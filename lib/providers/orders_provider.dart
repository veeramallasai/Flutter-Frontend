import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/models/order_model.dart';
import '../data/repositories/order_repository.dart';

class OrdersProvider extends ChangeNotifier {
  static const int _defaultLimit = 50;

  OrdersProvider({OrderRepository? repository})
    : _repository = repository ?? OrderRepository() {
    listenToOrders();
  }

  final OrderRepository _repository;

  StreamSubscription<List<OrderModel>>? _ordersSubscription;

  List<OrderModel> _orders = <OrderModel>[];
  String _selectedFilter = 'all';
  bool _isLoading = false;
  bool _isRefreshing = false;
  String _processingOrderId = '';
  String? _errorMessage;
  bool _disposed = false;

  List<OrderModel> get orders => List<OrderModel>.unmodifiable(_orders);

  String get selectedFilter => _selectedFilter;

  bool get isLoading => _isLoading;

  bool get isRefreshing => _isRefreshing;

  String get processingOrderId => _processingOrderId;

  String? get errorMessage => _errorMessage;

  bool get hasError =>
      _errorMessage != null && _errorMessage!.trim().isNotEmpty;

  List<OrderModel> get filteredOrders {
    switch (_selectedFilter) {
      case 'active':
        return List<OrderModel>.unmodifiable(
          _orders.where(
            (OrderModel order) =>
                !order.isDelivered && !order.isCancelled && !order.isFailed,
          ),
        );
      case 'delivered':
        return List<OrderModel>.unmodifiable(
          _orders.where((OrderModel order) => order.isDelivered),
        );
      case 'cancelled':
        return List<OrderModel>.unmodifiable(
          _orders.where(
            (OrderModel order) => order.isCancelled || order.isFailed,
          ),
        );
      case 'all':
      default:
        return orders;
    }
  }

  List<OrderModel> get activeOrders {
    return List<OrderModel>.unmodifiable(
      _orders.where(
        (OrderModel order) =>
            !order.isDelivered && !order.isCancelled && !order.isFailed,
      ),
    );
  }

  List<OrderModel> get completedOrders {
    return List<OrderModel>.unmodifiable(
      _orders.where(
        (OrderModel order) =>
            order.isDelivered || order.isCancelled || order.isFailed,
      ),
    );
  }

  int get totalCount => _orders.length;

  int get activeCount => activeOrders.length;

  int get deliveredCount {
    return _orders.where((OrderModel order) => order.isDelivered).length;
  }

  int get cancelledCount {
    return _orders
        .where((OrderModel order) => order.isCancelled || order.isFailed)
        .length;
  }

  bool get hasOrders => _orders.isNotEmpty;

  bool get hasFilteredOrders => filteredOrders.isNotEmpty;

  bool isProcessing(String orderId) {
    return _processingOrderId.isNotEmpty && _processingOrderId == orderId;
  }

  void listenToOrders({int limit = _defaultLimit}) {
    _ordersSubscription?.cancel();

    _isLoading = true;
    _errorMessage = null;
    _notify();

    try {
      _ordersSubscription = _repository
          .watchCurrentUserOrders(limit: limit)
          .listen(
            (List<OrderModel> newOrders) {
              if (_disposed) {
                return;
              }

              _orders = List<OrderModel>.from(newOrders);
              _isLoading = false;
              _isRefreshing = false;
              _errorMessage = null;
              _notify();
            },
            onError: (Object error, StackTrace stackTrace) {
              if (_disposed) {
                return;
              }

              _isLoading = false;
              _isRefreshing = false;
              _errorMessage = _friendlyError(error);
              _notify();
            },
          );
    } catch (error) {
      _isLoading = false;
      _isRefreshing = false;
      _errorMessage = _friendlyError(error);
      _notify();
    }
  }

  Future<void> refresh({int limit = _defaultLimit}) async {
    if (_isRefreshing) {
      return;
    }

    _isRefreshing = true;
    _errorMessage = null;
    _notify();

    try {
      final List<OrderModel> newOrders = await _repository.getCurrentUserOrders(
        limit: limit,
      );

      if (_disposed) {
        return;
      }

      _orders = List<OrderModel>.from(newOrders);
      _isLoading = false;
      _isRefreshing = false;
      _errorMessage = null;
      _notify();
    } catch (error) {
      if (_disposed) {
        return;
      }

      _isLoading = false;
      _isRefreshing = false;
      _errorMessage = _friendlyError(error);
      _notify();
    }
  }

  void selectFilter(String filter) {
    final String normalized = filter.trim().toLowerCase();

    const Set<String> supportedFilters = <String>{
      'all',
      'active',
      'delivered',
      'cancelled',
    };

    _selectedFilter = supportedFilters.contains(normalized)
        ? normalized
        : 'all';
    _errorMessage = null;
    _notify();
  }

  Future<bool> cancelOrder({
    required String orderId,
    String reason = '',
  }) async {
    final String normalizedOrderId = orderId.trim();

    if (normalizedOrderId.isEmpty || _processingOrderId.isNotEmpty) {
      return false;
    }

    _processingOrderId = normalizedOrderId;
    _errorMessage = null;
    _notify();

    try {
      await _repository.cancelOrder(orderId: normalizedOrderId, reason: reason);
      _orders = await _repository.getCurrentUserOrders(limit: _defaultLimit);

      if (_disposed) {
        return true;
      }

      _processingOrderId = '';
      _errorMessage = null;
      _notify();
      return true;
    } catch (error) {
      if (_disposed) {
        return false;
      }

      _processingOrderId = '';
      _errorMessage = _friendlyError(error);
      _notify();
      return false;
    }
  }

  Future<bool> reorder(String orderId) async {
    final String normalizedOrderId = orderId.trim();
    final OrderModel? order = findOrder(normalizedOrderId);

    if (normalizedOrderId.isEmpty ||
        _processingOrderId.isNotEmpty ||
        order == null ||
        !order.canReorder) {
      return false;
    }

    _processingOrderId = normalizedOrderId;
    _errorMessage = null;
    _notify();

    try {
      await _repository.reorder(normalizedOrderId);

      if (_disposed) {
        return true;
      }

      _processingOrderId = '';
      _errorMessage = null;
      _notify();
      return true;
    } catch (error) {
      if (_disposed) {
        return false;
      }

      _processingOrderId = '';
      _errorMessage = _friendlyError(error);
      _notify();
      return false;
    }
  }

  OrderModel? findOrder(String orderId) {
    final String normalizedOrderId = orderId.trim();

    for (final OrderModel order in _orders) {
      if (order.id == normalizedOrderId) {
        return order;
      }
    }

    return null;
  }

  void clearError() {
    if (_errorMessage == null) {
      return;
    }

    _errorMessage = null;
    _notify();
  }

  void _notify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  String _friendlyError(Object error) {
    final String message = error.toString().trim();

    if (message.startsWith('Bad state: ')) {
      return message.substring('Bad state: '.length);
    }

    if (message.startsWith('Exception: ')) {
      return message.substring('Exception: '.length);
    }

    if (message.isEmpty) {
      return 'Unable to load orders. Please try again.';
    }

    return message;
  }

  @override
  void dispose() {
    _disposed = true;
    _ordersSubscription?.cancel();
    super.dispose();
  }
}
