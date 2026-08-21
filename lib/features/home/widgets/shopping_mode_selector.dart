import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class ShoppingModeSelector extends StatelessWidget {
  const ShoppingModeSelector({
    super.key,
    required this.mode,
    required this.onTap,
    this.child,
  });

  final String mode;
  final VoidCallback onTap;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    if (child != null) return child!;
    final bool home = mode == 'home';
    return Align(
      alignment: Alignment.centerLeft,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(color: const Color(0xFFE8F6ED), borderRadius: BorderRadius.circular(10)),
                  child: Icon(home ? Icons.home_rounded : Icons.storefront_rounded, size: 19, color: AppColors.primary),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text('Shopping for', style: TextStyle(color: AppColors.textSecondary, fontSize: 9.5, fontWeight: FontWeight.w700)),
                    Text(home ? 'Home' : 'Shop Owners', style: const TextStyle(color: AppColors.textPrimary, fontSize: 12.5, fontWeight: FontWeight.w900)),
                  ],
                ),
                const SizedBox(width: 10),
                const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
