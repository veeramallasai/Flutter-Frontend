import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;

  late Animation<Offset> _textOffset;
  late Animation<double> _textOpacity;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _logoScale = Tween<double>(
      begin: .6,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.easeOutBack,
      ),
    );

    _logoOpacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_logoController);

    _textOffset = Tween<Offset>(
      begin: const Offset(0, .4),
      end: Offset.zero,
    ).animate(_textController);

    _textOpacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_textController);

    _logoController.forward();

    Future.delayed(
      const Duration(milliseconds: 500),
          () => _textController.forward(),
    );

    Timer(
      const Duration(seconds: 3),
          () {
        if (!mounted) return;

        Navigator.pushReplacementNamed(
          context,
          AppRoutes.session,
        );
      },
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xff014421),
              Color(0xff0B7A3E),
              Color(0xff23A559),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: -120,
                right: -80,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .08),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                bottom: -130,
                left: -90,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .06),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FadeTransition(
                      opacity: _logoOpacity,
                      child: ScaleTransition(
                        scale: _logoScale,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                            BorderRadius.circular(40),
                            boxShadow: [
                              BoxShadow(
                                color:
                                Colors.black.withValues(alpha: .18),
                                blurRadius: 40,
                                offset:
                                const Offset(0, 15),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.eco,
                            size: 80,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 35),
                    SlideTransition(
                      position: _textOffset,
                      child: FadeTransition(
                        opacity: _textOpacity,
                        child: const Column(
                          children: [
                            Text(
                              "FARM TO HOME",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight:
                                FontWeight.w900,
                                letterSpacing: 2,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Fresh • Organic • Trusted",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 15,
                                fontWeight:
                                FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 60),
                    const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const Positioned(
                bottom: 25,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    "Version 1.0.0",
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 12,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
