import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/cell_tower.dart';

/// Singleton SQLite database helper.
/// Manages the pre-loaded cell tower table and any cached train data.
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _db;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'train_tracker.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
      onOpen: _seedIfEmpty,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE cell_towers (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        mcc         INTEGER NOT NULL,
        mnc         INTEGER NOT NULL,
        cid         INTEGER NOT NULL,
        lac         INTEGER NOT NULL DEFAULT 0,
        lat         REAL    NOT NULL,
        lon         REAL    NOT NULL,
        route_code  TEXT    NOT NULL DEFAULT 'UNKNOWN',
        station_near TEXT   NOT NULL DEFAULT ''
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_towers_cid ON cell_towers(cid, mnc, mcc)
    ''');

    await db.execute('''
      CREATE TABLE cached_trains (
        train_no  TEXT PRIMARY KEY,
        json_data TEXT NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
  }

  /// Seed tower data from bundled asset on first launch
  Future<void> _seedIfEmpty(Database db) async {
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM cell_towers'),
    );
    if (count != null && count > 0) return;

    try {
      final raw = await rootBundle.loadString('assets/data/seed_towers.json');
      final towers = jsonDecode(raw) as List;
      final batch = db.batch();
      for (final t in towers) {
        batch.insert('cell_towers', t as Map<String, dynamic>);
      }
      await batch.commit(noResult: true);
    } catch (e) {
      // Asset not found — seeding skipped (towers can be downloaded later)
    }
  }

  // ─── Tower Queries ─────────────────────────────────────────────────────────

  /// Find a tower by its exact CID/MCC/MNC
  Future<CellTower?> findTower({
    required int mcc,
    required int mnc,
    required int cid,
  }) async {
    final db = await database;
    final rows = await db.query(
      'cell_towers',
      where: 'mcc = ? AND mnc = ? AND cid = ?',
      whereArgs: [mcc, mnc, cid],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return CellTower.fromMap(rows.first);
  }

  /// Find N nearest towers to a lat/lon using bounding box
  Future<List<CellTower>> nearbyTowers({
    required double lat,
    required double lon,
    double radiusDeg = 0.5,
  }) async {
    final db = await database;
    final rows = await db.query(
      'cell_towers',
      where: 'lat BETWEEN ? AND ? AND lon BETWEEN ? AND ?',
      whereArgs: [lat - radiusDeg, lat + radiusDeg, lon - radiusDeg, lon + radiusDeg],
    );
    return rows.map(CellTower.fromMap).toList();
  }

  /// Insert a newly crowdsourced tower
  Future<void> insertTower(CellTower tower) async {
    final db = await database;
    await db.insert(
      'cell_towers',
      tower.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ─── Train Cache Queries ───────────────────────────────────────────────────

  Future<String?> getCachedTrainJson(String trainNo) async {
    final db = await database;
    final rows = await db.query(
      'cached_trains',
      where: 'train_no = ?',
      whereArgs: [trainNo],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final updatedAt = rows.first['updated_at'] as int;
    // Cache valid for 5 minutes
    if (DateTime.now().millisecondsSinceEpoch - updatedAt > 5 * 60 * 1000) {
      return null;
    }
    return rows.first['json_data'] as String;
  }

  Future<void> cacheTrainJson(String trainNo, String jsonData) async {
    final db = await database;
    await db.insert(
      'cached_trains',
      {
        'train_no': trainNo,
        'json_data': jsonData,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
