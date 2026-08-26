import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class ProfileShoppingModeCard extends StatelessWidget {
  const ProfileShoppingModeCard({
    super.key,
    required this.mode,
    required this.onChanged,
    this.loading = false,
  });

  final String mode;
  final ValueChanged<String> onChanged;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final bool home = mode != 'shop';
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFFFFFFFF), Color(0xFFE8F5E9)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFDDEBE3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Row(
            children: <Widget>[
              Icon(Icons.swap_horiz_rounded, color: AppColors.primary),
              SizedBox(width: 9),
              Expanded(
                child: Text(
                  'Shopping mode',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                'CHANGE ANYTIME',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 7,
                  letterSpacing: 0.6,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: _ModeButton(
                  icon: Icons.home_rounded,
                  title: 'Home',
                  subtitle: 'Retail packs',
                  selected: home,
                  enabled: !loading,
                  onTap: () => onChanged('home'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ModeButton(
                  icon: Icons.storefront_rounded,
                  title: 'Shop Owner',
                  subtitle: 'Bulk packs',
                  selected: !home,
                  enabled: !loading,
                  onTap: () => onChanged('shop'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: enabled ? onTap : null,
    borderRadius: BorderRadius.circular(16),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF1B5E20) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected ? const Color(0xFF1B5E20) : const Color(0xFFDDE8E1),
        ),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            icon,
            color: selected ? const Color(0xFFFFB300) : AppColors.primary,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(
                    color: selected ? Colors.white : AppColors.textPrimary,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color:
                        selected
                            ? const Color(0xFFC9E7D6)
                            : AppColors.textSecondary,
                    fontSize: 7.5,
                  ),
                ),
              ],
            ),
          ),
          if (selected)
            const Icon(
              Icons.check_circle_rounded,
              color: Colors.white,
              size: 17,
            ),
        ],
      ),
    ),
  );
}
