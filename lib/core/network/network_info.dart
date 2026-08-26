import 'dart:async';

import 'package:http/http.dart' as http;

typedef ConnectivityChecker = Future<bool> Function();

class NetworkInfo {
  NetworkInfo({
    ConnectivityChecker? checker,
    http.Client? client,
    Uri? probeUri,
  }) : _checker = checker,
       _client = client ?? http.Client(),
       _probeUri =
           probeUri ?? Uri.parse('https://www.gstatic.com/generate_204');

  final ConnectivityChecker? _checker;
  final http.Client _client;
  final Uri _probeUri;

  Future<bool> get isConnected async {
    if (_checker != null) return _checker();
    try {
      final http.Response response = await _client
          .get(_probeUri)
          .timeout(const Duration(seconds: 5));
      return response.statusCode >= 200 && response.statusCode < 500;
    } catch (_) {
      return false;
    }
  }

  Future<void> requireConnection() async {
    if (!await isConnected) throw StateError('No internet connection.');
  }

  void dispose() => _client.close();
}
