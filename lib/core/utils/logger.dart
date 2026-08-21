import 'package:flutter/foundation.dart';

class AppLogger {
  AppLogger._();

  static void debug(String message, {String tag = 'FarmToHome'}) {
    if (kDebugMode) debugPrint('[$tag] $message');
  }

  static void info(String message, {String tag = 'INFO'}) => debug(message, tag: tag);

  static void warning(String message, {String tag = 'WARNING'}) => debug(message, tag: tag);

  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    String tag = 'ERROR',
  }) {
    if (!kDebugMode) return;
    debugPrint('[$tag] $message${error == null ? '' : ' | $error'}');
    if (stackTrace != null) debugPrintStack(stackTrace: stackTrace);
  }
}
