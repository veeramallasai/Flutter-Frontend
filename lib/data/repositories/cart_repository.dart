import 'package:firebase_auth/firebase_auth.dart';

import '../models/cart_item_model.dart';
import '../models/cart_model.dart';
import '../models/product_model.dart';
import '../remote/cart_remote_source.dart';

class CartRepository {
  CartRepository({
    CartRemoteSource? remoteSource,
    FirebaseAuth? auth,
  })  : _remoteSource = remoteSource ?? CartRemoteSource(),
        _auth = auth ?? FirebaseAuth.instance;

  final CartRemoteSource _remoteSource;
  final FirebaseAuth _auth;

  String? get currentUserId => _auth.currentUser?.uid;

  Stream<CartModel> watchCart() {
    return _remoteSource.watchCart(_requireUserId());
  }

  Future<CartModel> getCart() {
    return _remoteSource.getCart(_requireUserId());
  }

  Future<void> addProduct(
      ProductModel product, {
        int quantity = 1,
        String? unit,
        String? shoppingMode,
      }) {
    final CartItemModel item = CartItemModel.fromProduct(
      product,
      quantity: quantity,
      unit: unit,
      shoppingMode: shoppingMode,
    );
    return _remoteSource.addItem(_requireUserId(), item);
  }

  Future<void> updateQuantity(String itemId, int quantity) {
    return _remoteSource.updateQuantity(
      userId: _requireUserId(),
      itemId: itemId,
      quantity: quantity,
    );
  }

  Future<void> removeItem(String itemId) {
    return _remoteSource.removeItem(_requireUserId(), itemId);
  }

  Future<void> applyCoupon(String couponCode, double discount) {
    return _remoteSource.applyCoupon(
      userId: _requireUserId(),
      couponCode: couponCode,
      discount: discount,
    );
  }

  Future<void> removeCoupon() {
    return _remoteSource.removeCoupon(_requireUserId());
  }

  Future<void> clearCart() {
    return _remoteSource.clearCart(_requireUserId());
  }

  String _requireUserId() {
    final String userId = currentUserId?.trim() ?? '';
    if (userId.isEmpty) throw StateError('Please login to continue.');
    return userId;
  }
}
