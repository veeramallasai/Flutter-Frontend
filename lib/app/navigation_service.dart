import 'package:flutter/material.dart';

class NavigationService {
  NavigationService._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static NavigatorState get navigator {
    final NavigatorState? value = navigatorKey.currentState;
    if (value == null) {
      throw StateError('Navigator is not ready yet.');
    }
    return value;
  }

  static BuildContext? get context => navigatorKey.currentContext;

  static Future<T?> pushNamed<T extends Object?>(
    String route, {
    Object? arguments,
  }) => navigator.pushNamed<T>(route, arguments: arguments);

  static Future<T?> replaceNamed<T extends Object?, TO extends Object?>(
    String route, {
    Object? arguments,
    TO? result,
  }) => navigator.pushReplacementNamed<T, TO>(
    route,
    arguments: arguments,
    result: result,
  );

  static Future<T?> clearAndPush<T extends Object?>(
    String route, {
    Object? arguments,
  }) => navigator.pushNamedAndRemoveUntil<T>(
    route,
    (Route<dynamic> current) => false,
    arguments: arguments,
  );

  static bool canPop() => navigator.canPop();

  static void pop<T extends Object?>([T? result]) {
    if (navigator.canPop()) navigator.pop<T>(result);
  }
}
