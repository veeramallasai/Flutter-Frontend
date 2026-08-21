class Validators {
  Validators._();

  static String? requiredField(String? value, {String label = 'This field'}) {
    if (value == null || value.trim().isEmpty) return '$label is required.';
    return null;
  }

  static String? name(String? value, {String label = 'Name'}) {
    final String? required = requiredField(value, label: label);
    if (required != null) return required;
    if (value!.trim().length < 2) return '$label must contain at least 2 characters.';
    if (!RegExp(r"^[a-zA-Z\u0C00-\u0C7F][a-zA-Z\u0C00-\u0C7F .'-]*$").hasMatch(value.trim())) {
      return 'Enter a valid $label.';
    }
    return null;
  }

  static String? email(String? value) {
    final String? required = requiredField(value, label: 'Email');
    if (required != null) return required;
    final String email = value!.trim().toLowerCase();
    if (!RegExp(r"^[a-z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-z0-9-]+(?:\.[a-z0-9-]+)+$")
        .hasMatch(email)) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  static String? password(String? value, {bool strong = true}) {
    final String? required = requiredField(value, label: 'Password');
    if (required != null) return required;
    final String password = value!;
    if (password.length < 8) return 'Password must contain at least 8 characters.';
    if (strong && !RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Add at least one uppercase letter.';
    }
    if (strong && !RegExp(r'[0-9]').hasMatch(password)) {
      return 'Add at least one number.';
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    final String? required = requiredField(value, label: 'Confirm password');
    if (required != null) return required;
    return value == password ? null : 'Passwords do not match.';
  }

  static String? phone(String? value) {
    final String? required = requiredField(value, label: 'Mobile number');
    if (required != null) return required;
    final String digits = value!.replaceAll(RegExp(r'\D'), '');
    final String local = digits.length > 10 ? digits.substring(digits.length - 10) : digits;
    if (local.length != 10 || !RegExp(r'^[6-9]').hasMatch(local)) {
      return 'Enter a valid 10-digit Indian mobile number.';
    }
    return null;
  }

  static String? otp(String? value, {int length = 6}) {
    final String digits = value?.replaceAll(RegExp(r'\D'), '') ?? '';
    return digits.length == length ? null : 'Enter the $length-digit verification code.';
  }

  static String? pincode(String? value) {
    final String digits = value?.replaceAll(RegExp(r'\D'), '') ?? '';
    return RegExp(r'^[1-9][0-9]{5}$').hasMatch(digits)
        ? null
        : 'Enter a valid 6-digit pincode.';
  }

  static String? positiveAmount(String? value, {String label = 'Amount'}) {
    final double? amount = double.tryParse(value?.replaceAll(',', '').trim() ?? '');
    return amount != null && amount > 0 ? null : 'Enter a valid $label.';
  }
}
