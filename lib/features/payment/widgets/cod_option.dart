import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class CodOption extends StatelessWidget {
  const CodOption({
    super.key,
    required this.selected,
    required this.onTap,
    this.enabled = true,
  });

  final bool selected;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: Material(
        color: selected ? const Color(0xFFE8F5E9) : Colors.white,
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
                    color:
                        selected ? AppColors.primary : const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    Icons.payments_outlined,
                    color: selected ? Colors.white : AppColors.primary,
                  ),
                ),
                const SizedBox(width: 13),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Flexible(
                            child: Text(
                              'Cash on Delivery',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          _AvailableBadge(),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Pay when your fresh products arrive',
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

class _AvailableBadge extends StatelessWidget {
  const _AvailableBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(30),
      ),
      child: const Text(
        'AVAILABLE',
        style: TextStyle(
          color: AppColors.primary,
          fontSize: 7,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
