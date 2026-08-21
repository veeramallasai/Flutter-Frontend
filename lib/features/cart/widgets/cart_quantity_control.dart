import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class CartQuantityControl extends StatelessWidget {
  const CartQuantityControl({
    super.key,
    required this.quantity,
    required this.onDecrease,
    required this.onIncrease,
    this.enabled = true,
  });

  final int quantity;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      decoration: BoxDecoration(
        color: const Color(0xFFEAF7EF),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: const Color(0xFFD2E9DA)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _Button(
            icon: quantity <= 1 ? Icons.delete_outline_rounded : Icons.remove_rounded,
            onPressed: enabled ? onDecrease : null,
          ),
          SizedBox(
            width: 31,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          _Button(
            icon: Icons.add_rounded,
            onPressed: enabled ? onIncrease : null,
          ),
        ],
      ),
    );
  }
}

class _Button extends StatelessWidget {
  const _Button({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: IconButton(
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        icon: Icon(icon, color: AppColors.primary, size: 17),
      ),
    );
  }
}
