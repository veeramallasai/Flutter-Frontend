import 'package:flutter/material.dart';

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({
    super.key,
    required this.loading,
    required this.child,
    this.message = 'Please wait...',
  });

  final bool loading;
  final Widget child;
  final String message;

  @override
  Widget build(BuildContext context) => Stack(
        children: <Widget>[
          child,
          if (loading)
            Positioned.fill(
              child: ColoredBox(
                color: const Color(0x72000000),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4)),
                        const SizedBox(width: 12),
                        Text(message, style: const TextStyle(fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
}
