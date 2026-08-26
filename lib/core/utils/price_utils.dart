class PriceUtils {
  PriceUtils._();

  static String format(num value, {bool showDecimals = false}) {
    final double safeValue = value.isFinite ? value.toDouble() : 0;
    final bool negative = safeValue < 0;
    final String fixed = safeValue.abs().toStringAsFixed(showDecimals ? 2 : 0);
    final List<String> parts = fixed.split('.');
    final String grouped = _indianGrouping(parts.first);
    final String decimals = showDecimals ? '.${parts[1]}' : '';
    return '${negative ? '-' : ''}₹$grouped$decimals';
  }

  static String compact(num value) {
    final double amount = value.toDouble();
    if (amount.abs() >= 10000000) return '₹${_trim(amount / 10000000)}Cr';
    if (amount.abs() >= 100000) return '₹${_trim(amount / 100000)}L';
    if (amount.abs() >= 1000) return '₹${_trim(amount / 1000)}K';
    return format(amount);
  }

  static double savings({required double mrp, required double price}) =>
      mrp > price ? mrp - price : 0;

  static int discountPercent({required double mrp, required double price}) =>
      mrp > price && mrp > 0 ? ((mrp - price) * 100 / mrp).round() : 0;

  static double nonNegative(num value) => value < 0 ? 0 : value.toDouble();

  static String _indianGrouping(String digits) {
    if (digits.length <= 3) return digits;
    final String lastThree = digits.substring(digits.length - 3);
    String remaining = digits.substring(0, digits.length - 3);
    final List<String> groups = <String>[];
    while (remaining.length > 2) {
      groups.insert(0, remaining.substring(remaining.length - 2));
      remaining = remaining.substring(0, remaining.length - 2);
    }
    if (remaining.isNotEmpty) groups.insert(0, remaining);
    return '${groups.join(',')},$lastThree';
  }

  static String _trim(double value) =>
      value.toStringAsFixed(1).replaceFirst(RegExp(r'\.0$'), '');
}
