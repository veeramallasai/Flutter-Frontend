import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import 'quantity_selector.dart';

class RetailQuantitySelector extends StatelessWidget {
  const RetailQuantitySelector({
    super.key,
    required this.quantity,
    required this.onChanged,
    this.maximumQuantity = 20,
    this.unit = 'unit',
    this.unitPrice,
  });

  final int quantity;
  final int maximumQuantity;
  final String unit;
  final double? unitPrice;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Home Quantity',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  unitPrice == null
                      ? '$quantity × $unit'
                      : '$quantity × $unit  •  ₹${(unitPrice! * quantity).toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          QuantitySelector(
            quantity: quantity,
            maximum: maximumQuantity,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
