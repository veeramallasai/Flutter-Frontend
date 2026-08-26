import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class FarmerRatingWidget extends StatelessWidget {
  const FarmerRatingWidget({
    super.key,
    required this.rating,
    required this.reviewCount,
  });

  final double rating;
  final int reviewCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ...List<Widget>.generate(5, (int index) {
          return Icon(
            index < rating.round()
                ? Icons.star_rounded
                : Icons.star_border_rounded,
            color: const Color(0xFFFFB300),
            size: 15,
          );
        }),
        const SizedBox(width: 6),
        Text(
          '${rating.toStringAsFixed(1)} ($reviewCount)',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
