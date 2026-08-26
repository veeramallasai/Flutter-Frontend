import 'package:flutter/material.dart';

class PasswordStrength extends StatelessWidget {
  const PasswordStrength({super.key, required this.password});

  final String password;

  int get _score {
    int value = 0;
    if (password.length >= 8) value++;
    if (RegExp(r'[A-Z]').hasMatch(password)) value++;
    if (RegExp(r'[a-z]').hasMatch(password)) value++;
    if (RegExp(r'\d').hasMatch(password)) value++;
    return value;
  }

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();
    final int score = _score;
    final Color color =
        score <= 1
            ? const Color(0xFFD93C3C)
            : score <= 3
            ? const Color(0xFFD88A09)
            : const Color(0xFF11854A);
    final String label =
        score <= 1
            ? 'Weak'
            : score <= 3
            ? 'Good'
            : 'Strong';
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: <Widget>[
          for (int index = 0; index < 4; index++)
            Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(right: index == 3 ? 0 : 5),
                decoration: BoxDecoration(
                  color: index < score ? color : const Color(0xFFE3E9E5),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          const SizedBox(width: 9),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
