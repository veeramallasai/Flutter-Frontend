import 'package:flutter/material.dart';

class PremiumCategoryCard extends StatelessWidget {
  const PremiumCategoryCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Semantics(button: true, child: child);
}
