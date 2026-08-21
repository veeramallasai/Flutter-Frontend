import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/product_model.dart';

class ProductDescription extends StatefulWidget {
  const ProductDescription({
    super.key,
    required this.product,
  });

  final ProductModel product;

  @override
  State<ProductDescription> createState() => _ProductDescriptionState();
}

class _ProductDescriptionState extends State<ProductDescription> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final String description = widget.product.description.trim().isEmpty
        ? 'Fresh and carefully selected for Farm To Home customers.'
        : widget.product.description.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Product Description',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 9),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          child: Text(
            description,
            maxLines: _expanded ? null : 3,
            overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              height: 1.65,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (description.length > 130)
          TextButton(
            onPressed: () => setState(() => _expanded = !_expanded),
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            child: Text(
              _expanded ? 'SHOW LESS' : 'READ MORE',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 9,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
      ],
    );
  }
}
