import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/product_model.dart';

class RelatedProducts extends StatelessWidget {
  const RelatedProducts({
    super.key,
    required this.products,
    required this.onProductTap,
    this.onAddTap,
  });

  final List<ProductModel> products;
  final ValueChanged<ProductModel> onProductTap;
  final ValueChanged<ProductModel>? onAddTap;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'You May Also Like',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 235,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(width: 11),
            itemBuilder: (_, int index) {
              final ProductModel product = products[index];
              return _RelatedProductCard(
                product: product,
                onTap: () => onProductTap(product),
                onAddTap: onAddTap == null ? null : () => onAddTap!(product),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _RelatedProductCard extends StatelessWidget {
  const _RelatedProductCard({
    required this.product,
    required this.onTap,
    this.onAddTap,
  });

  final ProductModel product;
  final VoidCallback onTap;
  final VoidCallback? onAddTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 155,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAF9),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: _ProductImage(path: product.imageUrl),
                    ),
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  product.unit,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 7),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        '₹${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    if (onAddTap != null)
                      SizedBox(
                        width: 32,
                        height: 30,
                        child: IconButton(
                          onPressed: product.inStock ? onAddTap : null,
                          padding: EdgeInsets.zero,
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFFE8F5E9),
                          ),
                          icon: const Icon(
                            Icons.add_rounded,
                            color: AppColors.primary,
                            size: 18,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    if (path.trim().isEmpty) {
      return const Icon(Icons.eco_rounded, color: AppColors.primary, size: 42);
    }
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(path, fit: BoxFit.contain, errorBuilder: _error);
    }
    return Image.asset(path, fit: BoxFit.contain, errorBuilder: _error);
  }

  Widget _error(BuildContext context, Object error, StackTrace? stackTrace) {
    return const Icon(
      Icons.image_not_supported_outlined,
      color: AppColors.textSecondary,
      size: 38,
    );
  }
}
