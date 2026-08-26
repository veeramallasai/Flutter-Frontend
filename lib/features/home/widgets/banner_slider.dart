import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class BannerSlider extends StatelessWidget {
  const BannerSlider({
    super.key,
    required this.child,
    required this.itemCount,
    required this.currentIndex,
    this.indicator,
  });

  final Widget child;
  final int itemCount;
  final int currentIndex;
  final Widget? indicator;

  @override
  Widget build(BuildContext context) => Column(
    children: <Widget>[
      child,
      const SizedBox(height: 11),
      indicator ??
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List<Widget>.generate(itemCount, (int index) {
              final bool active = index == currentIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: active ? 25 : 7,
                height: 7,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : AppColors.border,
                  borderRadius: BorderRadius.circular(20),
                ),
              );
            }),
          ),
    ],
  );
}
