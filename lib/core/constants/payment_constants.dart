class PaymentConstants {
  PaymentConstants._();

  static const String cashOnDelivery = 'cash_on_delivery';
  static const String googlePay = 'google_pay';
  static const String phonePe = 'phone_pe';
  static const String upi = 'upi';
  static const String card = 'card';
  static const String netBanking = 'net_banking';

  static const String pending = 'pending';
  static const String paid = 'paid';
  static const String paidTest = 'paid_test';
  static const String failed = 'failed';
  static const String refunded = 'refunded';

  static const List<String> supportedMethods = <String>[
    cashOnDelivery,
    googlePay,
    phonePe,
    upi,
    card,
    netBanking,
  ];
  static const Set<String> successfulStatuses = <String>{paid, paidTest};
}
