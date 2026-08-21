import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class PremiumFloatingCartButton extends StatelessWidget {
  const PremiumFloatingCartButton({
    super.key,
    required this.count,
    required this.total,
    required this.onTap,
    this.label = 'View Cart',
  });

  final int count;
  final double total;
  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(19),
          child: Container(
            height: 58,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: <Color>[Color(0xFF04361F), Color(0xFF0B7A3E)]),
              borderRadius: BorderRadius.circular(19),
              boxShadow: const <BoxShadow>[
                BoxShadow(color: Color(0x36043D24), blurRadius: 22, offset: Offset(0, 10)),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CartBadgeIcon(count: count, color: Colors.white),
                const SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(label, style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w900)),
                    if (count > 0)
                      Text(
                        '$count item${count == 1 ? '' : 's'} • ₹${total.toStringAsFixed(0)}',
                        style: const TextStyle(color: Color(0xFFCFECDD), fontSize: 8.5, fontWeight: FontWeight.w700),
                      ),
                  ],
                ),
                const SizedBox(width: 11),
                const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
              ],
            ),
          ),
        ),
      );
}

class CartBadgeIcon extends StatelessWidget {
  const CartBadgeIcon({super.key, required this.count, this.color = AppColors.textPrimary});
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) => Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Icon(Icons.shopping_bag_rounded, color: color),
          if (count > 0)
            Positioned(
              right: -9,
              top: -9,
              child: Container(
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFF4B400),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Text(
                  count > 99 ? '99+' : '$count',
                  style: const TextStyle(color: Color(0xFF2D2400), fontSize: 7.5, fontWeight: FontWeight.w900),
                ),
              ),
            ),
        ],
      );
}
