import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farm_to_home_app/core/auth/backend_auth.dart';
import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../core/theme/app_colors.dart';
import 'widgets/language_selector.dart';
import 'widgets/notification_toggle.dart';
import 'widgets/theme_selector.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _orderUpdates = true;
  bool _offers = true;
  String _language = 'English';
  String _theme = 'fresh';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final User? user = BackendAuth.instance.currentUser;
    if (user != null) {
      try {
        final DocumentSnapshot<Map<String, dynamic>> snapshot =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();
        final Map<String, dynamic> data =
            snapshot.data() ?? <String, dynamic>{};
        _orderUpdates = data['orderNotifications'] != false;
        _offers = data['offerNotifications'] != false;
        _language = (data['language'] ?? 'English').toString();
        _theme = (data['appTheme'] ?? 'fresh').toString();
      } catch (_) {
        // Local defaults keep settings available if sync is temporarily unavailable.
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save(Map<String, dynamic> values) async {
    final User? user = BackendAuth.instance.currentUser;
    if (user == null) return;
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
      <String, dynamic>{...values, 'updatedAt': FieldValue.serverTimestamp()},
      SetOptions(merge: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Settings')),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 32),
                children: <Widget>[
                  const _SettingsHero(),
                  const SizedBox(height: 20),
                  const _SectionTitle('Notifications'),
                  _SettingsCard(
                    children: <Widget>[
                      NotificationToggle(
                        icon: Icons.notifications_active_rounded,
                        title: 'Order updates',
                        subtitle: 'Packing, delivery and payment status',
                        value: _orderUpdates,
                        onChanged: (bool value) {
                          setState(() => _orderUpdates = value);
                          _save(<String, dynamic>{'orderNotifications': value});
                        },
                      ),
                      const Divider(height: 1),
                      NotificationToggle(
                        icon: Icons.local_offer_rounded,
                        title: 'Offers & fresh deals',
                        subtitle: 'Seasonal arrivals and member savings',
                        value: _offers,
                        onChanged: (bool value) {
                          setState(() => _offers = value);
                          _save(<String, dynamic>{'offerNotifications': value});
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const _SectionTitle('App accent'),
                  _SettingsCard(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(13),
                        child: ThemeSelector(
                          selected: _theme,
                          onChanged: (String value) {
                            setState(() => _theme = value);
                            _save(<String, dynamic>{'appTheme': value});
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const _SectionTitle('Language preference'),
                  _SettingsCard(
                    children: <Widget>[
                      LanguageSelector(
                        selected: _language,
                        onChanged: (String value) {
                          setState(() => _language = value);
                          _save(<String, dynamic>{'language': value});
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const _SectionTitle('Privacy & support'),
                  _SettingsCard(
                    children: <Widget>[
                      _SettingsLink(
                        icon: Icons.verified_user_rounded,
                        title: 'Privacy & security',
                        onTap:
                            () =>
                                Navigator.pushNamed(context, AppRoutes.privacy),
                      ),
                      const Divider(height: 1),
                      _SettingsLink(
                        icon: Icons.description_outlined,
                        title: 'Terms of service',
                        onTap:
                            () => Navigator.pushNamed(context, AppRoutes.terms),
                      ),
                      const Divider(height: 1),
                      _SettingsLink(
                        icon: Icons.support_agent_rounded,
                        title: 'Priority support',
                        onTap:
                            () =>
                                Navigator.pushNamed(context, AppRoutes.support),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const _SettingsCard(
                    children: <Widget>[
                      ListTile(
                        leading: Icon(
                          Icons.eco_rounded,
                          color: AppColors.primary,
                        ),
                        title: Text(
                          'Farm To Home',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                        subtitle: Text('Premium customer app • Version 1.0.0'),
                      ),
                    ],
                  ),
                ],
              ),
    );
  }
}

class _SettingsHero extends StatelessWidget {
  const _SettingsHero();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: <Color>[Color(0xFF1B5E20), Color(0xFF2E7D32)],
      ),
      borderRadius: BorderRadius.circular(24),
    ),
    child: const Row(
      children: <Widget>[
        Icon(Icons.tune_rounded, color: Color(0xFFFFB300), size: 38),
        SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Make it yours',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Preferences sync securely with your account.',
                style: TextStyle(color: Color(0xFFC9E7D6), fontSize: 9.5),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _SettingsLink extends StatelessWidget {
  const _SettingsLink({
    required this.icon,
    required this.title,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    onTap: onTap,
    leading: Icon(icon, color: AppColors.primary),
    title: Text(
      title,
      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900),
    ),
    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: children),
    );
  }
}
