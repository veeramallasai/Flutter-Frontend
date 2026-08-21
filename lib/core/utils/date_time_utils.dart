class DateTimeUtils {
  DateTimeUtils._();

  static const List<String> _months = <String>[
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  static const List<String> _weekdays = <String>[
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
  ];

  static String formatDate(DateTime? value) {
    if (value == null) return '';
    return '${value.day.toString().padLeft(2, '0')} ${_months[value.month - 1]} ${value.year}';
  }

  static String formatShortDate(DateTime? value) {
    if (value == null) return '';
    return '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
  }

  static String formatTime(DateTime? value) {
    if (value == null) return '';
    final int hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    return '$hour:${value.minute.toString().padLeft(2, '0')} ${value.hour >= 12 ? 'PM' : 'AM'}';
  }

  static String formatDateTime(DateTime? value) {
    if (value == null) return '';
    return '${formatDate(value)}, ${formatTime(value)}';
  }

  static String weekday(DateTime value) => _weekdays[value.weekday - 1];

  static bool isSameDay(DateTime first, DateTime second) =>
      first.year == second.year && first.month == second.month && first.day == second.day;

  static String relative(DateTime? value, {DateTime? now}) {
    if (value == null) return '';
    final Duration difference = (now ?? DateTime.now()).difference(value);
    if (difference.isNegative) return formatDateTime(value);
    if (difference.inSeconds < 60) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes} min ago';
    if (difference.inHours < 24) return '${difference.inHours} hr ago';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays} days ago';
    return formatDate(value);
  }

  static DateTime startOfDay(DateTime value) => DateTime(value.year, value.month, value.day);
  static DateTime endOfDay(DateTime value) =>
      DateTime(value.year, value.month, value.day, 23, 59, 59, 999);
}
