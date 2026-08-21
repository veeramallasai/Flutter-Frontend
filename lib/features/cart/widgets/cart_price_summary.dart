import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class CartPriceSummary extends StatelessWidget {
  const CartPriceSummary({
    super.key,
    required this.subtotal,
    required this.productSavings,
    required this.couponDiscount,
    required this.total,
  });

  final double subtotal;
  final double productSavings;
  final double couponDiscount;
  final double total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Price Details',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 13),
          _Row(label: 'Original MRP total', value: subtotal),
          if (productSavings > 0)
            _Row(label: 'Product discount', value: -productSavings, green: true),
          if (couponDiscount > 0)
            _Row(label: 'Coupon discount', value: -couponDiscount, green: true),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 9),
            child: Divider(height: 1),
          ),
          _Row(label: 'You pay', value: total, bold: true),
          const SizedBox(height: 6),
          const Text(
            'Delivery charges are calculated in the next step.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 8,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.value,
    this.green = false,
    this.bold = false,
  });

  final String label;
  final double value;
  final bool green;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final String prefix = value < 0 ? '- ' : '';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: bold ? AppColors.textPrimary : AppColors.textSecondary,
                fontSize: bold ? 11 : 9.5,
                fontWeight: bold ? FontWeight.w900 : FontWeight.w600,
              ),
            ),
          ),
          Text(
            '$prefix₹${value.abs().toStringAsFixed(2)}',
            style: TextStyle(
              color: green ? AppColors.primary : AppColors.textPrimary,
              fontSize: bold ? 13 : 10,
              fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
