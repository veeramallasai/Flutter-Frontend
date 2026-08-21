import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import 'delivery_location_header.dart';

class PremiumHomeAppBar extends StatelessWidget {
  const PremiumHomeAppBar({
    super.key,
    this.child,
    this.userName = 'Fresh Shopper',
    this.onLocationTap,
    this.onNotificationsTap,
    this.onProfileTap,
  });

  final Widget? child;
  final String userName;
  final VoidCallback? onLocationTap;
  final VoidCallback? onNotificationsTap;
  final VoidCallback? onProfileTap;

  @override
  Widget build(BuildContext context) {
    if (child != null) return child!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: <BoxShadow>[BoxShadow(color: Color(0x0A000000), blurRadius: 18, offset: Offset(0, 6))],
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: <Color>[Color(0xFF08733D), Color(0xFF19A75E)]),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.eco_rounded, color: Colors.white, size: 27),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Hi, $userName 👋',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 16.5, fontWeight: FontWeight.w900),
                ),
                DeliveryLocationHeader(onTap: onLocationTap ?? () {}),
              ],
            ),
          ),
          IconButton(onPressed: onNotificationsTap, icon: const Icon(Icons.notifications_none_rounded)),
          IconButton(
            onPressed: onProfileTap,
            style: IconButton.styleFrom(backgroundColor: const Color(0xFFE9F7EF)),
            icon: const Icon(Icons.person_outline_rounded, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
