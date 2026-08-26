import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import 'app_router.dart';
import 'app_routes.dart';

class FarmToHomeApp extends StatelessWidget {
  const FarmToHomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Farm To Home',
      theme: AppTheme.premiumTheme,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
