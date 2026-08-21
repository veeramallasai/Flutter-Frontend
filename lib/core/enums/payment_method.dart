enum PaymentMethod {
  cashOnDelivery('cash_on_delivery', 'Cash on Delivery'),
  googlePay('google_pay', 'Google Pay'),
  phonePe('phone_pe', 'PhonePe'),
  upi('upi', 'UPI'),
  card('card', 'Credit / Debit Card'),
  netBanking('net_banking', 'Net Banking');

  const PaymentMethod(this.value, this.label);
  final String value;
  final String label;

  bool get isCashOnDelivery => this == PaymentMethod.cashOnDelivery;
  bool get isOnline => !isCashOnDelivery;

  static PaymentMethod fromValue(String? value) {
    final String normalized = value?.trim().toLowerCase() ?? '';
    return PaymentMethod.values.firstWhere(
      (PaymentMethod item) => item.value == normalized,
      orElse: () => PaymentMethod.cashOnDelivery,
    );
  }
}
