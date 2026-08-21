enum OrderStatus {
  placed('placed', 'Order Placed'),
  confirmed('confirmed', 'Confirmed'),
  processing('processing', 'Processing'),
  packed('packed', 'Packed'),
  shipped('shipped', 'Shipped'),
  outForDelivery('out_for_delivery', 'Out for Delivery'),
  delivered('delivered', 'Delivered'),
  cancelled('cancelled', 'Cancelled'),
  failed('failed', 'Failed');

  const OrderStatus(this.value, this.label);
  final String value;
  final String label;

  bool get isActive => !isCompleted;
  bool get isCompleted =>
      this == OrderStatus.delivered ||
      this == OrderStatus.cancelled ||
      this == OrderStatus.failed;
  bool get canCancel =>
      this == OrderStatus.placed ||
      this == OrderStatus.confirmed ||
      this == OrderStatus.processing;
  bool get canTrack => this != OrderStatus.cancelled && this != OrderStatus.failed;

  int get trackingIndex {
    const List<OrderStatus> flow = <OrderStatus>[
      OrderStatus.placed,
      OrderStatus.confirmed,
      OrderStatus.processing,
      OrderStatus.packed,
      OrderStatus.shipped,
      OrderStatus.outForDelivery,
      OrderStatus.delivered,
    ];
    return flow.indexOf(this);
  }

  static OrderStatus fromValue(String? value) {
    final String normalized = value?.trim().toLowerCase() ?? '';
    return OrderStatus.values.firstWhere(
      (OrderStatus item) => item.value == normalized,
      orElse: () => OrderStatus.placed,
    );
  }
}
