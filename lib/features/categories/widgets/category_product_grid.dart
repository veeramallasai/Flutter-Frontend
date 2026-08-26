import 'package:flutter/material.dart';

/// Responsive grid geometry shared by premium category product collections.
/// Keeps the larger edge-to-edge photography and quantity control from
/// crowding or overflowing on phone, tablet, and desktop widths.
SliverGridDelegate premiumCategoryProductGrid(double width) {
  final int columns =
      width >= 1250
          ? 5
          : width >= 950
          ? 4
          : width >= 650
          ? 3
          : 2;

  return SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: columns,
    crossAxisSpacing: width < 650 ? 10 : 13,
    mainAxisSpacing: width < 650 ? 10 : 13,
    mainAxisExtent: width < 650 ? 318 : 340,
  );
}
