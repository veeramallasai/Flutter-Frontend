class PhoneUtils {
  PhoneUtils._();

  static String digitsOnly(String value) => value.replaceAll(RegExp(r'\D'), '');

  static String localNumber(String value) {
    final String digits = digitsOnly(value);
    if (digits.length <= 10) return digits;
    return digits.substring(digits.length - 10);
  }

  static String toE164India(String value) {
    final String local = localNumber(value);
    return local.length == 10 ? '+91$local' : '';
  }

  static bool isValidIndianMobile(String value) =>
      RegExp(r'^[6-9][0-9]{9}$').hasMatch(localNumber(value));

  static String formatIndianMobile(String value) {
    final String local = localNumber(value);
    if (local.length != 10) return value.trim();
    return '+91 ${local.substring(0, 5)} ${local.substring(5)}';
  }

  static String mask(String value) {
    final String local = localNumber(value);
    if (local.length < 4) return value;
    return '+91 ••••••${local.substring(local.length - 4)}';
  }
}
