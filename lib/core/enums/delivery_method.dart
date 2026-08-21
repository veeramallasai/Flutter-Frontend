enum DeliveryMethod {
  quick('quick', 'Quick Delivery', 'Delivered in about 45 minutes'),
  scheduled('scheduled', 'Scheduled Delivery', 'Choose a convenient time slot'),
  preorder('preorder', 'Pre-order Delivery', 'Delivered after fresh harvest');

  const DeliveryMethod(this.value, this.label, this.description);
  final String value;
  final String label;
  final String description;

  bool get requiresDate => this != DeliveryMethod.quick;
  bool get requiresSlot => this == DeliveryMethod.scheduled;

  static DeliveryMethod fromValue(String? value) {
    final String normalized = value?.trim().toLowerCase().replaceAll(' ', '_') ?? '';
    if (normalized == 'pre_order') return DeliveryMethod.preorder;
    return DeliveryMethod.values.firstWhere(
      (DeliveryMethod item) => item.value == normalized,
      orElse: () => DeliveryMethod.quick,
    );
  }
}
