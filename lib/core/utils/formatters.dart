import 'package:flutter/services.dart';

class Formatters {
  Formatters._();

  static final TextInputFormatter digitsOnly = FilteringTextInputFormatter.digitsOnly;
  static final TextInputFormatter phoneNumber = LengthLimitingTextInputFormatter(10);
  static final TextInputFormatter otp = LengthLimitingTextInputFormatter(6);
  static final TextInputFormatter pincode = LengthLimitingTextInputFormatter(6);
  static final TextInputFormatter name = FilteringTextInputFormatter.allow(
    RegExp(r"[a-zA-Z\u0C00-\u0C7F .'-]"),
  );
  static final TextInputFormatter decimal = FilteringTextInputFormatter.allow(
    RegExp(r'^\d*\.?\d{0,2}'),
  );

  static List<TextInputFormatter> mobileFormatters() => <TextInputFormatter>[
        digitsOnly,
        phoneNumber,
      ];

  static List<TextInputFormatter> otpFormatters({int length = 6}) =>
      <TextInputFormatter>[
        digitsOnly,
        LengthLimitingTextInputFormatter(length),
      ];

  static String titleCase(String value) {
    return value
        .trim()
        .split(RegExp(r'\s+'))
        .where((String word) => word.isNotEmpty)
        .map((String word) => '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
        .join(' ');
  }
}
