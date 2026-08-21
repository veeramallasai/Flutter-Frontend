import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class PreorderNotice extends StatelessWidget {
  const PreorderNotice({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E6),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFF0DDA8)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.info_outline_rounded, color: Color(0xFFB87800), size: 21),
          SizedBox(width: 9),
          Expanded(
            child: Text(
              'Pre-order dates depend on harvest readiness. We’ll notify you if weather changes the expected delivery date.',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 9, height: 1.45, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
