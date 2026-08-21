import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/product_model.dart';

class ProductBenefits extends StatelessWidget {
  const ProductBenefits({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final List<String> benefits = product.benefits.isEmpty
        ? <String>['Farm fresh quality', 'Carefully selected', 'Direct sourcing']
        : product.benefits;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Why You’ll Love It',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 11),
        Wrap(
          spacing: 9,
          runSpacing: 9,
          children: benefits.map((String benefit) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF7EF),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    benefit,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            );
          }).toList(growable: false),
        ),
      ],
    );
  }
}
