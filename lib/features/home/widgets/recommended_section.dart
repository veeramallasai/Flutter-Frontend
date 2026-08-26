import 'package:flutter/material.dart';

class RecommendedSection extends StatelessWidget {
  const RecommendedSection({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
    children: <Widget>[
      for (int index = 0; index < children.length; index++) ...<Widget>[
        children[index],
        if (index != children.length - 1) const SizedBox(height: 28),
      ],
    ],
  );
}
