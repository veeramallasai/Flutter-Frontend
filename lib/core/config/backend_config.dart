import 'environment_config.dart';

import 'package:flutter/foundation.dart';

class BackendConfig {
  BackendConfig._();

  static const String _overrideBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static String get baseUrl {
    if (_overrideBaseUrl.trim().isNotEmpty) {
      return _withoutTrailingSlash(_overrideBaseUrl.trim());
    }
    switch (EnvironmentConfig.current) {
      case AppEnvironment.production:
        throw StateError('API_BASE_URL is required for a production build.');
      case AppEnvironment.staging:
        throw StateError('API_BASE_URL is required for a staging build.');
      case AppEnvironment.development:
        if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
          return 'http://10.0.2.2:8080';
        }
        return 'http://localhost:8080';
    }
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
    return Uri.parse('$baseUrl$normalizedPath')
        .replace(queryParameters: query.isEmpty ? null : query);
  }

  static String _withoutTrailingSlash(String value) =>
      value.endsWith('/') ? value.substring(0, value.length - 1) : value;
}
