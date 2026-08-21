import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class CardOption extends StatelessWidget {
  const CardOption({
    super.key,
    required this.selected,
    required this.onTap,
    this.enabled = true,
    this.badge = 'COMING SOON',
  });

  final bool selected;
  final VoidCallback onTap;
  final bool enabled;
  final String badge;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: Material(
        color: selected ? const Color(0xFFF2FAF5) : Colors.white,
        borderRadius: BorderRadius.circular(21),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(21),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(21),
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.border,
                width: selected ? 1.7 : 1,
              ),
            ),
            child: Row(
              children: <Widget>[
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary
                        : const Color(0xFFEAF7EF),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    Icons.credit_card_rounded,
                    color: selected ? Colors.white : AppColors.primary,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          const Flexible(
                            child: Text(
                              'Credit / Debit Card',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          if (badge.trim().isNotEmpty) ...<Widget>[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF4DA),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                badge,
                                style: const TextStyle(
                                  color: Color(0xFF9B6B08),
                                  fontSize: 7,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Available after secure gateway activation',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: selected ? AppColors.primary : AppColors.border,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
