import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/product_model.dart';

class ProductImageGallery extends StatefulWidget {
  const ProductImageGallery({
    super.key,
    required this.product,
    this.height = 330,
  });

  final ProductModel product;
  final double height;

  @override
  State<ProductImageGallery> createState() => _ProductImageGalleryState();
}

class _ProductImageGalleryState extends State<ProductImageGallery> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> images = widget.product.allImages;

    return Column(
      children: <Widget>[
        Container(
          height: widget.height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: AppColors.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: <Widget>[
              if (images.isEmpty)
                const Center(
                  child: Icon(Icons.eco_rounded, color: AppColors.primary, size: 80),
                )
              else
                PageView.builder(
                  controller: _controller,
                  itemCount: images.length,
                  onPageChanged: (int index) =>
                      setState(() => _currentIndex = index),
                  itemBuilder: (_, int index) => Padding(
                    padding: const EdgeInsets.all(24),
                    child: Hero(
                      tag: 'product-${widget.product.id}-$index',
                      child: _ProductImage(path: images[index]),
                    ),
                  ),
                ),
              if (widget.product.discountPercent > 0)
                Positioned(
                  left: 14,
                  top: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      '${widget.product.discountPercent}% OFF',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (images.length > 1) ...<Widget>[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List<Widget>.generate(images.length, (int index) {
              final bool active = index == _currentIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: active ? 22 : 7,
                height: 7,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : AppColors.border,
                  borderRadius: BorderRadius.circular(10),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.path});
  final String path;

  @override
  Widget build(BuildContext context) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(path, fit: BoxFit.contain, errorBuilder: _error);
    }
    return Image.asset(path, fit: BoxFit.contain, errorBuilder: _error);
  }

  Widget _error(BuildContext context, Object error, StackTrace? stackTrace) {
    return const Center(
      child: Icon(Icons.image_not_supported_outlined, color: AppColors.textSecondary, size: 55),
    );
  }
}
