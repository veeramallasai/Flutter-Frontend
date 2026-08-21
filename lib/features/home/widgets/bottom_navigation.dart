import 'package:flutter/material.dart';

import 'floating_cart_bar.dart';

class PremiumBottomNavigation extends StatelessWidget {
  const PremiumBottomNavigation({
    super.key,
    required this.cartCount,
    required this.onSelected,
    this.selectedIndex = 0,
  });

  final int cartCount;
  final ValueChanged<int> onSelected;
  final int selectedIndex;

  @override
  Widget build(BuildContext context) => NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onSelected,
        destinations: <NavigationDestination>[
          const NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'),
          const NavigationDestination(icon: Icon(Icons.grid_view_outlined), selectedIcon: Icon(Icons.grid_view_rounded), label: 'Categories'),
          NavigationDestination(icon: CartBadgeIcon(count: cartCount), selectedIcon: CartBadgeIcon(count: cartCount), label: 'Cart'),
          const NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long_rounded), label: 'Orders'),
          const NavigationDestination(icon: Icon(Icons.person_outline_rounded), selectedIcon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      );
}
