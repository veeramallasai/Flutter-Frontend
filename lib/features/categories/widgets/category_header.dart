import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class CategoryHeader extends StatelessWidget {
  const CategoryHeader({
    super.key,
    required this.title,
    this.subtitle = 'Fresh picks selected for you',
    this.imageUrl = '',
    this.onBack,
    this.onSearch,
    this.onCart,
    this.cartCount = 0,
  });

  final String title;
  final String subtitle;
  final String imageUrl;
  final VoidCallback? onBack;
  final VoidCallback? onSearch;
  final VoidCallback? onCart;
  final int cartCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 22),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[Color(0xFF064E2A), AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                _HeaderButton(icon: Icons.arrow_back_rounded, onTap: onBack),
                const Spacer(),
                _HeaderButton(icon: Icons.search_rounded, onTap: onSearch),
                const SizedBox(width: 9),
                Stack(
                  clipBehavior: Clip.none,
                  children: <Widget>[
                    _HeaderButton(
                      icon: Icons.shopping_bag_outlined,
                      onTap: onCart,
                    ),
                    if (cartCount > 0)
                      Positioned(
                        right: -4,
                        top: -5,
                        child: Container(
                          constraints: const BoxConstraints(minWidth: 20),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          decoration: const BoxDecoration(
                            color: AppColors.secondary,
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          child: Text(
                            cartCount > 99 ? '99+' : '$cartCount',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF2D2400),
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 22),
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          height: 1.1,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Color(0xFFD6F3E3),
                          fontSize: 12,
                          height: 1.4,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (imageUrl.trim().isNotEmpty) ...<Widget>[
                  const SizedBox(width: 18),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: imageUrl.startsWith('assets/')
                        ? Image.asset(
                            imageUrl,
                            width: 92,
                            height: 92,
                            fit: BoxFit.cover,
                          )
                        : Image.network(
                            imageUrl,
                            width: 92,
                            height: 92,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const SizedBox(width: 92, height: 92),
                          ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0x26FFFFFF),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(11),
          child: Icon(icon, color: Colors.white, size: 21),
        ),
      ),
    );
  }
}
