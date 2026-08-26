import 'package:cloud_firestore/cloud_firestore.dart';

import 'order_item_model.dart';

class OrderModel {
  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.userId,
    required this.shoppingMode,
    required this.status,
    required this.paymentStatus,
    required this.paymentMethod,
    required List<OrderItemModel> items,
    required this.itemCount,
    required this.subtotal,
    required this.mrpTotal,
    required this.productSavings,
    required this.couponCode,
    required this.couponDiscount,
    required this.deliveryFee,
    required this.totalAmount,
    required this.addressId,
    required Map<String, dynamic> address,
    required this.deliveryMethod,
    required this.deliverySlot,
    required List<OrderStatusHistoryEntry> statusHistory,
    this.paymentId = '',
    this.transactionId = '',
    this.deliveryDate,
    this.createdAt,
    this.updatedAt,
  }) : items = List<OrderItemModel>.unmodifiable(items),
       address = Map<String, dynamic>.unmodifiable(address),
       statusHistory = List<OrderStatusHistoryEntry>.unmodifiable(
         statusHistory,
       );

  final String id;
  final String orderNumber;
  final String userId;
  final String shoppingMode;

  final String status;
  final String paymentStatus;
  final String paymentMethod;
  final String paymentId;
  final String transactionId;

  final List<OrderItemModel> items;
  final int itemCount;

  final double subtotal;
  final double mrpTotal;
  final double productSavings;
  final String couponCode;
  final double couponDiscount;
  final double deliveryFee;
  final double totalAmount;

  final String addressId;
  final Map<String, dynamic> address;

  final String deliveryMethod;
  final String? deliveryDate;
  final String deliverySlot;

  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<OrderStatusHistoryEntry> statusHistory;

  bool get isHomeOrder => shoppingMode != 'shop';

  bool get isShopOrder => shoppingMode == 'shop';

  bool get isCashOnDelivery => paymentMethod == 'cash_on_delivery';

  bool get isPaid => paymentStatus == 'paid' || paymentStatus == 'paid_test';

  bool get isPlaced => status == 'placed';

  bool get isConfirmed => status == 'confirmed';

  bool get isProcessing => status == 'processing' || status == 'packed';

  bool get isShipped => status == 'shipped' || status == 'out_for_delivery';

  bool get isDelivered => status == 'delivered';

  bool get isCancelled => status == 'cancelled';

  bool get isFailed => status == 'failed';

  bool get canTrack => !isCancelled && !isFailed;

  bool get canCancel =>
      status == 'placed' || status == 'confirmed' || status == 'processing';

  bool get canReorder => isDelivered || isCancelled;

  int get calculatedItemCount {
    if (items.isEmpty) {
      return itemCount;
    }

    return items.fold<int>(
      0,
      (int total, OrderItemModel item) => total + item.quantity,
    );
  }

  double get calculatedItemsTotal {
    if (items.isEmpty) {
      return subtotal;
    }

    return items.fold<double>(
      0,
      (double total, OrderItemModel item) => total + item.lineTotal,
    );
  }

  double get totalSavings {
    final double savings = productSavings + couponDiscount;
    return savings < 0 ? 0 : savings;
  }

  String get shortOrderId {
    if (orderNumber.trim().isNotEmpty) {
      return orderNumber.trim();
    }

    if (id.length <= 10) {
      return id.toUpperCase();
    }

    return id.substring(0, 10).toUpperCase();
  }

  String get statusLabel => _label(status, fallback: 'Placed');

  String get paymentStatusLabel {
    switch (paymentStatus) {
      case 'paid':
      case 'paid_test':
        return 'Paid';
      case 'pending':
        return isCashOnDelivery ? 'Pay on Delivery' : 'Payment Pending';
      case 'failed':
        return 'Payment Failed';
      case 'refunded':
        return 'Refunded';
      default:
        return _label(paymentStatus, fallback: 'Pending');
    }
  }

  String get paymentMethodLabel {
    switch (paymentMethod) {
      case 'cash_on_delivery':
        return 'Cash on Delivery';
      case 'google_pay':
        return 'Google Pay';
      case 'phone_pe':
        return 'PhonePe';
      case 'upi':
        return 'UPI';
      case 'card':
        return 'Credit / Debit Card';
      case 'net_banking':
        return 'Net Banking';
      default:
        return _label(paymentMethod, fallback: 'Payment');
    }
  }

  String get deliveryMethodLabel {
    switch (deliveryMethod) {
      case 'quick':
        return 'Quick Delivery';
      case 'scheduled':
        return 'Scheduled Delivery';
      case 'preorder':
      case 'pre_order':
        return 'Pre-order Delivery';
      default:
        return _label(deliveryMethod, fallback: 'Delivery');
    }
  }

  factory OrderModel.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    return OrderModel.fromMap(
      document.data() ?? <String, dynamic>{},
      documentId: document.id,
    );
  }

  factory OrderModel.fromMap(
    Map<String, dynamic> map, {
    String documentId = '',
  }) {
    final List<OrderItemModel> items = _mapList(
      map['items'],
    ).map(OrderItemModel.fromMap).toList(growable: false);

    final List<OrderStatusHistoryEntry> history = _mapList(
      map['statusHistory'],
    ).map(OrderStatusHistoryEntry.fromMap).toList(growable: false);

    final int storedItemCount = _toInt(map['itemCount']);
    final int calculatedCount = items.fold<int>(
      0,
      (int total, OrderItemModel item) => total + item.quantity,
    );

    final double subtotal = _toDouble(map['subtotal']);
    double mrpTotal = _toDouble(map['mrpTotal'], fallback: subtotal);

    if (mrpTotal < subtotal) {
      mrpTotal = subtotal;
    }

    return OrderModel(
      id: _text(
        documentId.isNotEmpty ? documentId : map['id'] ?? map['orderId'],
      ),
      orderNumber: _text(map['orderNumber']),
      userId: _text(map['userId']),
      shoppingMode: _normalizeShoppingMode(map['shoppingMode']),
      status: _text(map['status'], fallback: 'placed').toLowerCase(),
      paymentStatus:
          _text(map['paymentStatus'], fallback: 'pending').toLowerCase(),
      paymentMethod:
          _text(
            map['paymentMethod'],
            fallback: 'cash_on_delivery',
          ).toLowerCase(),
      paymentId: _text(map['paymentId']),
      transactionId: _text(map['transactionId']),
      items: items,
      itemCount: storedItemCount > 0 ? storedItemCount : calculatedCount,
      subtotal: subtotal,
      mrpTotal: mrpTotal,
      productSavings: _nonNegative(
        _toDouble(map['productSavings'], fallback: mrpTotal - subtotal),
      ),
      couponCode: _text(map['couponCode']),
      couponDiscount: _nonNegative(_toDouble(map['couponDiscount'])),
      deliveryFee: _nonNegative(_toDouble(map['deliveryFee'])),
      totalAmount: _nonNegative(_toDouble(map['totalAmount'])),
      addressId: _text(map['addressId']),
      address: _mapValue(map['address']),
      deliveryMethod:
          _text(map['deliveryMethod'], fallback: 'quick').toLowerCase(),
      deliveryDate: _nullableText(map['deliveryDate']),
      deliverySlot: _text(map['deliverySlot'], fallback: 'Earliest available'),
      createdAt: _toDateTime(map['createdAt']),
      updatedAt: _toDateTime(map['updatedAt']),
      statusHistory: history,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'orderId': id,
      'orderNumber': orderNumber,
      'userId': userId,
      'shoppingMode': shoppingMode,
      'status': status,
      'paymentStatus': paymentStatus,
      'paymentMethod': paymentMethod,
      'paymentId': paymentId,
      'transactionId': transactionId,
      'items': items
          .map((OrderItemModel item) => item.toMap())
          .toList(growable: false),
      'itemCount': calculatedItemCount,
      'subtotal': subtotal,
      'mrpTotal': mrpTotal,
      'productSavings': productSavings,
      'couponCode': couponCode,
      'couponDiscount': couponDiscount,
      'deliveryFee': deliveryFee,
      'totalAmount': totalAmount,
      'addressId': addressId,
      'address': address,
      'deliveryMethod': deliveryMethod,
      'deliveryDate': deliveryDate,
      'deliverySlot': deliverySlot,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
      'statusHistory': statusHistory
          .map((OrderStatusHistoryEntry entry) => entry.toMap())
          .toList(growable: false),
    };
  }

  OrderModel copyWith({
    String? id,
    String? orderNumber,
    String? userId,
    String? shoppingMode,
    String? status,
    String? paymentStatus,
    String? paymentMethod,
    String? paymentId,
    String? transactionId,
    List<OrderItemModel>? items,
    int? itemCount,
    double? subtotal,
    double? mrpTotal,
    double? productSavings,
    String? couponCode,
    double? couponDiscount,
    double? deliveryFee,
    double? totalAmount,
    String? addressId,
    Map<String, dynamic>? address,
    String? deliveryMethod,
    String? deliveryDate,
    String? deliverySlot,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<OrderStatusHistoryEntry>? statusHistory,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      userId: userId ?? this.userId,
      shoppingMode: shoppingMode ?? this.shoppingMode,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentId: paymentId ?? this.paymentId,
      transactionId: transactionId ?? this.transactionId,
      items: items ?? this.items,
      itemCount: itemCount ?? this.itemCount,
      subtotal: subtotal ?? this.subtotal,
      mrpTotal: mrpTotal ?? this.mrpTotal,
      productSavings: productSavings ?? this.productSavings,
      couponCode: couponCode ?? this.couponCode,
      couponDiscount: couponDiscount ?? this.couponDiscount,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      totalAmount: totalAmount ?? this.totalAmount,
      addressId: addressId ?? this.addressId,
      address: address ?? this.address,
      deliveryMethod: deliveryMethod ?? this.deliveryMethod,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      deliverySlot: deliverySlot ?? this.deliverySlot,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      statusHistory: statusHistory ?? this.statusHistory,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is OrderModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'OrderModel('
        'id: $id, '
        'orderNumber: $orderNumber, '
        'status: $status, '
        'totalAmount: $totalAmount'
        ')';
  }
}

