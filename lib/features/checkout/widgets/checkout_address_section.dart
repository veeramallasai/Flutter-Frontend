import 'package:flutter/material.dart';

class CheckoutAddressSection extends StatelessWidget {
  const CheckoutAddressSection({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      Semantics(container: true, label: 'Delivery address', child: child);
}
