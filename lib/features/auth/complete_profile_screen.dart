import 'package:farm_to_home_app/core/auth/backend_auth.dart';
import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../data/repositories/user_repository.dart';
import 'widgets/auth_background.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final User? user = BackendAuth.instance.currentUser;
    _nameController.text = user?.displayName ?? '';
    _phoneController.text = user?.phoneNumber?.replaceFirst('+91', '') ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false) || _saving) return;
    final User? user = BackendAuth.instance.currentUser;
    if (user == null) return;
    setState(() => _saving = true);
    try {
      final String name = _nameController.text.trim();
      await user.updateDisplayName(name);
      try {
        await UserRepository().syncCurrentUser();
      } catch (_) {}
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.home,
        (Route<dynamic> route) => false,
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to save profile. Please try again.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => AuthBackground(
    child: Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: AppColors.border),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 34,
                      offset: Offset(0, 14),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const CircleAvatar(
                        radius: 34,
                        backgroundColor: Color(0xFFE8F5E9),
                        child: Icon(
                          Icons.person_rounded,
                          color: AppColors.primary,
                          size: 34,
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Complete your profile',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 7),
                      const Text(
                        'A few details help us personalise delivery and support.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        validator:
                            (String? value) =>
                                (value?.trim().length ?? 0) < 2
                                    ? 'Enter your name'
                                    : null,
                        decoration: const InputDecoration(
                          labelText: 'Full name',
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        validator: (String? value) {
                          final String phone = value?.trim() ?? '';
                          return phone.isNotEmpty &&
                                  !RegExp(r'^[6-9]\d{9}$').hasMatch(phone)
                              ? 'Enter a valid mobile number'
                              : null;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Mobile number',
                          prefixText: '+91  ',
                          prefixIcon: Icon(Icons.phone_iphone_rounded),
                        ),
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        height: 54,
                        child: FilledButton(
                          onPressed: _saving ? null : _save,
                          child:
                              _saving
                                  ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Text(
                                    'SAVE & CONTINUE',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
