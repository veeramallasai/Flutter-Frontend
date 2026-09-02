import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class NetworkImageWidget extends StatelessWidget {
  const NetworkImageWidget({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.borderRadius = 16,
    this.fallbackIcon = Icons.eco_rounded,
  });

  final String url;
  final BoxFit fit;
  final double borderRadius;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    if (url.trim().isEmpty) return _fallback();
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CachedNetworkImage(
        imageUrl: url,
        width: double.infinity,
        height: double.infinity,
        fit: fit,
        placeholder: (BuildContext context, String url) => const ColoredBox(
          color: Color(0xFFF1F8F4),
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
        ),
        errorWidget: (BuildContext context, String url, dynamic error) =>
            _fallback(),
      ),
    );
  }

  Widget _fallback() => ClipRRect(
    borderRadius: BorderRadius.circular(borderRadius),
    child: ColoredBox(
      color: const Color(0xFFF1F8F4),
      child: Center(
        child: Icon(fallbackIcon, color: AppColors.primary, size: 42),
      ),
    ),
  );
}
