import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class CategoryFilterBar extends StatelessWidget {
  const CategoryFilterBar({
    super.key,
    required this.filters,
    required this.selected,
    required this.onSelected,
  });

  final List<String> filters;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Row(
        children: filters
            .map((String filter) {
              final bool active =
                  filter.toLowerCase() == selected.toLowerCase();
              return Padding(
                padding: const EdgeInsets.only(right: 9),
                child: ChoiceChip(
                  label: Text(_label(filter)),
                  selected: active,
                  showCheckmark: false,
                  onSelected: (_) => onSelected(filter),
                  backgroundColor: Colors.white,
                  selectedColor: AppColors.primary,
                  side: BorderSide(
                    color: active ? AppColors.primary : AppColors.border,
                  ),
                  labelStyle: TextStyle(
                    color: active ? Colors.white : AppColors.textPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              );
            })
            .toList(growable: false),
      ),
    );
  }

  String _label(String value) {
    if (value.trim().isEmpty) return 'All';
    final String text = value.trim().replaceAll('_', ' ');
    return '${text[0].toUpperCase()}${text.substring(1)}';
  }
}
