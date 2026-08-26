import 'package:flutter/material.dart';

class CheckoutCouponSection extends StatelessWidget {
  const CheckoutCouponSection({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      Semantics(container: true, label: 'Coupon and savings', child: child);
}
