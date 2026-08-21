import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class ProductSection extends StatelessWidget {
  const ProductSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.products,
    required this.onViewAll,
    this.header,
  });

  final String title;
  final String subtitle;
  final Widget products;
  final VoidCallback onViewAll;
  final Widget? header;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          header ?? Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 3),
                    Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              TextButton(onPressed: onViewAll, child: const Text('View all')),
            ],
          ),
          const SizedBox(height: 15),
          products,
        ],
      );
}
