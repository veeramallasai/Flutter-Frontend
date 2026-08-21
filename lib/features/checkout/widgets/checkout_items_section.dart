import 'package:flutter/material.dart';

class CheckoutItemsSection extends StatelessWidget {
  const CheckoutItemsSection({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Semantics(
        container: true,
        label: 'Checkout item',
        child: child,
      );
}
