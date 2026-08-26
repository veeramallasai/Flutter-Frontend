import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class QuickDeliveryCard extends StatelessWidget {
  const QuickDeliveryCard({
    super.key,
    required this.isSelected,
    required this.onTap,
    this.fee = 49,
    this.estimatedTime = '30–60 minutes',
  });

  final bool isSelected;
  final VoidCallback onTap;
  final double fee;
  final String estimatedTime;

  @override
  Widget build(BuildContext context) {
    return _DeliveryCard(
      icon: Icons.bolt_rounded,
      title: 'Quick Delivery',
      subtitle: 'Fresh products delivered in $estimatedTime',
      trailing: fee <= 0 ? 'FREE' : '₹${fee.toStringAsFixed(0)}',
      isSelected: isSelected,
      onTap: onTap,
    );
  }
}

class _DeliveryCard extends StatelessWidget {
  const _DeliveryCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.isSelected,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final String trailing;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F5E9) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          children: <Widget>[
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 8.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              trailing,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
