enum PaymentStatus {
  pending('pending', 'Pending'),
  paid('paid', 'Paid'),
  paidTest('paid_test', 'Paid'),
  failed('failed', 'Failed'),
  refunded('refunded', 'Refunded');

  const PaymentStatus(this.value, this.label);
  final String value;
  final String label;

  bool get isSuccessful =>
      this == PaymentStatus.paid || this == PaymentStatus.paidTest;
  bool get canRetry =>
      this == PaymentStatus.pending || this == PaymentStatus.failed;

  static PaymentStatus fromValue(String? value) {
    final String normalized = value?.trim().toLowerCase() ?? '';
    return PaymentStatus.values.firstWhere(
      (PaymentStatus item) => item.value == normalized,
      orElse: () => PaymentStatus.pending,
    );
  }
}
