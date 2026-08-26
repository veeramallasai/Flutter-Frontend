import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class ThemeSelector extends StatelessWidget {
  const ThemeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => Row(
    children: <Widget>[
      Expanded(
        child: _ThemeOption(
          value: 'fresh',
          title: 'Fresh',
          colors: const <Color>[Color(0xFFFFFFFF), Color(0xFFE8F5E9)],
          selected: selected == 'fresh',
          onTap: onChanged,
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: _ThemeOption(
          value: 'emerald',
          title: 'Emerald',
          colors: const <Color>[Color(0xFF1B5E20), Color(0xFF2E7D32)],
          selected: selected == 'emerald',
          onTap: onChanged,
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: _ThemeOption(
          value: 'cream',
          title: 'Cream',
          colors: const <Color>[Color(0xFFFFF8E8), Color(0xFFFFE3A0)],
          selected: selected == 'cream',
          onTap: onChanged,
        ),
      ),
    ],
  );
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.value,
    required this.title,
    required this.colors,
    required this.selected,
    required this.onTap,
  });

  final String value;
  final String title;
  final List<Color> colors;
  final bool selected;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => onTap(value),
    borderRadius: BorderRadius.circular(16),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.border,
          width: selected ? 1.7 : 1,
        ),
      ),
      child: Column(
        children: <Widget>[
          Container(
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: colors),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Icon(
                  selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                  color: selected ? AppColors.primary : Colors.white70,
                  size: 17,
                ),
              ),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            title,
            style: TextStyle(
              color: selected ? AppColors.primary : AppColors.textPrimary,
              fontSize: 9,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    ),
  );
}
