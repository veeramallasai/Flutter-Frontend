import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/bootstrap/app_bootstrap.dart';
import 'core/theme/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppBootstrap.initialize();

  ErrorWidget.builder = (FlutterErrorDetails details) {
    debugPrint('Farm To Home UI error: ${details.exceptionAsString()}');
    return const ColoredBox(
      color: AppColors.background,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Unable to load this section. Please try again.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.muted,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  };

  runApp(const FarmToHomeApp());
}
