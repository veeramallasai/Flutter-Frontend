import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/models/cart_model.dart';
import '../data/models/product_model.dart';
import '../data/repositories/cart_repository.dart';

class CartProvider extends ChangeNotifier {
  CartProvider({CartRepository? repository})
    : _repository = repository ?? CartRepository();

  final CartRepository _repository;
  StreamSubscription<CartModel>? _subscription;
  CartModel? _cart;
  bool _isLoading = false;
  bool _isUpdating = false;
  String? _errorMessage;
  bool _disposed = false;

  CartModel? get cart => _cart;
  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage?.trim().isNotEmpty ?? false;
  int get itemCount => _cart?.itemCount ?? 0;
  double get subtotal => _cart?.subtotal ?? 0;
  double get productSavings => _cart?.productSavings ?? 0;
  double get total => _cart?.total ?? 0;

  void listenToCart() {
    _subscription?.cancel();
    _isLoading = true;
    _errorMessage = null;
    _notify();

    try {
      _subscription = _repository.watchCart().listen(
        (CartModel value) {
          if (_disposed) return;
          _cart = value;
          _isLoading = false;
          _errorMessage = null;
          _notify();
        },
        onError: (Object error, StackTrace stackTrace) {
          if (_disposed) return;
          _isLoading = false;
          _errorMessage = _friendlyError(error);
          _notify();
        },
      );
    } catch (error) {
      _isLoading = false;
      _errorMessage = _friendlyError(error);
      _notify();
    }
  }

  Future<bool> addProduct(
    ProductModel product, {
    int quantity = 1,
    String? unit,
    String? shoppingMode,
  }) {
    return _run(
      () => _repository.addProduct(
        product,
        quantity: quantity,
        unit: unit,
        shoppingMode: shoppingMode,
      ),
    );
  }

  Future<bool> updateQuantity(String itemId, int quantity) {
    return _run(() => _repository.updateQuantity(itemId, quantity));
  }

  Future<bool> removeItem(String itemId) {
    return _run(() => _repository.removeItem(itemId));
  }

  Future<bool> applyCoupon(String couponCode, double discount) {
    return _run(() => _repository.applyCoupon(couponCode, discount));
  }

  Future<bool> clearCart() {
    return _run(_repository.clearCart);
  }

  Future<bool> _run(Future<void> Function() action) async {
    if (_isUpdating) return false;
    _isUpdating = true;
    _errorMessage = null;
    _notify();
    try {
      await action();
      _cart = await _repository.getCart();
      return true;
    } catch (error) {
      _errorMessage = _friendlyError(error);
      return false;
    } finally {
      _isUpdating = false;
      _notify();
    }
  }

  void clearError() {
    _errorMessage = null;
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  String _friendlyError(Object error) {
    String message = error.toString().trim();
    if (message.startsWith('Bad state: ')) {
      message = message.substring('Bad state: '.length);
    }
    return message.isEmpty ? 'Unable to update cart.' : message;
  }

  @override
  void dispose() {
    _disposed = true;
    _subscription?.cancel();
    super.dispose();
  }
}
