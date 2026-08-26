import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class NotificationToggle extends StatelessWidget {
  const NotificationToggle({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => SwitchListTile(
    value: value,
    onChanged: onChanged,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
    secondary: Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(icon, color: AppColors.primary, size: 21),
    ),
    title: Text(
      title,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 11.5,
        fontWeight: FontWeight.w900,
      ),
    ),
    subtitle: Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Text(
        subtitle,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 9,
          height: 1.35,
        ),
      ),
    ),
  );
}
