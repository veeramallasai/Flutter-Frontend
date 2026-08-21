import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class CartSavingsCard extends StatelessWidget {
  const CartSavingsCard({
    super.key,
    required this.productSavings,
    required this.couponSavings,
  });

  final double productSavings;
  final double couponSavings;

  @override
  Widget build(BuildContext context) {
    final double totalSavings = productSavings + couponSavings;
    if (totalSavings <= 0) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFFE4F6EB), Color(0xFFF4FBF7)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.celebration_rounded, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'You are saving ₹${totalSavings.toStringAsFixed(2)} on this cart!',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
