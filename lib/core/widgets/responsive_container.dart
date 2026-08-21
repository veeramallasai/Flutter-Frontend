import 'package:flutter/material.dart';

class ResponsiveContainer extends StatelessWidget {
  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth = 1100,
    this.mobilePadding = 16,
    this.desktopPadding = 32,
  });
  final Widget child;
  final double maxWidth;
  final double mobilePadding;
  final double desktopPadding;

  @override
  Widget build(BuildContext context) {
    final bool desktop = MediaQuery.sizeOf(context).width >= 900;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: desktop ? desktopPadding : mobilePadding),
          child: child,
        ),
      ),
    );
  }
}
