class OrderConstants {
  OrderConstants._();

  static const String placed = 'placed';
  static const String confirmed = 'confirmed';
  static const String processing = 'processing';
  static const String packed = 'packed';
  static const String shipped = 'shipped';
  static const String outForDelivery = 'out_for_delivery';
  static const String delivered = 'delivered';
  static const String cancelled = 'cancelled';
  static const String failed = 'failed';

  static const List<String> trackingFlow = <String>[
    placed,
    confirmed,
    processing,
    packed,
    shipped,
    outForDelivery,
    delivered,
  ];

  static const Set<String> activeStatuses = <String>{
    placed, confirmed, processing, packed, shipped, outForDelivery,
  };
  static const Set<String> completedStatuses = <String>{delivered, cancelled, failed};
  static const Set<String> cancellableStatuses = <String>{placed, confirmed, processing};
}
