import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class RetryWidget extends StatelessWidget {
  const RetryWidget({
    super.key,
    required this.onRetry,
    this.message = 'Something went wrong. Please try again.',
    this.compact = false,
  });

  final VoidCallback onRetry;
  final String message;
  final bool compact;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: EdgeInsets.all(compact ? 12 : 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.refresh_rounded, color: AppColors.primary, size: compact ? 34 : 52),
              const SizedBox(height: 10),
              Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary, height: 1.4, fontWeight: FontWeight.w600)),
              const SizedBox(height: 14),
              FilledButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh_rounded), label: const Text('TRY AGAIN')),
            ],
          ),
        ),
      );
}
