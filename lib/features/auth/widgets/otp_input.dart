import 'package:flutter/material.dart';

class OtpInput extends StatelessWidget {
  const OtpInput({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Semantics(
        textField: true,
        label: 'Six digit one time password',
        child: child,
      );
}
