import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class ProceedCheckoutBar extends StatelessWidget {
  const ProceedCheckoutBar({
    super.key,
    required this.total,
    required this.itemCount,
    required this.onProceed,
    this.isLoading = false,
    this.enabled = true,
  });

  final double total;
  final int itemCount;
  final VoidCallback onProceed;
  final bool isLoading;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFCFEFD),
      elevation: 14,
      shadowColor: Colors.black.withValues(alpha: 0.12),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 11, 16, 12),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '$itemCount item${itemCount == 1 ? '' : 's'}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 8.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '₹${total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: enabled && !isLoading ? onProceed : null,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E20),
                  minimumSize: const Size(190, 54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17),
                  ),
                ),
                icon:
                    isLoading
                        ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Icon(Icons.arrow_forward_rounded, size: 18),
                label: const Text(
                  'CHOOSE DELIVERY',
                  style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
