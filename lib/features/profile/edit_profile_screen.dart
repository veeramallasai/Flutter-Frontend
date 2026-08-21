import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/premium_toast.dart';
import '../../data/repositories/user_repository.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _photo = TextEditingController();
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    try {
      final DocumentSnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final Map<String, dynamic> data = snapshot.data() ?? <String, dynamic>{};
      _name.text = (data['displayName'] ?? user.displayName ?? '').toString();
      _phone.text = (data['phoneNumber'] ?? user.phoneNumber ?? '').toString();
      _photo.text = (data['photoUrl'] ?? user.photoURL ?? '').toString();
    } catch (_) {
      _name.text = user.displayName ?? '';
      _phone.text = user.phoneNumber ?? '';
      _photo.text = user.photoURL ?? '';
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    if (_formKey.currentState?.validate() != true || _saving) return;
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      PremiumToast.show(context, 'Please login to continue.', error: true);
      return;
    }
    setState(() => _saving = true);
    try {
      final String name = _name.text.trim();
      final List<String> names = name.split(RegExp(r'\s+'));
      final String phone = _phone.text.trim();
      final String photo = _photo.text.trim();
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
        <String, dynamic>{
          'displayName': name,
          'firstName': names.isEmpty ? '' : names.first,
          'lastName': names.length <= 1 ? '' : names.skip(1).join(' '),
          'phoneNumber': phone,
          'photoUrl': photo,
          'email': user.email ?? '',
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      await user.updateDisplayName(name);
      if (photo.isNotEmpty) await user.updatePhotoURL(photo);
      await UserRepository().syncCurrentUser();
      if (!mounted) return;
      PremiumToast.show(context, 'Profile updated successfully');
      Navigator.pop(context, true);
    } on FirebaseException catch (error) {
      if (mounted) {
        PremiumToast.show(
          context,
          error.message ?? 'Unable to update profile.',
          error: true,
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _photo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Edit Profile')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 32),
                children: <Widget>[
                  _ProfilePreview(photoUrl: _photo.text, name: _name.text),
                  const SizedBox(height: 22),
                  TextFormField(
                    controller: _name,
                    textCapitalization: TextCapitalization.words,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      labelText: 'Full name',
                      prefixIcon: Icon(Icons.person_outline_rounded),
                    ),
                    validator: (String? value) =>
                        (value?.trim().length ?? 0) < 2 ? 'Enter your full name' : null,
                  ),
                  const SizedBox(height: 13),
                  TextFormField(
                    initialValue: user?.email ?? '',
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Verified email',
                      prefixIcon: Icon(Icons.alternate_email_rounded),
                      suffixIcon: Icon(Icons.verified_rounded, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 13),
                  TextFormField(
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone number',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    validator: (String? value) {
                      final String digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
                      return digits.isNotEmpty && digits.length < 10
                          ? 'Enter a valid phone number'
                          : null;
                    },
                  ),
                  const SizedBox(height: 13),
                  TextFormField(
                    controller: _photo,
                    keyboardType: TextInputType.url,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      labelText: 'Profile photo URL (optional)',
                      prefixIcon: Icon(Icons.image_outlined),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: _saving
                        ? const SizedBox(
                            width: 17,
                            height: 17,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.check_rounded),
                    label: const Text('SAVE PROFILE'),
                    style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(54)),
                  ),
                ],
              ),
            ),
    );
  }
}

class _ProfilePreview extends StatelessWidget {
  const _ProfilePreview({required this.photoUrl, required this.name});
  final String photoUrl;
  final String name;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: <Color>[Color(0xFF04341F), Color(0xFF159253)],
          ),
          borderRadius: BorderRadius.circular(26),
        ),
        child: Column(
          children: <Widget>[
            Container(
              width: 88,
              height: 88,
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: ClipOval(
                child: photoUrl.startsWith('http')
                    ? Image.network(
                        photoUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _fallback(),
                      )
                    : _fallback(),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              name.trim().isEmpty ? 'Fresh Shopper' : name.trim(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const Text(
              'FARM TO HOME MEMBER',
              style: TextStyle(
                color: Color(0xFFBCE4CD),
                fontSize: 8,
                letterSpacing: 1,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      );

  Widget _fallback() => const ColoredBox(
        color: Color(0xFFEAF7EF),
        child: Icon(Icons.person_rounded, color: AppColors.primary, size: 48),
      );
}
