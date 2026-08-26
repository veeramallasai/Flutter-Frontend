import 'package:cloud_firestore/cloud_firestore.dart';

import '../network/api_client.dart';
import '../network/api_response.dart';
import '../errors/network_exception.dart';

class BackendOrderResult {
  const BackendOrderResult({
    required this.orderId,
    required this.orderNumber,
    required this.paymentId,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.totalAmount,
    required this.itemCount,
    this.deliveryPartnerTipAccepted = false,
  });

  final String orderId;
  final String orderNumber;
  final String paymentId;
  final String paymentStatus;
  final String paymentMethod;
  final double totalAmount;
  final int itemCount;
  final bool deliveryPartnerTipAccepted;

  factory BackendOrderResult.fromMap(
    Map<String, dynamic> map, {
    bool deliveryPartnerTipAccepted = false,
  }) {
    return BackendOrderResult(
      orderId: _text(map['orderId']),
      orderNumber: _text(map['orderNumber']),
      paymentId: _text(map['paymentId']),
      paymentStatus: _text(map['paymentStatus'], fallback: 'pending'),
      paymentMethod: _text(map['paymentMethod'], fallback: 'cash_on_delivery'),
      totalAmount: _number(map['totalAmount']),
      itemCount: _integer(map['itemCount']),
      deliveryPartnerTipAccepted: deliveryPartnerTipAccepted,
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
    double deliveryPartnerTip = 0,
  }) async {
    final double normalizedTip =
        deliveryPartnerTip < 0 ? 0 : deliveryPartnerTip;

    final Map<String, dynamic> baseBody = <String, dynamic>{
      'shoppingMode': shoppingMode == 'shop' ? 'shop' : 'home',
      'paymentMethod': paymentMethod,
      'addressId': addressId.trim(),
      'address': _jsonMap(address),
      'deliveryMethod': deliveryMethod.trim().toLowerCase(),
      'deliveryDate': deliveryDate,
      'deliverySlot': deliverySlot.trim(),
      'couponCode': couponCode.trim().toUpperCase(),
    };

    if (normalizedTip <= 0) {
      return _placeOrderRequest(baseBody, deliveryPartnerTipAccepted: false);
    }

    try {
      return await _placeOrderRequest(<String, dynamic>{
        ...baseBody,
        'deliveryPartnerTip': normalizedTip,
      }, deliveryPartnerTipAccepted: true);
    } on NetworkException catch (error) {
      // Older backend builds may not yet expose deliveryPartnerTip in the
      // request DTO. A 400 in that case should not block COD checkout.
      // Retry once using the stable order contract. The client still carries
      // the selected tip to confirmation so it can be paid to the partner.
      if (error.statusCode != 400) rethrow;
      return _placeOrderRequest(baseBody, deliveryPartnerTipAccepted: false);
    }
  }

  Future<BackendOrderResult> _placeOrderRequest(
    Map<String, dynamic> body, {
    required bool deliveryPartnerTipAccepted,
  }) async {
    final ApiResponse<dynamic> response = await _client.post(
      '/api/v1/orders',
      body: body,
    );
    final dynamic raw = response.data;
    if (raw is! Map) {
      throw StateError('Backend returned an invalid order response.');
    }
    return BackendOrderResult.fromMap(
      Map<String, dynamic>.from(raw),
      deliveryPartnerTipAccepted: deliveryPartnerTipAccepted,
    );
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
