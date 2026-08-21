import 'package:flutter/material.dart';

class AppleLoginButton extends StatelessWidget {
  const AppleLoginButton({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: 'Continue with Apple',
        child: child,
      );
}
