import '../../core/network/api_client.dart';
import '../../core/network/api_response.dart';
import '../models/cart_item_model.dart';
import '../models/cart_model.dart';

class CartRemoteSource {
  CartRemoteSource({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Stream<CartModel> watchCart(String userId) =>
      Stream<CartModel>.fromFuture(getCart(userId));

  Future<CartModel> getCart(String userId) async {
    final ApiResponse<dynamic> response = await _client.get('/api/v1/cart');
    return _cart(response.data, userId);
  }

  Future<void> addItem(String userId, CartItemModel item) async {
    await _client.post(
      '/api/v1/cart/items',
      body: <String, dynamic>{
        'productId': item.productId,
        'itemId': item.id,
        'shoppingMode': item.shoppingMode,
        'unit': item.unit,
        'quantity': item.quantity,
      },
    );
  }

  Future<void> updateQuantity({
    required String userId,
    required String itemId,
    required int quantity,
  }) async {
    final String key = Uri.encodeComponent(itemId.trim());
    await _client.patch(
      '/api/v1/cart/items/$key',
      body: <String, dynamic>{'quantity': quantity},
    );
  }

  Future<void> removeItem(String userId, String itemId) async {
    final String key = Uri.encodeComponent(itemId.trim());
    await _client.delete('/api/v1/cart/items/$key');
  }

  Future<void> applyCoupon({
    required String userId,
    required String couponCode,
    required double discount,
  }) async {
    await _client.post(
      '/api/v1/cart/coupon',
      body: <String, dynamic>{'couponCode': couponCode.trim().toUpperCase()},
    );
  }

  Future<void> removeCoupon(String userId) async {
    await _client.delete('/api/v1/cart/coupon');
  }

  Future<void> clearCart(String userId) async {
    await _client.delete('/api/v1/cart');
  }

  CartModel _cart(dynamic raw, String userId) {
    if (raw is! Map) return CartModel.empty(userId);
    return CartModel.fromMap(
      raw.map(
        (dynamic key, dynamic value) =>
            MapEntry<String, dynamic>(key.toString(), value),
      ),
      documentId: userId,
    );
  }
}
