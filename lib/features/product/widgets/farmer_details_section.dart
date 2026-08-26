import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/farmer_model.dart';
import 'farmer_rating_widget.dart';

class FarmerDetailsSection extends StatelessWidget {
  const FarmerDetailsSection({
    super.key,
    required this.farmer,
    this.onViewProfile,
  });

  final FarmerModel farmer;
  final VoidCallback? onViewProfile;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            radius: 31,
            backgroundColor: const Color(0xFFE8F5E9),
            backgroundImage:
                farmer.imageUrl.startsWith('http')
                    ? NetworkImage(farmer.imageUrl)
                    : null,
            child:
                farmer.imageUrl.isEmpty
                    ? const Icon(
                      Icons.agriculture_rounded,
                      color: AppColors.primary,
                      size: 31,
                    )
                    : null,
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        farmer.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    if (farmer.isVerified) ...<Widget>[
                      const SizedBox(width: 5),
                      const Icon(
                        Icons.verified_rounded,
                        color: AppColors.primary,
                        size: 17,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  farmer.farmName,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                FarmerRatingWidget(
                  rating: farmer.rating,
                  reviewCount: farmer.reviewCount,
                ),
                if (farmer.location.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 6),
                  Text(
                    farmer.location,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onViewProfile != null)
            IconButton(
              tooltip: 'View farmer',
              onPressed: onViewProfile,
              icon: const Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.primary,
                size: 18,
              ),
            ),
        ],
      ),
    );
  }
}
