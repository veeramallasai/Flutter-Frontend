import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import 'quantity_selector.dart';

class ShopOwnerBulkSelector extends StatelessWidget {
  const ShopOwnerBulkSelector({
    super.key,
    required this.selectedPackSize,
    required this.packCount,
    required this.onPackSizeChanged,
    required this.onPackCountChanged,
    this.packSizes = const <int>[10, 25, 50, 100],
    this.unit = 'kg',
    this.maximumPacks = 50,
  });

  final List<int> packSizes;
  final int selectedPackSize;
  final int packCount;
  final int maximumPacks;
  final String unit;
  final ValueChanged<int> onPackSizeChanged;
  final ValueChanged<int> onPackCountChanged;

  int get totalQuantity => selectedPackSize * packCount;

  @override
  Widget build(BuildContext context) {
    final List<int> availableSizes = packSizes
        .where((int size) => size > 0)
        .toSet()
        .toList(growable: false);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5FAF7),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD6EBDD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Row(
            children: <Widget>[
              Icon(Icons.storefront_rounded, color: AppColors.primary, size: 20),
              SizedBox(width: 7),
              Text(
                'Shop Owner Bulk Order',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          const Text(
            'Choose pack size',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: availableSizes.map((int size) {
              final bool selected = size == selectedPackSize;
              return ChoiceChip(
                label: Text('$size $unit'),
                selected: selected,
                onSelected: (_) => onPackSizeChanged(size),
                showCheckmark: false,
                selectedColor: const Color(0xFFE4F6EB),
                backgroundColor: Colors.white,
                side: BorderSide(
                  color: selected ? AppColors.primary : AppColors.border,
                ),
                labelStyle: TextStyle(
                  color: selected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              );
            }).toList(growable: false),
          ),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Number of packs',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Total: $totalQuantity $unit',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              QuantitySelector(
                quantity: packCount,
                maximum: maximumPacks,
                onChanged: onPackCountChanged,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
