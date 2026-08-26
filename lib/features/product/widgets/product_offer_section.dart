import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/product_model.dart';

class ProductOfferSection extends StatelessWidget {
  const ProductOfferSection({
    super.key,
    required this.product,
    this.couponCode = '',
    this.couponText = '',
  });

  final ProductModel product;
  final String couponCode;
  final String couponText;

  @override
  Widget build(BuildContext context) {
    if (product.discountPercent <= 0 && couponCode.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Offers',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        if (product.discountPercent > 0)
          _OfferTile(
            icon: Icons.local_offer_rounded,
            title: '${product.discountPercent}% product discount',
            subtitle:
                'You save ₹${product.savings.toStringAsFixed(2)} on this unit.',
          ),
        if (product.discountPercent > 0 && couponCode.trim().isNotEmpty)
          const SizedBox(height: 9),
        if (couponCode.trim().isNotEmpty)
          _OfferTile(
            icon: Icons.confirmation_number_rounded,
            title: 'Use code ${couponCode.trim().toUpperCase()}',
            subtitle:
                couponText.trim().isEmpty
                    ? 'Apply this coupon during checkout.'
                    : couponText.trim(),
          ),
      ],
    );
  }
}

class _OfferTile extends StatelessWidget {
  const _OfferTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, color: AppColors.primary, size: 21),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
