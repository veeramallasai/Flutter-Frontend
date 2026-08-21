import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class ProductUnitSelector extends StatelessWidget {
  const ProductUnitSelector({
    super.key,
    required this.units,
    required this.selectedUnit,
    required this.onChanged,
  });

  final List<String> units;
  final String selectedUnit;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final List<String> availableUnits = units
        .map((String unit) => unit.trim())
        .where((String unit) => unit.isNotEmpty)
        .toSet()
        .toList(growable: false);

    if (availableUnits.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Select Unit',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 9,
          runSpacing: 9,
          children: availableUnits.map((String unit) {
            final bool selected = unit == selectedUnit;
            return ChoiceChip(
              label: Text(unit),
              selected: selected,
              onSelected: (_) => onChanged(unit),
              showCheckmark: false,
              backgroundColor: Colors.white,
              selectedColor: const Color(0xFFE4F6EB),
              side: BorderSide(
                color: selected ? AppColors.primary : AppColors.border,
                width: selected ? 1.4 : 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              labelStyle: TextStyle(
                color: selected
                    ? AppColors.primary
                    : AppColors.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            );
          }).toList(growable: false),
        ),
      ],
    );
  }
}
