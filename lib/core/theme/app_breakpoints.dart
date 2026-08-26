import 'package:flutter/widgets.dart';

abstract final class AppBreakpoints {
  static const double compact = 360;
  static const double standardPhone = 390;
  static const double largePhone = 430;
  static const double tablet = 768;
  static const double desktop = 1100;

  static bool isPhone(BuildContext context) =>
      MediaQuery.sizeOf(context).width < tablet;
  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= desktop;

  static double horizontalPadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= desktop) return 32;
    if (width >= tablet) return 24;
    if (width <= compact) return 14;
    return 16;
  }
}
