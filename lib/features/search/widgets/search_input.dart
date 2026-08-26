import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class PremiumSearchInput extends StatelessWidget {
  const PremiumSearchInput({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
    required this.onFilterTap,
    this.hasFilters = false,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;
  final VoidCallback onFilterTap;
  final bool hasFilters;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: hasFilters ? AppColors.primary : AppColors.border,
      ),
      boxShadow: const <BoxShadow>[
        BoxShadow(
          color: Color(0x0A000000),
          blurRadius: 18,
          offset: Offset(0, 7),
        ),
      ],
    ),
    child: TextField(
      controller: controller,
      autofocus: true,
      textInputAction: TextInputAction.search,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: 'Search vegetables, fruits and dairy',
        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (controller.text.isNotEmpty)
              IconButton(
                onPressed: onClear,
                icon: const Icon(Icons.close_rounded),
              ),
            Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                IconButton(
                  onPressed: onFilterTap,
                  icon: const Icon(Icons.tune_rounded),
                ),
                if (hasFilters)
                  const Positioned(
                    right: 7,
                    top: 7,
                    child: CircleAvatar(
                      radius: 4,
                      backgroundColor: Color(0xFFFFB300),
                    ),
                  ),
              ],
            ),
          ],
        ),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
      ),
    ),
  );
}
