import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.name,
    required this.email,
    required this.phone,
    required this.photoUrl,
    required this.shoppingMode,
    required this.onEdit,
  });

  final String name;
  final String email;
  final String phone;
  final String photoUrl;
  final String shoppingMode;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final String contact = email.trim().isNotEmpty ? email : phone;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      padding: const EdgeInsets.fromLTRB(20, 17, 20, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFF1B5E20),
            Color(0xFF2E7D32),
            Color(0xFF2E7D32),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x32064325),
            blurRadius: 30,
            offset: Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              const Expanded(
                child: Text(
                  'MY FRESH CLUB',
                  style: TextStyle(
                    color: Color(0xFFCCF4DE),
                    fontSize: 10,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              _ModePill(label: shoppingMode),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: <Widget>[
              _Avatar(photoUrl: photoUrl),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      contact,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFD9F4E5),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (email.isNotEmpty && phone.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 3),
                      Text(
                        phone,
                        style: const TextStyle(
                          color: Color(0xFFBFE8D0),
                          fontSize: 9.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton.filledTonal(
                tooltip: 'Edit profile',
                onPressed: onEdit,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.14),
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.edit_rounded, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 19),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.11),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Row(
              children: <Widget>[
                Expanded(
                  child: _TrustStat(
                    icon: Icons.eco_rounded,
                    value: 'Farm fresh',
                    label: 'QUALITY',
                  ),
                ),
                _Divider(),
                Expanded(
                  child: _TrustStat(
                    icon: Icons.shield_rounded,
                    value: 'Protected',
                    label: 'PAYMENTS',
                  ),
                ),
                _Divider(),
                Expanded(
                  child: _TrustStat(
                    icon: Icons.bolt_rounded,
                    value: 'Priority',
                    label: 'DELIVERY',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.photoUrl});
  final String photoUrl;

  @override
  Widget build(BuildContext context) => Container(
    width: 76,
    height: 76,
    padding: const EdgeInsets.all(3),
    decoration: const BoxDecoration(
      color: Colors.white,
      shape: BoxShape.circle,
    ),
    child: ClipOval(
      child:
          photoUrl.startsWith('http')
              ? Image.network(photoUrl, fit: BoxFit.cover, errorBuilder: _error)
              : _fallback(),
    ),
  );

  Widget _error(BuildContext context, Object error, StackTrace? stackTrace) =>
      _fallback();

  Widget _fallback() => const ColoredBox(
    color: Color(0xFFE8F5E9),
    child: Icon(Icons.person_rounded, color: AppColors.primary, size: 40),
  );
}

class _ModePill extends StatelessWidget {
  const _ModePill({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const Icon(Icons.verified_rounded, color: Color(0xFFFFB300), size: 15),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}

class _TrustStat extends StatelessWidget {
  const _TrustStat({
    required this.icon,
    required this.value,
    required this.label,
  });
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Column(
    children: <Widget>[
      Icon(icon, color: const Color(0xFFFFB300), size: 18),
      const SizedBox(height: 5),
      Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9.5,
          fontWeight: FontWeight.w900,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        label,
        style: const TextStyle(
          color: Color(0xFFBCE4CD),
          fontSize: 7,
          letterSpacing: 0.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 34, color: const Color(0x44FFFFFF));
}
