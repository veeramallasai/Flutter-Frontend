import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class ProductReview {
  const ProductReview({
    required this.customerName,
    required this.comment,
    required this.rating,
    this.dateText = '',
    this.verifiedPurchase = true,
  });

  final String customerName;
  final String comment;
  final double rating;
  final String dateText;
  final bool verifiedPurchase;
}

class ProductReviews extends StatelessWidget {
  const ProductReviews({
    super.key,
    required this.rating,
    required this.reviewCount,
    this.reviews = const <ProductReview>[],
    this.onViewAll,
  });

  final double rating;
  final int reviewCount;
  final List<ProductReview> reviews;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    final List<ProductReview> visibleReviews = reviews
        .take(3)
        .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            const Expanded(
              child: Text(
                'Customer Reviews',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            if (onViewAll != null)
              TextButton(
                onPressed: onViewAll,
                child: const Text(
                  'VIEW ALL',
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E6),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: <Widget>[
              Text(
                rating.toStringAsFixed(1),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _RatingStars(rating: rating),
                    const SizedBox(height: 4),
                    Text(
                      'Based on $reviewCount reviews',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (visibleReviews.isEmpty) ...<Widget>[
          const SizedBox(height: 10),
          const Text(
            'No written reviews yet.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ] else
          ...visibleReviews.map(
            (ProductReview review) => _ReviewTile(review: review),
          ),
      ],
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.review});

  final ProductReview review;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              CircleAvatar(
                radius: 17,
                backgroundColor: const Color(0xFFE8F5E9),
                child: Text(
                  review.customerName.trim().isEmpty
                      ? 'C'
                      : review.customerName.trim()[0].toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      review.customerName.trim().isEmpty
                          ? 'Customer'
                          : review.customerName,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    _RatingStars(rating: review.rating, size: 13),
                  ],
                ),
              ),
              if (review.dateText.isNotEmpty)
                Text(
                  review.dateText,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            review.comment,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
              height: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (review.verifiedPurchase) ...<Widget>[
            const SizedBox(height: 7),
            const Row(
              children: <Widget>[
                Icon(
                  Icons.verified_rounded,
                  color: AppColors.primary,
                  size: 14,
                ),
                SizedBox(width: 4),
                Text(
                  'Verified purchase',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _RatingStars extends StatelessWidget {
  const _RatingStars({required this.rating, this.size = 17});

  final double rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(5, (int index) {
        return Icon(
          index < rating.round()
              ? Icons.star_rounded
              : Icons.star_border_rounded,
          color: const Color(0xFFFFB300),
          size: size,
        );
      }),
    );
  }
}
