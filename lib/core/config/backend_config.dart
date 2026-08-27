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
    defaultValue: '',
  );

  /// Default production Railway backend URL fallback when deployed
  static const String fallbackRailwayBackendUrl =
      'https://flutter-frontend-production-e8d6.up.railway.app';

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
    if (_defaultProductionUrl.trim().isNotEmpty) {
      return _withoutTrailingSlash(_defaultProductionUrl.trim());
    }

    // Auto-detection for web production vs local environment
    if (kIsWeb) {
      final String host = Uri.base.host;
      final bool isLocalHost = host == 'localhost' ||
          host == '127.0.0.1' ||
          host == '0.0.0.0' ||
          host.isEmpty;
      if (!isLocalHost) {
        // App is deployed and running in browser (e.g. on Railway)
        // Default to Railway backend URL, or current web origin if API is co-located
        return _withoutTrailingSlash(fallbackRailwayBackendUrl);
      }
    }

    return 'http://localhost:8085';
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
