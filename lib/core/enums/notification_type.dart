enum NotificationType {
  general('general', 'Updates'),
  order('order', 'Order update'),
  payment('payment', 'Payment update'),
  delivery('delivery', 'Delivery update'),
  offer('offer', 'Offer'),
  account('account', 'Account'),
  system('system', 'System');

  const NotificationType(this.value, this.label);
  final String value;
  final String label;

  static NotificationType fromValue(String? value) {
    final String normalized = value?.trim().toLowerCase() ?? '';
    return NotificationType.values.firstWhere(
      (NotificationType item) => item.value == normalized,
      orElse: () => NotificationType.general,
    );
  }
}
