import '../../core/network/api_client.dart';
import '../../core/network/api_response.dart';
import '../models/order_model.dart';

class OrderRemoteSource {
  OrderRemoteSource({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Stream<List<OrderModel>> watchUserOrders(String userId, {int limit = 50}) =>
      Stream<List<OrderModel>>.fromFuture(getUserOrders(userId, limit: limit));

  Future<List<OrderModel>> getUserOrders(
    String userId, {
    int limit = 50,
  }) async {
    final ApiResponse<dynamic> response = await _client.get('/api/v1/orders');
    final dynamic raw = response.data;
    if (raw is! Iterable) return <OrderModel>[];
    return raw
        .whereType<Map>()
        .take(limit <= 0 ? 50 : limit)
        .map(
          (Map<dynamic, dynamic> value) => OrderModel.fromMap(
            value.map(
              (dynamic key, dynamic item) =>
                  MapEntry<String, dynamic>(key.toString(), item),
            ),
          ),
        )
        .toList(growable: false);
  }

  Stream<OrderModel?> watchOrder(String orderId) =>
      Stream<OrderModel?>.fromFuture(getOrder(orderId));

  Future<OrderModel?> getOrder(String orderId) async {
    final String id = orderId.trim();
    if (id.isEmpty) return null;
    final ApiResponse<dynamic> response = await _client.get(
      '/api/v1/orders/$id',
    );
    final dynamic raw = response.data;
    if (raw is! Map) return null;
    return OrderModel.fromMap(
      raw.map(
        (dynamic key, dynamic value) =>
            MapEntry<String, dynamic>(key.toString(), value),
      ),
      documentId: id,
    );
  }

  Future<String> createOrder(OrderModel order) {
    throw UnsupportedError('Orders must be created through secure checkout.');
  }

  Future<void> updateOrder(OrderModel order) {
    throw UnsupportedError('Order changes require a backend operation.');
  }

  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
    String note = '',
  }) {
    throw UnsupportedError('Customers cannot change order status.');
  }

  Future<void> cancelOrder({
    required String orderId,
    String reason = '',
  }) async {
    await _client.post(
      '/api/v1/orders/${orderId.trim()}/cancel',
      body: <String, dynamic>{'reason': reason.trim()},
    );
  }

  Future<void> updatePaymentStatus({
    required String orderId,
    required String paymentStatus,
    String paymentId = '',
    String transactionId = '',
  }) {
    throw UnsupportedError('Payment status is controlled by the backend.');
  }
}
