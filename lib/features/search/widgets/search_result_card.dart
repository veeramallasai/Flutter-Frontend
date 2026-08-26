import 'package:flutter/material.dart';

class SearchResultCard extends StatelessWidget {
  const SearchResultCard({
    super.key,
    required this.productName,
    required this.child,
  });

  final String productName;
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      Semantics(button: true, label: '$productName product', child: child);
}
