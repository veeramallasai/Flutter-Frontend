import 'package:farm_to_home_app/core/auth/backend_auth.dart';
import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../core/theme/app_colors.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = BackendAuth.instance.currentUser;
    final bool emailVerified = user?.emailVerified == true;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Privacy & Security')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 32),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: <Color>[Color(0xFF092F22), Color(0xFF116E48)],
              ),
              borderRadius: BorderRadius.circular(26),
            ),
            child: Row(
              children: <Widget>[
                const Icon(
                  Icons.shield_rounded,
                  color: Color(0xFFFFB300),
                  size: 45,
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'Your account is protected',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        emailVerified
                            ? 'Verified email • Securely authenticated'
                            : 'Secure authentication',
                        style: const TextStyle(
                          color: Color(0xFFC9E7D6),
                          fontSize: 9.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const _PrivacyCard(
            icon: Icons.lock_rounded,
            title: 'Secure authentication',
            text:
                'Your password and sign-in credentials are handled securely through our encrypted backend authentication.',
          ),
          const _PrivacyCard(
            icon: Icons.location_on_rounded,
            title: 'Location information',
            text:
                'Delivery addresses and location are used only to fulfil orders and improve delivery accuracy.',
          ),
          const _PrivacyCard(
            icon: Icons.payments_rounded,
            title: 'Payment protection',
            text:
                'Payment status and transaction references are stored for order support. Card credentials are never stored by this app.',
          ),
          const _PrivacyCard(
            icon: Icons.manage_accounts_rounded,
            title: 'Your control',
            text:
                'You can edit profile details, manage addresses, control notifications and contact support at any time.',
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.terms),
            icon: const Icon(Icons.description_outlined),
            label: const Text('VIEW TERMS OF SERVICE'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrivacyCard extends StatelessWidget {
  const _PrivacyCard({
    required this.icon,
    required this.title,
    required this.text,
  });
  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 11),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.border),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                text,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 9.5,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
