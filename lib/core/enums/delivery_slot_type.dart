enum DeliverySlotType {
  earliest('earliest', 'Earliest available'),
  morning('morning', 'Morning'),
  afternoon('afternoon', 'Afternoon'),
  evening('evening', 'Evening'),
  custom('custom', 'Custom slot');

  const DeliverySlotType(this.value, this.label);
  final String value;
  final String label;

  static DeliverySlotType fromValue(String? value) {
    final String normalized = value?.trim().toLowerCase() ?? '';
    return DeliverySlotType.values.firstWhere(
      (DeliverySlotType item) => item.value == normalized,
      orElse: () => DeliverySlotType.earliest,
    );
  }
}
