import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/product_model.dart';

class ProductTitleSection extends StatelessWidget {
  const ProductTitleSection({
    super.key,
    required this.product,
  });

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (product.category.isNotEmpty)
          Text(
            product.category.toUpperCase(),
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 9,
              letterSpacing: 0.7,
              fontWeight: FontWeight.w900,
            ),
          ),
        const SizedBox(height: 6),
        Text(
          product.name,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 25,
            height: 1.15,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF7EF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: <Widget>[
                  const Icon(Icons.star_rounded, color: Color(0xFFF4B400), size: 15),
                  const SizedBox(width: 4),
                  Text(
                    product.rating.toStringAsFixed(1),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${product.reviewCount} reviews',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (product.isFresh) ...<Widget>[
              const Spacer(),
              const Icon(Icons.eco_rounded, color: AppColors.primary, size: 17),
              const SizedBox(width: 4),
              const Text(
                'Fresh',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
