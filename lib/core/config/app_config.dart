import '../constants/app_constants.dart';
import 'backend_config.dart';
import 'environment_config.dart';

class AppConfig {
  AppConfig._();

  static const String name = AppConstants.appName;
  static const String version = String.fromEnvironment(
    'APP_VERSION',
    defaultValue: '1.0.0',
  );
  static const String buildNumber = String.fromEnvironment(
    'BUILD_NUMBER',
    defaultValue: '1',
  );

  static String get environment => EnvironmentConfig.name;
  static String get apiBaseUrl => BackendConfig.baseUrl;
  static bool get isProduction => EnvironmentConfig.isProduction;
  static bool get showDebugBanner => !isProduction;

  static Map<String, String> get diagnostics => <String, String>{
    'app': name,
    'version': version,
    'build': buildNumber,
    'environment': environment,
    'apiBaseUrl': apiBaseUrl,
  };
}
