import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class CartModeWarning extends StatelessWidget {
  const CartModeWarning({
    super.key,
    required this.hasMixedModes,
    required this.shoppingMode,
  });

  final bool hasMixedModes;
  final String shoppingMode;

  @override
  Widget build(BuildContext context) {
    if (!hasMixedModes) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5E5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF1D7A6)),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.info_outline_rounded, color: Color(0xFFB96D00)),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              'Home and bulk products are together. Checkout will use ${shoppingMode == 'shop' ? 'bulk' : 'home'} delivery.',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 9,
                height: 1.4,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
