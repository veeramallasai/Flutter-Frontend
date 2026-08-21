import 'package:cloud_firestore/cloud_firestore.dart';

import '../network/api_client.dart';
import '../network/api_response.dart';

class BackendOrderResult {
  const BackendOrderResult({
    required this.orderId,
    required this.orderNumber,
    required this.paymentId,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.totalAmount,
    required this.itemCount,
  });

  final String orderId;
  final String orderNumber;
  final String paymentId;
  final String paymentStatus;
  final String paymentMethod;
  final double totalAmount;
  final int itemCount;

  factory BackendOrderResult.fromMap(Map<String, dynamic> map) {
    return BackendOrderResult(
      orderId: _text(map['orderId']),
      orderNumber: _text(map['orderNumber']),
      paymentId: _text(map['paymentId']),
      paymentStatus: _text(map['paymentStatus'], fallback: 'pending'),
      paymentMethod: _text(map['paymentMethod'], fallback: 'cash_on_delivery'),
      totalAmount: _number(map['totalAmount']),
      itemCount: _integer(map['itemCount']),
    );
  }
}

class OrderBackendService {
  OrderBackendService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<BackendOrderResult> placeOrder({
    required String shoppingMode,
    required String paymentMethod,
    required String addressId,
    required Map<String, dynamic> address,
    required String deliveryMethod,
    required String deliverySlot,
    String? deliveryDate,
    String couponCode = '',
  }) async {
    final ApiResponse<dynamic> response = await _client.post(
      '/api/v1/orders',
      body: <String, dynamic>{
        'shoppingMode': shoppingMode == 'shop' ? 'shop' : 'home',
        'paymentMethod': paymentMethod,
        'addressId': addressId.trim(),
        'address': _jsonMap(address),
        'deliveryMethod': deliveryMethod.trim().toLowerCase(),
        'deliveryDate': deliveryDate,
        'deliverySlot': deliverySlot.trim(),
        'couponCode': couponCode.trim().toUpperCase(),
      },
    );
    final dynamic raw = response.data;
    if (raw is! Map) {
      throw StateError('Backend returned an invalid order response.');
    }
    return BackendOrderResult.fromMap(Map<String, dynamic>.from(raw));
  }
}

Map<String, dynamic> _jsonMap(Map<dynamic, dynamic> value) => value.map(
      (dynamic key, dynamic item) =>
          MapEntry<String, dynamic>(key.toString(), _jsonValue(item)),
    );

dynamic _jsonValue(dynamic value) {
  if (value == null || value is String || value is num || value is bool) {
    return value;
  }
  if (value is Timestamp) return value.toDate().toUtc().toIso8601String();
  if (value is DateTime) return value.toUtc().toIso8601String();
  if (value is GeoPoint) {
    return <String, double>{
      'latitude': value.latitude,
      'longitude': value.longitude,
    };
  }
  if (value is Map) return _jsonMap(value);
  if (value is Iterable) return value.map<dynamic>(_jsonValue).toList();
  return value.toString();
}

String _text(dynamic value, {String fallback = ''}) {
  final String text = value?.toString().trim() ?? '';
  return text.isEmpty ? fallback : text;
}

double _number(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

int _integer(dynamic value) {
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
