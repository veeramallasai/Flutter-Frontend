import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class PopularSearches extends StatelessWidget {
  const PopularSearches({super.key, required this.onSelected});

  final ValueChanged<String> onSelected;

  static const List<String> _items = <String>[
    'Tomato',
    'Fresh Fruits',
    'Milk',
    'Green Vegetables',
    'Seasonal',
  ];

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Row(
            children: <Widget>[
              Icon(Icons.local_fire_department_rounded, color: Color(0xFFD78900), size: 20),
              SizedBox(width: 7),
              Text('Popular right now', style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _items
                .map((String item) => ActionChip(
                      backgroundColor: const Color(0xFFFFF8E8),
                      side: const BorderSide(color: Color(0xFFF0DDAF)),
                      label: Text(item),
                      onPressed: () => onSelected(item),
                    ))
                .toList(growable: false),
          ),
        ],
      );
}
