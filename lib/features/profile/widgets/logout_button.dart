import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key, required this.onPressed, this.loading = false});

  final VoidCallback onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
        onPressed: loading ? null : onPressed,
        icon: loading
            ? const SizedBox(
                width: 17,
                height: 17,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.logout_rounded),
        label: const Text('LOG OUT SECURELY'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: const BorderSide(color: Color(0xFFFFCFCF)),
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
        ),
      );
}
