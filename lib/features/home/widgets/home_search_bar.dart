import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class PremiumHomeSearchBar extends StatelessWidget {
  const PremiumHomeSearchBar({
    super.key,
    required this.onTap,
    this.hint = 'Search vegetables, fruits, dairy...',
    this.child,
  });

  final VoidCallback onTap;
  final String hint;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    if (child != null) return child!;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 58,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 14,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: <Widget>[
              const Icon(Icons.search_rounded, color: AppColors.primary),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  hint,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(
                Icons.tune_rounded,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
