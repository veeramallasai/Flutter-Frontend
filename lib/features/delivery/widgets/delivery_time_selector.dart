import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class DeliveryTimeSelector extends StatelessWidget {
  const DeliveryTimeSelector({
    super.key,
    required this.times,
    required this.selectedTime,
    required this.onChanged,
  });

  final List<String> times;
  final String selectedTime;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: times
          .map((String time) {
            final bool selected = time == selectedTime;
            return ChoiceChip(
              label: Text(time),
              selected: selected,
              showCheckmark: false,
              onSelected: (_) => onChanged(time),
              selectedColor: const Color(0xFFE8F5E9),
              backgroundColor: Colors.white,
              side: BorderSide(
                color: selected ? AppColors.primary : AppColors.border,
              ),
              labelStyle: TextStyle(
                color: selected ? AppColors.primary : AppColors.textSecondary,
                fontSize: 9,
                fontWeight: FontWeight.w800,
              ),
            );
          })
          .toList(growable: false),
    );
  }
}
