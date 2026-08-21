import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CircleAvatar(radius: 36, backgroundColor: const Color(0xFFEAF7EF), child: Icon(icon, color: AppColors.primary, size: 34)),
                const SizedBox(height: 16),
                Text(title, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textPrimary, fontSize: 19, fontWeight: FontWeight.w900)),
                const SizedBox(height: 7),
                Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary, height: 1.45)),
                if (actionLabel != null && onAction != null) ...<Widget>[
                  const SizedBox(height: 18),
                  FilledButton(onPressed: onAction, child: Text(actionLabel!, style: const TextStyle(fontWeight: FontWeight.w900))),
                ],
              ],
            ),
          ),
        ),
      );
}
