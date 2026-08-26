import 'dart:async';

import '../network/network_info.dart';

class ConnectivityService {
  ConnectivityService({NetworkInfo? networkInfo})
    : _networkInfo = networkInfo ?? NetworkInfo();

  final NetworkInfo _networkInfo;
  final StreamController<bool> _controller = StreamController<bool>.broadcast();
  Timer? _timer;
  bool? _lastValue;

  Stream<bool> get changes => _controller.stream;
  bool? get lastKnownStatus => _lastValue;

  Future<bool> check() async {
    final bool connected = await _networkInfo.isConnected;
    if (_lastValue != connected) {
      _lastValue = connected;
      if (!_controller.isClosed) _controller.add(connected);
    }
    return connected;
  }

  void startMonitoring({Duration interval = const Duration(seconds: 10)}) {
    _timer?.cancel();
    check();
    _timer = Timer.periodic(interval, (_) => check());
  }

  void stopMonitoring() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> dispose() async {
    stopMonitoring();
    _networkInfo.dispose();
    await _controller.close();
  }
}
