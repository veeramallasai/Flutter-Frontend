import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class PremiumAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PremiumAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const <Widget>[],
    this.onBack,
    this.showBack = true,
  });

  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final VoidCallback? onBack;
  final bool showBack;

  @override
  Size get preferredSize => Size.fromHeight(subtitle == null ? 64 : 76);

  @override
  Widget build(BuildContext context) => AppBar(
    toolbarHeight: preferredSize.height,
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.white,
    elevation: 0,
    shadowColor: const Color(0x12000000),
    leading:
        showBack
            ? IconButton(
              onPressed: onBack ?? () => Navigator.maybePop(context),
              icon: const Icon(Icons.arrow_back_rounded),
            )
            : null,
    automaticallyImplyLeading: false,
    title: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        if (subtitle != null)
          Text(
            subtitle!,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    ),
    actions: actions,
  );
}
