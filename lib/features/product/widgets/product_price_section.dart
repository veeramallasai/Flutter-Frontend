import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/product_model.dart';

class ProductPriceSection extends StatelessWidget {
  const ProductPriceSection({
    super.key,
    required this.product,
  });

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5FAF7),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD6EBDD)),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      '₹${product.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Text(
                        '/ ${product.unit}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                if (product.mrp > product.price) ...<Widget>[
                  const SizedBox(height: 5),
                  Row(
                    children: <Widget>[
                      Text(
                        'MRP ₹${product.mrp.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                          decoration: TextDecoration.lineThrough,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Save ₹${product.savings.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: product.inStock
                  ? const Color(0xFFE4F6EB)
                  : const Color(0xFFFFEEEE),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              product.inStock ? 'IN STOCK' : 'OUT OF STOCK',
              style: TextStyle(
                color: product.inStock ? AppColors.primary : AppColors.error,
                fontSize: 8,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
