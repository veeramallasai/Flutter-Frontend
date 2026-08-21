import 'package:flutter/material.dart';

class CheckoutDeliverySection extends StatelessWidget {
  const CheckoutDeliverySection({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Semantics(
        container: true,
        label: 'Delivery details',
        child: child,
      );
}
