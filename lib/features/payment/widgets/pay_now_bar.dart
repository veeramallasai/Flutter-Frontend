import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class PayNowBar extends StatelessWidget {
  const PayNowBar({
    super.key,
    required this.amount,
    required this.isCashOnDelivery,
    required this.onPressed,
    this.isProcessing = false,
    this.enabled = true,
  });

  final double amount;
  final bool isCashOnDelivery;
  final VoidCallback onPressed;
  final bool isProcessing;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final bool canPress = enabled && !isProcessing;

    return Material(
      color: Colors.white,
      elevation: 12,
      shadowColor: const Color(0x22000000),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      isCashOnDelivery ? 'Amount to pay' : 'Total payable',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '₹${amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: <Widget>[
                        const Icon(
                          Icons.lock_rounded,
                          color: AppColors.primary,
                          size: 11,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            isCashOnDelivery
                                ? 'Pay when delivered'
                                : 'Secure payment',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              SizedBox(
                height: 54,
                child: FilledButton(
                  onPressed: canPress ? onPressed : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.border,
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child:
                      isProcessing
                          ? const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.4,
                                ),
                              ),
                              SizedBox(width: 9),
                              Text(
                                'PROCESSING...',
                                style: TextStyle(fontWeight: FontWeight.w900),
                              ),
                            ],
                          )
                          : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                isCashOnDelivery ? 'PLACE ORDER' : 'PAY NOW',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(width: 7),
                              const Icon(Icons.arrow_forward_rounded, size: 19),
                            ],
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
