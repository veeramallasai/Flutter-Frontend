import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class AddToCartBar extends StatelessWidget {
  const AddToCartBar({
    super.key,
    required this.totalPrice,
    required this.quantity,
    required this.onAddToCart,
    this.onBuyNow,
    this.isLoading = false,
    this.enabled = true,
  });

  final double totalPrice;
  final int quantity;
  final VoidCallback onAddToCart;
  final VoidCallback? onBuyNow;
  final bool isLoading;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final bool canTap = enabled && !isLoading && quantity > 0;

    return Material(
      color: Colors.white,
      elevation: 14,
      shadowColor: Colors.black.withValues(alpha: 0.12),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 11, 16, 12),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '$quantity item${quantity == 1 ? '' : 's'}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '₹${totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              if (onBuyNow != null) ...<Widget>[
                OutlinedButton(
                  onPressed: canTap ? onBuyNow : null,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(92, 49),
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'BUY NOW',
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900),
                  ),
                ),
                const SizedBox(width: 9),
              ],
              FilledButton.icon(
                onPressed: canTap ? onAddToCart : null,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(126, 49),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon:
                    isLoading
                        ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Icon(Icons.shopping_bag_rounded, size: 18),
                label: Text(
                  isLoading ? 'ADDING' : 'ADD',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