class OrderStatusHistoryEntry {
  const OrderStatusHistoryEntry({required this.status, required this.time});

  final String status;
  final DateTime? time;

  factory OrderStatusHistoryEntry.fromMap(Map<String, dynamic> map) {
    return OrderStatusHistoryEntry(
      status: _text(map['status'], fallback: 'placed').toLowerCase(),
      time: _toDateTime(map['time']),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'status': status,
      if (time != null) 'time': Timestamp.fromDate(time!),
    };
  }

  String get label => _label(status, fallback: 'Placed');
}

List<Map<String, dynamic>> _mapList(dynamic value) {
  if (value is! Iterable) {
    return <Map<String, dynamic>>[];
  }

  return value
      .whereType<Map>()
      .map((Map item) => Map<String, dynamic>.from(item))
      .toList(growable: false);
}

Map<String, dynamic> _mapValue(dynamic value) {
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }

  return <String, dynamic>{};
}

String _normalizeShoppingMode(dynamic value) {
  return _text(value).toLowerCase() == 'shop' ? 'shop' : 'home';
}

String _text(dynamic value, {String fallback = ''}) {
  if (value == null) {
    return fallback;
  }

  final String text = value.toString().trim();
  return text.isEmpty ? fallback : text;
}

String? _nullableText(dynamic value) {
  final String text = _text(value);
  return text.isEmpty ? null : text;
}

double _toDouble(dynamic value, {double fallback = 0}) {
  if (value is num) {
    return value.toDouble();
  }

  final String cleaned =
      value
          ?.toString()
          .replaceAll(',', '')
          .replaceAll(RegExp(r'[^0-9.\-]'), '') ??
      '';

  return double.tryParse(cleaned) ?? fallback;
}

int _toInt(dynamic value, {int fallback = 0}) {
  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.toInt();
  }

  return int.tryParse(value?.toString().trim() ?? '') ?? fallback;
}

double _nonNegative(double value) {
  return value < 0 ? 0 : value;
}

DateTime? _toDateTime(dynamic value) {
  if (value is Timestamp) {
    return value.toDate();
  }

  if (value is DateTime) {
    return value;
  }

  if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(value);
  }

  if (value is String && value.trim().isNotEmpty) {
    return DateTime.tryParse(value.trim());
  }

  return null;
}

String _label(String value, {required String fallback}) {
  final String normalized = value.trim();

  if (normalized.isEmpty) {
    return fallback;
  }

  return normalized
      .split('_')
      .where((String word) => word.isNotEmpty)
      .map(
        (String word) =>
            '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
      )
      .join(' ');
}
