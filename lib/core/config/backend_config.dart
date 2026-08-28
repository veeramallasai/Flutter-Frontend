import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kDebugMode, kIsWeb;

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

  static const String _springBackendUrl = String.fromEnvironment(
    'SPRING_BACKEND_URL',
    defaultValue: '',
  );

  static const String _defaultProductionUrl = String.fromEnvironment(
    'PROD_BACKEND_URL',
    defaultValue: '',
  );

  /// Default production Railway backend URL fallback when deployed
  static const String fallbackRailwayBackendUrl =
      'https://farm-to-home-backend-production.up.railway.app';

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
    if (_springBackendUrl.trim().isNotEmpty) {
      return _withoutTrailingSlash(_springBackendUrl.trim());
    }
    if (_defaultProductionUrl.trim().isNotEmpty) {
      return _withoutTrailingSlash(_defaultProductionUrl.trim());
    }

    // Direct local debug requests to local Spring Boot server on port 8085
    if (kDebugMode) {
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        return 'http://10.0.2.2:8085';
      }
      return 'http://localhost:8085';
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
        // Direct API calls to the Spring Boot backend server, not the Flutter web static host
        return _withoutTrailingSlash(fallbackRailwayBackendUrl);
      }
      // When running on localhost in Flutter web, default to local Spring Boot server on port 8085
      return 'http://localhost:8085';
    }

    return fallbackRailwayBackendUrl;
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
