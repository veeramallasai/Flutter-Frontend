import 'package:flutter/material.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      Semantics(container: true, label: 'Secure login form', child: child);
}
