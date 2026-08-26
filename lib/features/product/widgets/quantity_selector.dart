import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class QuantitySelector extends StatelessWidget {
  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.onChanged,
    this.minimum = 1,
    this.maximum = 99,
    this.compact = false,
  });

  final int quantity;
  final int minimum;
  final int maximum;
  final bool compact;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final int safeMinimum = minimum < 0 ? 0 : minimum;
    final int safeMaximum = maximum < safeMinimum ? safeMinimum : maximum;
    final int safeQuantity =
        quantity < safeMinimum
            ? safeMinimum
            : quantity > safeMaximum
            ? safeMaximum
            : quantity;
    final double buttonSize = compact ? 30 : 38;

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAF9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD6EBDD)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _QuantityButton(
            icon: Icons.remove_rounded,
            size: buttonSize,
            enabled: safeQuantity > safeMinimum,
            onPressed: () => onChanged(safeQuantity - 1),
          ),
          SizedBox(
            width: compact ? 34 : 44,
            child: Text(
              '$safeQuantity',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: compact ? 11 : 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          _QuantityButton(
            icon: Icons.add_rounded,
            size: buttonSize,
            enabled: safeQuantity < safeMaximum,
            onPressed: () => onChanged(safeQuantity + 1),
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({
    required this.icon,
    required this.size,
    required this.enabled,
    required this.onPressed,
  });

  final IconData icon;
  final double size;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: IconButton(
        onPressed: enabled ? onPressed : null,
        padding: EdgeInsets.zero,
        style: IconButton.styleFrom(
          backgroundColor: enabled ? Colors.white : const Color(0xFFF1F1F1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
          ),
        ),
        icon: Icon(
          icon,
          size: 18,
          color: enabled ? AppColors.primary : AppColors.textSecondary,
        ),
      ),
    );
  }
}
