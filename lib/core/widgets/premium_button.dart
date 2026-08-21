import 'package:flutter/material.dart';

class PremiumButton extends StatelessWidget {
  const PremiumButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.dark = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final bool dark;

  @override
  Widget build(BuildContext context) => FilledButton.icon(
        onPressed: loading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: dark ? const Color(0xFF073D24) : const Color(0xFF0B7A3E),
          minimumSize: const Size.fromHeight(55),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
        ),
        icon: loading
            ? const SizedBox(width: 17, height: 17, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Icon(icon ?? Icons.arrow_forward_rounded, size: 19),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.2)),
      );
}
