import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class PremiumTextField extends StatelessWidget {
  const PremiumTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.enabled = true,
    this.maxLines = 1,
    this.validator,
    this.onChanged,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool enabled;
  final int maxLines;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    enabled: enabled,
    keyboardType: keyboardType,
    textInputAction: textInputAction,
    obscureText: obscureText,
    maxLines: obscureText ? 1 : maxLines,
    validator: validator,
    onChanged: onChanged,
    onFieldSubmitted: onSubmitted,
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon:
          prefixIcon == null
              ? null
              : Icon(prefixIcon, color: AppColors.primary),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: const BorderSide(color: AppColors.border),
      ),
    ),
  );
}
