import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/services/connectivity_service.dart';

class ConnectivityProvider extends ChangeNotifier {
  ConnectivityProvider({ConnectivityService? service})
      : _service = service ?? ConnectivityService();

  final ConnectivityService _service;
  StreamSubscription<bool>? _subscription;
  bool _isConnected = true;
  bool _isChecking = false;
  bool _disposed = false;

  bool get isConnected => _isConnected;
  bool get isOffline => !_isConnected;
  bool get isChecking => _isChecking;

  Future<void> start() async {
    _subscription?.cancel();
    _subscription = _service.changes.listen((bool value) {
      _isConnected = value;
      _notify();
    });
    _service.startMonitoring();
    await checkNow();
  }

  Future<bool> checkNow() async {
    _isChecking = true;
    _notify();
    try {
      _isConnected = await _service.check();
      return _isConnected;
    } finally {
      _isChecking = false;
      _notify();
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _subscription?.cancel();
    _service.dispose();
    super.dispose();
  }
}
