import 'dart:async';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';

import '../models/train.dart';
import '../models/pnr_status.dart';
import '../services/train_api_service.dart';
import '../services/cell_tower_service.dart';

enum TrainLoadState { idle, loading, loaded, error, offline }

class TrainProvider extends ChangeNotifier {
  Train? _train;
  PNRStatus? _pnrStatus;
  TrainLoadState _state = TrainLoadState.idle;
  String _errorMessage = '';
  Timer? _pollTimer;
  WebSocketChannel? _wsChannel;
  bool _isConnected = false;

  Train? get train => _train;
  PNRStatus? get pnrStatus => _pnrStatus;
  TrainLoadState get state => _state;
  String get errorMessage => _errorMessage;
  bool get isConnected => _isConnected;

  // ─── Train Status ──────────────────────────────────────────────────────────

  Future<void> loadTrain(String trainNo, {bool useOffline = false}) async {
    _state = TrainLoadState.loading;
    notifyListeners();

    if (useOffline) {
      final result = await CellTowerService.instance.triangulate();
      if (result != null) {
        _train = Train(
          trainNo: trainNo,
          trainName: 'Offline Mode',
          from: '--', to: '--',
          status: 'Estimated Position',
          currentStation: result.stationNear.isNotEmpty ? result.stationNear : 'Unknown',
          currentStationCode: result.routeCode,
          lat: result.lat,
          lon: result.lon,
          lastUpdated: DateTime.now(),
          isOffline: true,
        );
        _state = TrainLoadState.offline;
        notifyListeners();
        return;
      }
    }

    final train = await TrainApiService.instance.getTrainStatus(trainNo);
    if (train != null) {
      _train = train;
      _state = train.isOffline ? TrainLoadState.offline : TrainLoadState.loaded;
    } else {
      _state = TrainLoadState.error;
      _errorMessage = 'Could not fetch train data. Check your connection.';
    }
    notifyListeners();

    // Start live polling every 30s
    _startPolling(trainNo);
  }

  void _startPolling(String trainNo) {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      final train = await TrainApiService.instance.getTrainStatus(trainNo);
      if (train != null) {
        _train = train;
        _state = train.isOffline ? TrainLoadState.offline : TrainLoadState.loaded;
        notifyListeners();
      }
    });
  }

  // ─── WebSocket ─────────────────────────────────────────────────────────────

  void connectWebSocket(String trainNo, String wsUrl) {
    _wsChannel?.sink.close();
    final uri = Uri.parse(wsUrl);
    try {
      _wsChannel = WebSocketChannel.connect(uri);
      _isConnected = true;
      notifyListeners();

      // Send subscription message (Socket.io compatible)
      _wsChannel!.sink.add(jsonEncode({'type': 'subscribe_train', 'trainNo': trainNo}));

      _wsChannel!.stream.listen(
        (msg) {
          try {
            final data = jsonDecode(msg as String) as Map<String, dynamic>;
            if (data['trainNo'] == trainNo) {
              _train = Train.fromJson(data);
              notifyListeners();
            }
          } catch (_) {}
        },
        onDone: () { _isConnected = false; notifyListeners(); },
        onError: (_) { _isConnected = false; notifyListeners(); },
      );
    } catch (_) {
      _isConnected = false;
    }
  }

  // ─── PNR ──────────────────────────────────────────────────────────────────

  Future<void> loadPNR(String pnrNo) async {
    _state = TrainLoadState.loading;
    notifyListeners();

    final status = await TrainApiService.instance.getPNRStatus(pnrNo);
    if (status != null) {
      _pnrStatus = status;
      _state = TrainLoadState.loaded;
    } else {
      _state = TrainLoadState.error;
      _errorMessage = 'PNR not found or server unreachable.';
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _wsChannel?.sink.close();
    super.dispose();
  }
}
