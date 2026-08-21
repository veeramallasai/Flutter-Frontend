import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class AuthBackground extends StatelessWidget {
  const AuthBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.background,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[Color(0xFFF8FCF9), Color(0xFFEAF7EF), Color(0xFFFFFBF0)],
          ),
        ),
        child: Stack(
          children: <Widget>[
            const Positioned(right: -90, top: -90, child: _Glow(size: 260, color: Color(0x1F18A75D))),
            const Positioned(left: -110, bottom: -100, child: _Glow(size: 300, color: Color(0x1FF4B400))),
            Positioned.fill(child: child),
          ],
        ),
      );
}

class _Glow extends StatelessWidget {
  const _Glow({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}
