class DeliveryUtils {
  DeliveryUtils._();

  static const double freeDeliveryThreshold = 499;
  static const double quickDeliveryFee = 35;
  static const double scheduledDeliveryFee = 20;

  static String normalizeMethod(String value) {
    final String normalized = value.trim().toLowerCase().replaceAll(' ', '_');
    if (normalized == 'scheduled') return 'scheduled';
    if (normalized == 'preorder' || normalized == 'pre_order')
      return 'preorder';
    return 'quick';
  }

  static String methodLabel(String method) {
    switch (normalizeMethod(method)) {
      case 'scheduled':
        return 'Scheduled Delivery';
      case 'preorder':
        return 'Pre-order Delivery';
      default:
        return 'Quick Delivery';
    }
  }

  static double fee({required double subtotal, required String method}) {
    if (subtotal >= freeDeliveryThreshold ||
        normalizeMethod(method) == 'preorder')
      return 0;
    return normalizeMethod(method) == 'scheduled'
        ? scheduledDeliveryFee
        : quickDeliveryFee;
  }

  static double amountForFreeDelivery(double subtotal) {
    final double remaining = freeDeliveryThreshold - subtotal;
    return remaining > 0 ? remaining : 0;
  }

  static String estimatedArrival(String method, {DateTime? now}) {
    final DateTime current = now ?? DateTime.now();
    switch (normalizeMethod(method)) {
      case 'scheduled':
        return 'Choose your preferred date and time';
      case 'preorder':
        return 'Delivered on the selected harvest date';
      default:
        final DateTime arrival = current.add(const Duration(minutes: 45));
        return 'Today by ${_time(arrival)}';
    }
  }

  static bool isSlotAvailable({
    required DateTime date,
    required int startHour,
    DateTime? now,
  }) {
    final DateTime current = now ?? DateTime.now();
    final DateTime slot = DateTime(date.year, date.month, date.day, startHour);
    return slot.isAfter(current.add(const Duration(minutes: 30)));
  }

  static String _time(DateTime value) {
    final int hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final String minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute ${value.hour >= 12 ? 'PM' : 'AM'}';
  }
}
