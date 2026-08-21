import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class PremiumOutlinedButton extends StatelessWidget {
  const PremiumOutlinedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
        onPressed: loading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
        ),
        icon: loading
            ? const SizedBox(width: 17, height: 17, child: CircularProgressIndicator(strokeWidth: 2))
            : Icon(icon ?? Icons.arrow_forward_rounded, size: 19),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.2)),
      );
}
