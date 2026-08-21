import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class CartHeader extends StatelessWidget {
  const CartHeader({
    super.key,
    required this.itemCount,
    required this.shoppingMode,
    this.onClear,
  });

  final int itemCount;
  final String shoppingMode;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final bool shop = shoppingMode.toLowerCase() == 'shop';
    return Row(
      children: <Widget>[
        Container(
          width: 43,
          height: 43,
          decoration: const BoxDecoration(
            color: Color(0xFFEAF7EF),
            shape: BoxShape.circle,
          ),
          child: Icon(
            shop ? Icons.storefront_rounded : Icons.shopping_basket_rounded,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                shop ? 'Bulk Shopping Cart' : 'Your Fresh Cart',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$itemCount item${itemCount == 1 ? '' : 's'} selected',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (onClear != null)
          TextButton(
            onPressed: onClear,
            child: const Text(
              'CLEAR',
              style: TextStyle(
                color: AppColors.error,
                fontSize: 9,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
      ],
    );
  }
}
