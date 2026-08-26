import 'package:flutter/foundation.dart' show kIsWeb;

class BackendConfig {
  BackendConfig._();

  static const String _overrideBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static const String _apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: '',
  );

  static const String _railwayUrl = String.fromEnvironment(
    'RAILWAY_URL',
    defaultValue: '',
  );

  static const String _defaultProductionUrl = String.fromEnvironment(
    'PROD_BACKEND_URL',
    defaultValue: 'https://farm-to-home-backend.up.railway.app',
  );

  static String get baseUrl {
    if (_overrideBaseUrl.trim().isNotEmpty) {
      return _withoutTrailingSlash(_overrideBaseUrl.trim());
    }
    if (_apiUrl.trim().isNotEmpty) {
      return _withoutTrailingSlash(_apiUrl.trim());
    }
    if (_railwayUrl.trim().isNotEmpty) {
      return _withoutTrailingSlash(_railwayUrl.trim());
    }
    if (kIsWeb) {
      return _withoutTrailingSlash(_defaultProductionUrl);
    }
    return 'http://localhost:8082';
  }




  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const int maximumRetries = 2;
  static const Duration retryDelay = Duration(milliseconds: 600);

  static Uri uri(String path, {Map<String, dynamic>? queryParameters}) {
    final String normalizedPath = path.startsWith('/') ? path : '/$path';
    final Map<String, String> query = <String, String>{};
    queryParameters?.forEach((String key, dynamic value) {
      if (value != null) query[key] = value.toString();
    });
    return Uri.parse(
      '$baseUrl$normalizedPath',
    ).replace(queryParameters: query.isEmpty ? null : query);
  }

  static String _withoutTrailingSlash(String value) =>
      value.endsWith('/') ? value.substring(0, value.length - 1) : value;
}
