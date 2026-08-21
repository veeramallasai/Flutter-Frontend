import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle display = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 34,
    height: 1.08,
    letterSpacing: -1.1,
    fontWeight: FontWeight.w900,
  );

  static const TextStyle headline = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 24,
    height: 1.15,
    letterSpacing: -0.5,
    fontWeight: FontWeight.w900,
  );

  static const TextStyle title = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 18,
    height: 1.25,
    fontWeight: FontWeight.w800,
  );

  static const TextStyle subtitle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 14,
    height: 1.35,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle body = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 13,
    height: 1.5,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle caption = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 10.5,
    height: 1.35,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle button = TextStyle(
    color: Colors.white,
    fontSize: 12,
    letterSpacing: 0.25,
    fontWeight: FontWeight.w900,
  );

  static const TextStyle price = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 18,
    fontWeight: FontWeight.w900,
  );

  static const TextStyle savings = TextStyle(
    color: AppColors.primary,
    fontSize: 10.5,
    fontWeight: FontWeight.w800,
  );
}
