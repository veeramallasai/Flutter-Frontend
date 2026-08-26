import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/order_item_model.dart';

class OrderItemTile extends StatelessWidget {
  const OrderItemTile({super.key, required this.item, this.showDivider = true});

  final OrderItemModel item;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _OrderProductImage(imageUrl: item.imageUrl),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      item.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        height: 1.25,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      item.unit,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: <Widget>[
                        Text(
                          '₹${item.unitPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        if (item.mrp > item.unitPrice) ...<Widget>[
                          const SizedBox(width: 6),
                          Text(
                            '₹${item.mrp.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 10,
                              decoration: TextDecoration.lineThrough,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Qty ${item.quantity}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '₹${item.lineTotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (showDivider)
          const Divider(height: 1, thickness: 1, color: AppColors.border),
      ],
    );
  }
}

class _OrderProductImage extends StatelessWidget {
  const _OrderProductImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 70,
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: _buildImage(),
    );
  }

  Widget _buildImage() {
    if (imageUrl.trim().isEmpty) {
      return const Icon(
        Icons.local_grocery_store_rounded,
        color: AppColors.primary,
        size: 30,
      );
    }

    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.contain,
        errorBuilder:
            (_, __, ___) => const Icon(
              Icons.image_not_supported_outlined,
              color: AppColors.textSecondary,
            ),
      );
    }

    return Image.asset(
      imageUrl,
      fit: BoxFit.contain,
      errorBuilder:
          (_, __, ___) => const Icon(
            Icons.image_not_supported_outlined,
            color: AppColors.textSecondary,
          ),
    );
  }
}
