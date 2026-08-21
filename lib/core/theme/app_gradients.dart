import 'package:flutter/material.dart';

class AppGradients {
  AppGradients._();

  static const LinearGradient premiumGreen = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[Color(0xFF042E1B), Color(0xFF0B7A3E), Color(0xFF25A75D)],
  );

  static const LinearGradient harvestGold = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[Color(0xFF5A3800), Color(0xFFC78100), Color(0xFFF4B400)],
  );

  static const LinearGradient softSurface = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[Color(0xFFF2FAF5), Color(0xFFFFFBF0)],
  );
}
