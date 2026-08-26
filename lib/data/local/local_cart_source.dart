import 'dart:async';

import '../models/cart_item_model.dart';
import '../models/cart_model.dart';

class LocalCartSource {
  final Map<String, CartModel> _carts = <String, CartModel>{};
  final StreamController<CartModel> _changes =
      StreamController<CartModel>.broadcast();

  CartModel getCart(String userId, {String shoppingMode = 'home'}) {
    final String id = _userId(userId);
    return _carts[id] ?? CartModel.empty(id, shoppingMode: shoppingMode);
  }

  Stream<CartModel> watchCart(
    String userId, {
    String shoppingMode = 'home',
  }) async* {
    final String id = _userId(userId);
    yield getCart(id, shoppingMode: shoppingMode);
    yield* _changes.stream.where((CartModel cart) => cart.userId == id);
  }

  Future<void> saveCart(CartModel cart) async {
    final String id = _userId(cart.userId);
    final CartModel updated = cart.copyWith(updatedAt: DateTime.now());
    _carts[id] = updated;
    _changes.add(updated);
  }

  Future<void> addItem(String userId, CartItemModel item) async {
    final CartModel cart = getCart(userId, shoppingMode: item.shoppingMode);
    final List<CartItemModel> items = List<CartItemModel>.from(cart.items);
    final int index = items.indexWhere(
      (CartItemModel value) => value.id == item.id,
    );
    if (index < 0) {
      items.add(item);
    } else {
      items[index] = items[index].copyWith(
        quantity: items[index].quantity + item.quantity,
      );
    }
    await saveCart(
      cart.copyWith(items: items, shoppingMode: item.shoppingMode),
    );
  }

  Future<void> updateQuantity(
    String userId,
    String itemId,
    int quantity,
  ) async {
    final CartModel cart = getCart(userId);
    final List<CartItemModel> items = cart.items
        .where((CartItemModel item) => item.id != itemId || quantity > 0)
        .map(
          (CartItemModel item) =>
              item.id == itemId ? item.copyWith(quantity: quantity) : item,
        )
        .toList(growable: false);
    await saveCart(cart.copyWith(items: items));
  }

  Future<void> removeItem(String userId, String itemId) =>
      updateQuantity(userId, itemId, 0);

  Future<void> clearCart(String userId) async {
    final CartModel cart = getCart(userId);
    await saveCart(
      cart.copyWith(
        items: <CartItemModel>[],
        couponCode: '',
        couponDiscount: 0,
      ),
    );
  }

  String _userId(String value) {
    final String id = value.trim();
    if (id.isEmpty) throw ArgumentError('User ID cannot be empty.');
    return id;
  }

  Future<void> dispose() => _changes.close();
}
