import 'package:flutter/material.dart';

class ContinuePaymentBar extends StatelessWidget {
  const ContinuePaymentBar({
    super.key,
    required this.onPressed,
    this.loading = false,
  });

  final VoidCallback onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 55,
        child: FilledButton.icon(
          onPressed: loading ? null : onPressed,
          icon: loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : const Icon(Icons.lock_rounded),
          label: const Text(
            'CONTINUE TO PAYMENT',
            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.15),
          ),
        ),
      );
}
