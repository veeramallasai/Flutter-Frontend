import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AssetImageWidget extends StatelessWidget {
  const AssetImageWidget({
    super.key,
    required this.path,
    this.fit = BoxFit.contain,
    this.scale = 1,
  });
  final String path;
  final BoxFit fit;
  final double scale;

  @override
  Widget build(BuildContext context) {
    if (path.trim().isEmpty) return const _Fallback();
    return ClipRect(
      child: Transform.scale(
        scale: scale,
        child: Image.asset(
          path,
          fit: fit,
          errorBuilder: (_, __, ___) => const _Fallback(),
        ),
      ),
    );
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback();
  @override
  Widget build(BuildContext context) => const Center(
    child: Icon(Icons.eco_rounded, color: AppColors.primary, size: 42),
  );
}
