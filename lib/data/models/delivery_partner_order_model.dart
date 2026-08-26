class DeliveryPartnerOrderModel {
  const DeliveryPartnerOrderModel({
    required this.id,
    required this.status,
    this.customerName = '',
    this.address = '',
    this.scheduledAt = '',
  });

  final String id;
  final String status;
  final String customerName;
  final String address;
  final String scheduledAt;

  factory DeliveryPartnerOrderModel.fromMap(Map<String, dynamic> map) {
    return DeliveryPartnerOrderModel(
      id: (map['id'] ?? map['orderId'] ?? '').toString(),
      status: (map['status'] ?? map['deliveryStatus'] ?? 'ASSIGNED').toString(),
      customerName: (map['customerName'] ?? map['customer'] ?? '').toString(),
      address: (map['address'] ?? map['deliveryAddress'] ?? '').toString(),
      scheduledAt: (map['scheduledAt'] ?? map['deliveryDate'] ?? '').toString(),
    );
  }
}
