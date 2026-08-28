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
      'https://farmtohome-backend-production-3378.up.railway.app';

  static String get baseUrl {
    if (_overrideBaseUrl.trim().isNotEmpty) {
      return _formatUrl(_overrideBaseUrl);
    }
    if (_apiUrl.trim().isNotEmpty) {
      return _formatUrl(_apiUrl);
    }
    if (_railwayUrl.trim().isNotEmpty) {
      return _formatUrl(_railwayUrl);
    }
    if (_springBackendUrl.trim().isNotEmpty) {
      return _formatUrl(_springBackendUrl);
    }
    if (_defaultProductionUrl.trim().isNotEmpty) {
      return _formatUrl(_defaultProductionUrl);
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
        return _formatUrl(fallbackRailwayBackendUrl);
      }
      // When running on localhost in Flutter web, default to local Spring Boot server on port 8085
      return 'http://localhost:8085';
    }

    return _formatUrl(fallbackRailwayBackendUrl);
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

  static String _formatUrl(String value) {
    String trimmed = value.trim();
    if (trimmed.isEmpty) return trimmed;
    if (trimmed.endsWith('/')) {
      trimmed = trimmed.substring(0, trimmed.length - 1);
    }
    if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
      trimmed = 'https://$trimmed';
    }
    return trimmed;
  }
  static String _withoutTrailingSlash(String value) => _formatUrl(value);
}
