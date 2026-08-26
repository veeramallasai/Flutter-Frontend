import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppSnackbar {
  AppSnackbar._();

  static void success(BuildContext context, String message) => _show(
    context,
    message,
    color: const Color(0xFF073D24),
    icon: Icons.check_circle_rounded,
  );

  static void error(BuildContext context, String message) => _show(
    context,
    message,
    color: AppColors.error,
    icon: Icons.error_outline_rounded,
  );

  static void info(BuildContext context, String message) => _show(
    context,
    message,
    color: const Color(0xFF214E78),
    icon: Icons.info_outline_rounded,
  );

  static void _show(
    BuildContext context,
    String message, {
    required Color color,
    required IconData icon,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
          content: Row(
            children: <Widget>[
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }
}
