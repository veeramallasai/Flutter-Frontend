import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/order_model.dart';
import '../../data/repositories/order_repository.dart';
import 'widgets/logout_button.dart';
import 'widgets/order_summary_card.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_menu_item.dart';
import 'widgets/profile_shopping_mode_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _savingPassword = false;
  bool _savingMode = false;
  bool _loggingOut = false;
  final OrderRepository _orders = OrderRepository();

  Future<void> _logout() async {
    setState(() => _loggingOut = true);
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (Route<dynamic> route) => false,
    );
  }

  Future<void> _changeShoppingMode(String mode) async {
    if (_savingMode) return;
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    setState(() => _savingMode = true);
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
        <String, dynamic>{
          'shoppingMode': mode == 'shop' ? 'shop' : 'home',
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      if (mounted) _message(mode == 'shop' ? 'Shop Owner mode selected.' : 'Home Shopping mode selected.');
    } catch (error) {
      if (mounted) _message('Unable to change shopping mode.', error: true);
    } finally {
      if (mounted) setState(() => _savingMode = false);
    }
  }

  Widget _orderOverview() {
    return StreamBuilder<List<OrderModel>>(
      stream: _orders.watchCurrentUserOrders(limit: 50),
      builder: (BuildContext context, AsyncSnapshot<List<OrderModel>> snapshot) {
        final List<OrderModel> orders = snapshot.data ?? <OrderModel>[];
        final int active = orders.where((OrderModel order) {
          return !order.isDelivered && !order.isCancelled && !order.isFailed;
        }).length;
        final double savings = orders.fold<double>(
          0,
          (double value, OrderModel order) => value + order.totalSavings,
        );
        return OrderSummaryCard(
          totalOrders: orders.length,
          activeOrders: active,
          totalSavings: savings,
          onTap: () => Navigator.pushNamed(context, AppRoutes.orders),
        );
      },
    );
  }

  Future<void> _setLoginPassword() async {
    final User? user = FirebaseAuth.instance.currentUser;
    final String email = user?.email?.trim() ?? '';
    if (user == null || email.isEmpty) {
      _message('A verified email is required to set a login password.', error: true);
      return;
    }

    final TextEditingController password = TextEditingController();
    final TextEditingController confirm = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final String? value = await showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Set login password'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Use $email with this password on your next login.',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: password,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'New password',
                  prefixIcon: Icon(Icons.lock_outline_rounded),
                ),
                validator: (String? input) {
                  final String text = input ?? '';
                  if (text.length < 8) return 'Use at least 8 characters';
                  if (!RegExp(r'[A-Z]').hasMatch(text) ||
                      !RegExp(r'[a-z]').hasMatch(text) ||
                      !RegExp(r'\d').hasMatch(text)) {
                    return 'Add uppercase, lowercase and a number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: confirm,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm password',
                  prefixIcon: Icon(Icons.verified_user_outlined),
                ),
                validator: (String? input) => input != password.text
                    ? 'Passwords do not match'
                    : null,
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState?.validate() == true) {
                Navigator.pop(dialogContext, password.text);
              }
            },
            child: const Text('SAVE PASSWORD'),
          ),
        ],
      ),
    );
    password.dispose();
    confirm.dispose();
    if (value == null || value.isEmpty) return;
    if (!mounted) return;

    setState(() => _savingPassword = true);
    try {
      final bool alreadyLinked = user.providerData.any(
        (UserInfo info) => info.providerId == EmailAuthProvider.PROVIDER_ID,
      );
      if (alreadyLinked) {
        await user.updatePassword(value);
      } else {
        await user.linkWithCredential(
          EmailAuthProvider.credential(email: email, password: value),
        );
      }
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
        <String, dynamic>{
          'emailLoginEnabled': true,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      if (!mounted) return;
      _message('Email & password login is ready.');
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      _message(
        error.code == 'requires-recent-login'
            ? 'For security, log out and sign in with Google once, then try again.'
            : (error.message ?? 'Unable to set password.'),
        error: true,
      );
    } finally {
      if (mounted) setState(() => _savingPassword = false);
    }
  }

  void _message(String value, {bool error = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(value),
          behavior: SnackBarBehavior.floating,
          backgroundColor: error ? AppColors.error : const Color(0xFF073D24),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String uid = user?.uid ?? '';
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: uid.isEmpty
              ? const Stream<DocumentSnapshot<Map<String, dynamic>>>.empty()
              : FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
          builder: (
            BuildContext context,
            AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot,
          ) {
            final Map<String, dynamic> data =
                snapshot.data?.data() ?? <String, dynamic>{};
            final String name = (data['displayName'] ?? user?.displayName ?? '')
                .toString()
                .trim();
            final String displayName = name.isEmpty ? 'Fresh Shopper' : name;
            final String email = (data['email'] ?? user?.email ?? '').toString();
            final String phone = (data['phoneNumber'] ?? user?.phoneNumber ?? '').toString();
            final String photo = (data['photoUrl'] ?? user?.photoURL ?? '').toString();
            final String rawMode = data['shoppingMode'] == 'shop' ? 'shop' : 'home';
            final String mode = rawMode == 'shop' ? 'Shop Owner' : 'Home Shopping';

            return CustomScrollView(
              slivers: <Widget>[
                SliverToBoxAdapter(
                  child: ProfileHeader(
                    name: displayName,
                    email: email,
                    phone: phone,
                    photoUrl: photo,
                    shoppingMode: mode,
                    onEdit: () => Navigator.pushNamed(context, AppRoutes.editProfile),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(<Widget>[
                      _orderOverview(),
                      const SizedBox(height: 13),
                      ProfileShoppingModeCard(
                        mode: rawMode,
                        loading: _savingMode,
                        onChanged: _changeShoppingMode,
                      ),
                      const SizedBox(height: 20),
                      const _SectionTitle('YOUR FARM TO HOME'),
                      const SizedBox(height: 10),
                      ProfileMenuItem(
                        icon: Icons.manage_accounts_rounded,
                        title: 'Edit profile',
                        subtitle: 'Name, phone and profile photo',
                        onTap: () => Navigator.pushNamed(context, AppRoutes.editProfile),
                      ),
                      ProfileMenuItem(
                        icon: Icons.receipt_long_rounded,
                        title: 'Orders & live tracking',
                        subtitle: 'Track deliveries, invoices and reorder',
                        onTap: () => Navigator.pushNamed(context, AppRoutes.orders),
                      ),
                      ProfileMenuItem(
                        icon: Icons.location_on_rounded,
                        title: 'Saved delivery addresses',
                        subtitle: 'Home, shop and preferred locations',
                        onTap: () => Navigator.pushNamed(context, AppRoutes.savedAddresses),
                      ),
                      ProfileMenuItem(
                        icon: Icons.lock_person_rounded,
                        title: 'Email & password login',
                        subtitle: 'Set or update your secure login password',
                        loading: _savingPassword,
                        onTap: _setLoginPassword,
                      ),
                      const SizedBox(height: 18),
                      const _SectionTitle('PREFERENCES & SUPPORT'),
                      const SizedBox(height: 10),
                      ProfileMenuItem(
                        icon: Icons.notifications_rounded,
                        title: 'Notifications',
                        subtitle: 'Order alerts and fresh deal preferences',
                        onTap: () => Navigator.pushNamed(context, AppRoutes.notifications),
                      ),
                      ProfileMenuItem(
                        icon: Icons.tune_rounded,
                        title: 'App preferences',
                        subtitle: 'Notifications, language and privacy',
                        onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
                      ),
                      ProfileMenuItem(
                        icon: Icons.support_agent_rounded,
                        title: 'Priority support',
                        subtitle: 'Help with orders, refunds and payments',
                        badge: 'LIVE',
                        onTap: () => Navigator.pushNamed(context, AppRoutes.support),
                      ),
                      ProfileMenuItem(
                        icon: Icons.shield_rounded,
                        title: 'Privacy & security',
                        subtitle: 'Account protection and data controls',
                        onTap: () => Navigator.pushNamed(context, AppRoutes.privacy),
                      ),
                      const SizedBox(height: 18),
                      LogoutButton(onPressed: _logout, loading: _loggingOut),
                    ]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 4,
        onDestinationSelected: (int index) {
          const List<String> routes = <String>[
            AppRoutes.home,
            AppRoutes.categories,
            AppRoutes.cart,
            AppRoutes.orders,
            AppRoutes.profile,
          ];
          if (index != 4) Navigator.pushReplacementNamed(context, routes[index]);
        },
        destinations: const <NavigationDestination>[
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.grid_view_rounded), label: 'Categories'),
          NavigationDestination(icon: Icon(Icons.shopping_bag_outlined), label: 'Cart'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), label: 'Orders'),
          NavigationDestination(icon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }

}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.value);
  final String value;
  @override
  Widget build(BuildContext context) => Text(
        value,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 9.5, letterSpacing: 1.15, fontWeight: FontWeight.w900),
      );
}
