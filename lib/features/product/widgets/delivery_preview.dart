import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class DeliveryPreview extends StatelessWidget {
  const DeliveryPreview({
    super.key,
    required this.shoppingMode,
    this.deliveryText,
  });

  final String shoppingMode;
  final String? deliveryText;

  @override
  Widget build(BuildContext context) {
    final bool shop = shoppingMode.toLowerCase() == 'shop';
    final String message = deliveryText?.trim().isNotEmpty == true
        ? deliveryText!.trim()
        : shop
        ? 'Bulk delivery slot shown during checkout'
        : 'Fresh delivery available today';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF2DCA4)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Icon(
              shop ? Icons.local_shipping_rounded : Icons.delivery_dining_rounded,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  shop ? 'Shop Delivery' : 'Home Delivery',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  message,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 9.5,
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
