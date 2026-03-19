import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/train.dart';
import '../models/pnr_status.dart';
import '../db/database_helper.dart';

/// Fetches live train status and PNR from the backend.
/// Automatically falls back to the SQLite cache when offline.
class TrainApiService {
  static final TrainApiService instance = TrainApiService._();
  TrainApiService._();

  // Change to your deployed backend URL in production
  static const String _baseUrl =
      String.fromEnvironment('API_URL', defaultValue: 'http://10.0.2.2:3001');

  // ─── Train Status ──────────────────────────────────────────────────────────

  Future<Train?> getTrainStatus(String trainNo) async {
    // 1. Try SQLite cache first (if recently cached)
    final cached = await DatabaseHelper.instance.getCachedTrainJson(trainNo);
    if (cached != null) {
      try {
        final json = jsonDecode(cached) as Map<String, dynamic>;
        return Train.fromJson({...json, 'isOffline': false});
      } catch (_) {}
    }

    // 2. Try live API
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/api/train/$trainNo'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final trainData = body['data'] as Map<String, dynamic>;
        // Cache for offline use
        await DatabaseHelper.instance.cacheTrainJson(trainNo, jsonEncode(trainData));
        return Train.fromJson(trainData);
      }
    } catch (_) {
      // Network error — try stale cache
    }

    // 3. Serve stale cache with offline flag
    final stale = await _getStaleCache(trainNo);
    if (stale != null) {
      return Train.fromJson({...stale, 'isOffline': true});
    }

    return null;
  }

  Future<List<Map<String, dynamic>>> getSchedule(String trainNo) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/api/train/$trainNo/schedule'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        return List<Map<String, dynamic>>.from(body['data'] as List);
      }
    } catch (_) {}
    return [];
  }

  // ─── PNR Status ────────────────────────────────────────────────────────────

  Future<PNRStatus?> getPNRStatus(String pnrNo) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/api/pnr/$pnrNo'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        return PNRStatus.fromJson(body['data'] as Map<String, dynamic>);
      }
    } catch (_) {}
    return null;
  }

  // ─── Crowdsource Upload ────────────────────────────────────────────────────

  Future<bool> uploadTower({
    required int mcc,
    required int mnc,
    required int cid,
    required int lac,
    required double lat,
    required double lon,
    required String idToken,
    String routeCode = 'UNKNOWN',
    String stationNear = '',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/towers'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'mcc': mcc, 'mnc': mnc, 'cid': cid, 'lac': lac,
          'lat': lat, 'lon': lon,
          'routeCode': routeCode, 'stationNear': stationNear,
        }),
      ).timeout(const Duration(seconds: 10));
      return response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> _getStaleCache(String trainNo) async {
    try {
      final db = DatabaseHelper.instance;
      final rows = await (await db.database).query(
        'cached_trains', where: 'train_no = ?', whereArgs: [trainNo], limit: 1,
      );
      if (rows.isNotEmpty) {
        return jsonDecode(rows.first['json_data'] as String) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }
}
