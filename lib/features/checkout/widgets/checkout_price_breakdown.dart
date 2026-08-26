import 'package:flutter/material.dart';

class CheckoutPriceBreakdown extends StatelessWidget {
  const CheckoutPriceBreakdown({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      Semantics(container: true, label: 'Checkout price details', child: child);
}
