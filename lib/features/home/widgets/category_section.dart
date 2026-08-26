import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class CategorySection extends StatelessWidget {
  const CategorySection({
    super.key,
    required this.categories,
    required this.onViewAll,
    this.header,
  });

  final Widget categories;
  final VoidCallback onViewAll;
  final Widget? header;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      header ??
          Row(
            children: <Widget>[
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Shop by category',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Fresh essentials, directly from trusted farms',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(onPressed: onViewAll, child: const Text('View all')),
            ],
          ),
      const SizedBox(height: 16),
      categories,
    ],
  );
}
