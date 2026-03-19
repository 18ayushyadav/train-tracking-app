import 'dart:math';
import 'package:telephony/telephony.dart';

import '../db/database_helper.dart';
import '../models/cell_tower.dart';

/// Reads cell tower identifiers from the Android TelephonyManager API
/// and triangulates the train's approximate position using the local SQLite DB.
///
/// Privacy: No data is sent anywhere. Reads only happen when user opens the app
/// or explicitly requests a location update.
class CellTowerService {
  static final CellTowerService instance = CellTowerService._();
  CellTowerService._();

  final Telephony _telephony = Telephony.instance;

  // ─── Read Current Cell Towers ──────────────────────────────────────────────

  /// Returns the list of visible cell towers from Android CellInfo API.
  /// Returns empty list on web/iOS or if permissions are not granted.
  Future<List<CellTower>> getCurrentTowers() async {
    try {
      // Check permission (Android only)
      final granted = await _telephony.requestPhoneAndSmsPermissions;
      if (granted == null || !granted) return [];

      final cellInfoList = await _telephony.getCellInfoList;
      if (cellInfoList == null) return [];

      final towers = <CellTower>[];
      for (final info in cellInfoList) {
        if (info is CellInfoGsm) {
          final identity = info.cellIdentityGsm;
          final signal = info.cellSignalStrengthGsm;
          if (identity != null && identity.cid != null) {
            towers.add(CellTower(
              mcc: identity.mcc ?? 404,
              mnc: identity.mnc ?? 0,
              cid: identity.cid!,
              lac: identity.lac ?? 0,
              lat: 0, lon: 0, // to be filled from DB lookup
              signalStrength: signal?.dbm,
            ));
          }
        } else if (info is CellInfoLte) {
          final identity = info.cellIdentityLte;
          final signal = info.cellSignalStrengthLte;
          if (identity != null && identity.ci != null) {
            towers.add(CellTower(
              mcc: identity.mcc ?? 404,
              mnc: identity.mnc ?? 0,
              cid: identity.ci!,
              lac: identity.tac ?? 0,
              lat: 0, lon: 0,
              signalStrength: signal?.dbm,
            ));
          }
        }
      }
      return towers;
    } catch (e) {
      return [];
    }
  }

  // ─── Triangulation ─────────────────────────────────────────────────────────

  /// Attempts to triangulate position from current cell towers vs. SQLite DB.
  /// Returns (lat, lon, routeCode, stationNear) or null if no match found.
  Future<TriangulationResult?> triangulate() async {
    final towers = await getCurrentTowers();
    if (towers.isEmpty) return null;

    final db = DatabaseHelper.instance;
    final matchedTowers = <_WeightedTower>[];

    for (final t in towers) {
      final dbTower = await db.findTower(mcc: t.mcc, mnc: t.mnc, cid: t.cid);
      if (dbTower != null) {
        // Weight by signal strength (stronger signal = closer tower)
        final weight = t.signalStrength != null
            ? 1.0 / max(1, (-t.signalStrength!).toDouble())
            : 1.0;
        matchedTowers.add(_WeightedTower(dbTower, weight));
      }
    }

    if (matchedTowers.isEmpty) return null;

    // Weighted centroid
    double totalWeight = matchedTowers.fold(0, (s, w) => s + w.weight);
    double lat = matchedTowers.fold(0, (s, w) => s + w.tower.lat * w.weight) / totalWeight;
    double lon = matchedTowers.fold(0, (s, w) => s + w.tower.lon * w.weight) / totalWeight;

    // Pick the route and station from the highest-signal tower
    matchedTowers.sort((a, b) => b.weight.compareTo(a.weight));
    final best = matchedTowers.first.tower;

    return TriangulationResult(
      lat: lat,
      lon: lon,
      routeCode: best.routeCode,
      stationNear: best.stationNear,
      towerCount: matchedTowers.length,
    );
  }
}

class _WeightedTower {
  final CellTower tower;
  final double weight;
  _WeightedTower(this.tower, this.weight);
}

class TriangulationResult {
  final double lat;
  final double lon;
  final String routeCode;
  final String stationNear;
  final int towerCount;

  const TriangulationResult({
    required this.lat,
    required this.lon,
    required this.routeCode,
    required this.stationNear,
    required this.towerCount,
  });
}
