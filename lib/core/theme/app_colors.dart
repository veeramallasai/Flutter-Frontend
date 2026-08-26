import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color primary = Color(0xFF2E7D32);
  static const Color primaryDark = Color(0xFF1B5E20);
  static const Color primaryLight = Color(0xFF81C784);
  static const Color accentBackground = Color(0xFFE8F5E9);
  static const Color background = Color(0xFFF9FAF9);
  static const Color card = Color(0xFFFFFFFF);
  static const Color text = Color(0xFF111111);
  static const Color muted = Color(0xFF666666);
  static const Color border = Color(0xFFE0E3E0);
  static const Color inputBackground = Color(0xFFF0F2F0);
  static const Color subtle = Color(0xFFF5F5F5);
  static const Color error = Color(0xFFD32F2F);
  static const Color star = Color(0xFFFFB300);
  static const Color google = Color(0xFF4285F4);
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);

  // Compatibility names already used by older screens.
  static const Color textPrimary = text;
  static const Color textSecondary = muted;
  static const Color secondary = primaryLight;
  static const Color surfaceSoft = subtle;
  static const Color surface = card;
  static const Color divider = border;
  static const Color success = primary;
  static const Color warning = star;
  static const Color onPrimary = white;

  static const Color primaryGreen = primary;
  static const Color darkGreen = primaryDark;
  static const Color accentGreen = primaryLight;
  static const Color lightMint = accentBackground;
  static const Color lightCream = Color(0xFFFFFBF2);
  static const Color darkText = text;
  static const Color greyText = muted;
  static const Color errorRed = error;
  static const Color goldAmber = star;
}
