import 'package:firebase_auth/firebase_auth.dart';

import '../../core/network/api_client.dart';
import '../models/order_model.dart';
import '../remote/order_remote_source.dart';

class OrderRepository {
  OrderRepository({
    OrderRemoteSource? remoteSource,
    FirebaseAuth? auth,
    ApiClient? client,
  }) : _remoteSource = remoteSource ?? OrderRemoteSource(),
       _auth = auth ?? FirebaseAuth.instance,
       _client = client ?? ApiClient();

  final OrderRemoteSource _remoteSource;
  final FirebaseAuth _auth;
  final ApiClient _client;

  String? get currentUserId => _auth.currentUser?.uid;

  bool get isSignedIn => currentUserId != null;

  Stream<List<OrderModel>> watchCurrentUserOrders({int limit = 50}) {
    final String userId = _requireUserId();

    return _remoteSource.watchUserOrders(userId, limit: limit);
  }

  Stream<List<OrderModel>> watchOrdersByStatus(
    String status, {
    int limit = 50,
  }) {
    final String normalizedStatus = status.trim().toLowerCase();

    return watchCurrentUserOrders(limit: limit).map((List<OrderModel> orders) {
      if (normalizedStatus.isEmpty || normalizedStatus == 'all') {
        return orders;
      }

      return List<OrderModel>.unmodifiable(
        orders.where((OrderModel order) => order.status == normalizedStatus),
      );
    });
  }

  Future<List<OrderModel>> getCurrentUserOrders({int limit = 50}) {
    final String userId = _requireUserId();

    return _remoteSource.getUserOrders(userId, limit: limit);
  }

  Stream<OrderModel?> watchOrder(String orderId) {
    final String userId = _requireUserId();

    return _remoteSource.watchOrder(orderId).map((OrderModel? order) {
      if (order == null) {
        return null;
      }

      _verifyOwnership(order, userId);
      return order;
    });
  }

  Future<OrderModel?> getOrder(String orderId) async {
    final String userId = _requireUserId();
    final OrderModel? order = await _remoteSource.getOrder(orderId);

    if (order == null) {
      return null;
    }

    _verifyOwnership(order, userId);
    return order;
  }

  Future<String> createOrder(OrderModel order) {
    final String userId = _requireUserId();
    final OrderModel userOrder = order.userId == userId
        ? order
        : order.copyWith(userId: userId);

    return _remoteSource.createOrder(userOrder);
  }

  Future<void> updateOrder(OrderModel order) async {
    final String userId = _requireUserId();
    final OrderModel currentOrder = await _requireOwnedOrder(order.id, userId);

    if (currentOrder.userId != order.userId) {
      throw StateError('Order owner cannot be changed.');
    }

    await _remoteSource.updateOrder(order);
  }

  Future<void> cancelOrder({
    required String orderId,
    String reason = '',
  }) async {
    _requireUserId();
    await _remoteSource.cancelOrder(orderId: orderId, reason: reason);
  }

  Future<int> reorder(String orderId) async {
    _requireUserId();
    final response = await _client.post(
      '/api/v1/orders/${orderId.trim()}/reorder',
    );
    final dynamic value = response.data;
    return value is num ? value.toInt() : int.tryParse('$value') ?? 0;
  }

  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
    String note = '',
  }) async {
    final String userId = _requireUserId();
    await _requireOwnedOrder(orderId, userId);

    await _remoteSource.updateOrderStatus(
      orderId: orderId,
      status: status,
      note: note,
    );
  }

  Future<void> updatePaymentStatus({
    required String orderId,
    required String paymentStatus,
    String paymentId = '',
    String transactionId = '',
  }) async {
    final String userId = _requireUserId();
    await _requireOwnedOrder(orderId, userId);

    await _remoteSource.updatePaymentStatus(
      orderId: orderId,
      paymentStatus: paymentStatus,
      paymentId: paymentId,
      transactionId: transactionId,
    );
  }

  Future<List<OrderModel>> getActiveOrders({int limit = 50}) async {
    final List<OrderModel> orders = await getCurrentUserOrders(limit: limit);

    return List<OrderModel>.unmodifiable(
      orders.where(
        (OrderModel order) =>
            !order.isDelivered && !order.isCancelled && !order.isFailed,
      ),
    );
  }

  Future<List<OrderModel>> getCompletedOrders({int limit = 50}) async {
    final List<OrderModel> orders = await getCurrentUserOrders(limit: limit);

    return List<OrderModel>.unmodifiable(
      orders.where(
        (OrderModel order) =>
            order.isDelivered || order.isCancelled || order.isFailed,
      ),
    );
  }

  Future<OrderModel> _requireOwnedOrder(String orderId, String userId) async {
    final String normalizedOrderId = orderId.trim();

    if (normalizedOrderId.isEmpty) {
      throw ArgumentError.value(
        orderId,
        'orderId',
        'Order ID cannot be empty.',
      );
    }

    final OrderModel? order = await _remoteSource.getOrder(normalizedOrderId);

    if (order == null) {
      throw StateError('Order not found.');
    }

    _verifyOwnership(order, userId);
    return order;
  }

  void _verifyOwnership(OrderModel order, String userId) {
    if (order.userId != userId) {
      throw StateError('You do not have access to this order.');
    }
  }

  String _requireUserId() {
    final String? userId = currentUserId;

    if (userId == null || userId.trim().isEmpty) {
      throw StateError('Please login to continue.');
    }

    return userId.trim();
  }
}
