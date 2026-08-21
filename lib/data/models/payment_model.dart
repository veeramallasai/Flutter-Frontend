import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentModel {
  const PaymentModel({
    required this.id,
    required this.paymentId,
    required this.userId,
    required this.orderId,
    required this.orderNumber,
    required this.method,
    required this.status,
    required this.subtotal,
    required this.productSavings,
    required this.couponCode,
    required this.couponDiscount,
    required this.deliveryFee,
    required this.totalAmount,
    required this.transactionId,
    required this.gateway,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String paymentId;
  final String userId;
  final String orderId;
  final String orderNumber;
  final String method;
  final String status;
  final double subtotal;
  final double productSavings;
  final String couponCode;
  final double couponDiscount;
  final double deliveryFee;
  final double totalAmount;
  final String transactionId;
  final String gateway;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isCashOnDelivery => method == 'cash_on_delivery';

  bool get isPaid => status == 'paid' || status == 'paid_test';

  bool get isPending => status == 'pending';

  bool get isFailed => status == 'failed';

  bool get isRefunded => status == 'refunded';

  String get methodLabel {
    switch (method) {
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
        return _label(method, fallback: 'Payment');
    }
  }

  String get statusLabel {
    switch (status) {
      case 'paid':
      case 'paid_test':
        return 'Paid';
      case 'pending':
        return isCashOnDelivery ? 'Pay on Delivery' : 'Pending';
      case 'failed':
        return 'Failed';
      case 'refunded':
        return 'Refunded';
      default:
        return _label(status, fallback: 'Pending');
    }
  }

  factory PaymentModel.fromDocument(
      DocumentSnapshot<Map<String, dynamic>> document,
      ) {
    return PaymentModel.fromMap(
      document.data() ?? <String, dynamic>{},
      documentId: document.id,
    );
  }

  factory PaymentModel.fromMap(
      Map<String, dynamic> map, {
        String documentId = '',
      }) {
    final String resolvedId = _text(
      documentId.isNotEmpty ? documentId : map['id'] ?? map['paymentId'],
    );

    return PaymentModel(
      id: resolvedId,
      paymentId: _text(map['paymentId'], fallback: resolvedId),
      userId: _text(map['userId']),
      orderId: _text(map['orderId']),
      orderNumber: _text(map['orderNumber']),
      method: _text(map['method'], fallback: 'cash_on_delivery').toLowerCase(),
      status: _text(map['status'], fallback: 'pending').toLowerCase(),
      subtotal: _toDouble(map['subtotal']),
      productSavings: _toDouble(map['productSavings']),
      couponCode: _text(map['couponCode']),
      couponDiscount: _toDouble(map['couponDiscount']),
      deliveryFee: _toDouble(map['deliveryFee']),
      totalAmount: _toDouble(map['totalAmount']),
      transactionId: _text(map['transactionId']),
      gateway: _text(
        map['gateway'],
        fallback: _text(map['method'], fallback: 'cash_on_delivery'),
      ),
      createdAt: _toDateTime(map['createdAt']),
      updatedAt: _toDateTime(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'paymentId': paymentId,
      'userId': userId,
      'orderId': orderId,
      'orderNumber': orderNumber,
      'method': method,
      'status': status,
      'subtotal': subtotal,
      'productSavings': productSavings,
      'couponCode': couponCode,
      'couponDiscount': couponDiscount,
      'deliveryFee': deliveryFee,
      'totalAmount': totalAmount,
      'transactionId': transactionId,
      'gateway': gateway,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }

  PaymentModel copyWith({
    String? id,
    String? paymentId,
    String? userId,
    String? orderId,
    String? orderNumber,
    String? method,
    String? status,
    double? subtotal,
    double? productSavings,
    String? couponCode,
    double? couponDiscount,
    double? deliveryFee,
    double? totalAmount,
    String? transactionId,
    String? gateway,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      paymentId: paymentId ?? this.paymentId,
      userId: userId ?? this.userId,
      orderId: orderId ?? this.orderId,
      orderNumber: orderNumber ?? this.orderNumber,
      method: method ?? this.method,
      status: status ?? this.status,
      subtotal: subtotal ?? this.subtotal,
      productSavings: productSavings ?? this.productSavings,
      couponCode: couponCode ?? this.couponCode,
      couponDiscount: couponDiscount ?? this.couponDiscount,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      totalAmount: totalAmount ?? this.totalAmount,
      transactionId: transactionId ?? this.transactionId,
      gateway: gateway ?? this.gateway,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

String _text(dynamic value, {String fallback = ''}) {
  final String text = value?.toString().trim() ?? '';
  return text.isEmpty ? fallback : text;
}

double _toDouble(dynamic value, {double fallback = 0}) {
  if (value is num) return value.toDouble();

  final String cleaned = value
      ?.toString()
      .replaceAll(',', '')
      .replaceAll(RegExp(r'[^0-9.\-]'), '') ??
      '';
  return double.tryParse(cleaned) ?? fallback;
}

DateTime? _toDateTime(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  return DateTime.tryParse(value?.toString() ?? '');
}

String _label(String value, {required String fallback}) {
  final String normalized = value.trim();
  if (normalized.isEmpty) return fallback;

  return normalized
      .split('_')
      .where((String part) => part.isNotEmpty)
      .map(
        (String part) =>
    '${part.substring(0, 1).toUpperCase()}${part.substring(1)}',
  )
      .join(' ');
}
