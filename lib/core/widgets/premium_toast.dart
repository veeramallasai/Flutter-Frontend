import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Compact, non-blocking feedback used for cart actions.
/// It deliberately avoids ScaffoldMessenger so it never covers checkout UI.
class PremiumToast {
  PremiumToast._();

  static OverlayEntry? _entry;
  static Timer? _timer;

  static void show(
    BuildContext context,
    String message, {
    bool error = false,
  }) {
    _timer?.cancel();
    _entry?.remove();

    final OverlayState overlay = Overlay.of(context, rootOverlay: true);
    _entry = OverlayEntry(
      builder: (BuildContext context) => Positioned(
        left: 18,
        right: 18,
        bottom: MediaQuery.paddingOf(context).bottom + 86,
        child: IgnorePointer(
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 430),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: error ? AppColors.error : const Color(0xFF073D24),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(
                      color: Color(0x26000000),
                      blurRadius: 22,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      error ? Icons.error_outline_rounded : Icons.check_circle_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 9),
                    Flexible(
                      child: Text(
                        message,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          height: 1.25,
                          fontWeight: FontWeight.w800,
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
    );
    overlay.insert(_entry!);
    _timer = Timer(const Duration(milliseconds: 1350), () {
      _entry?.remove();
      _entry = null;
    });
  }
}
