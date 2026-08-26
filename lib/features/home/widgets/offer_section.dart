import 'package:flutter/material.dart';

class OfferSection extends StatelessWidget {
  const OfferSection({super.key, required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(23),
      child: child,
    ),
  );
}
