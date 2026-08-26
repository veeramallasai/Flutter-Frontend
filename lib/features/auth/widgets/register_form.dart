import 'package:flutter/material.dart';

class RegisterForm extends StatelessWidget {
  const RegisterForm({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    label: 'Secure registration form',
    child: child,
  );
}
