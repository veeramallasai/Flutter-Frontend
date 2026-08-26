import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class CurrentLocationButton extends StatelessWidget {
  const CurrentLocationButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        side: const BorderSide(color: AppColors.primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
      ),
      icon:
          isLoading
              ? const SizedBox(
                width: 17,
                height: 17,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
              : const Icon(Icons.my_location_rounded),
      label: Text(isLoading ? 'GETTING LOCATION...' : 'USE CURRENT LOCATION'),
    );
  }
}
