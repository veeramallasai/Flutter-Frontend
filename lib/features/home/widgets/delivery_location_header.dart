import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class DeliveryLocationHeader extends StatelessWidget {
  const DeliveryLocationHeader({
    super.key,
    required this.onTap,
    this.location = 'Select delivery location',
  });

  final VoidCallback onTap;
  final String location;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(10),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(
            Icons.location_on_rounded,
            color: AppColors.primary,
            size: 16,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              location,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.textSecondary,
            size: 18,
          ),
        ],
      ),
    ),
  );
}
