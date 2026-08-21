enum AppEnvironment { development, staging, production }

class EnvironmentConfig {
  EnvironmentConfig._();

  static const String _environmentName = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );

  static AppEnvironment get current {
    switch (_environmentName.trim().toLowerCase()) {
      case 'production':
      case 'prod':
        return AppEnvironment.production;
      case 'staging':
      case 'stage':
        return AppEnvironment.staging;
      default:
        return AppEnvironment.development;
    }
  }

  static bool get isDevelopment => current == AppEnvironment.development;
  static bool get isStaging => current == AppEnvironment.staging;
  static bool get isProduction => current == AppEnvironment.production;

  static String get name => current.name;

  static const bool enableVerboseLogs = bool.fromEnvironment(
    'ENABLE_VERBOSE_LOGS',
    defaultValue: true,
  );
  static const bool enableAnalytics = bool.fromEnvironment(
    'ENABLE_ANALYTICS',
    defaultValue: true,
  );
  static const bool enableCrashReporting = bool.fromEnvironment(
    'ENABLE_CRASH_REPORTING',
    defaultValue: true,
  );
}
