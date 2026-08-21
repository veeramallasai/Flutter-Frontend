import 'package:farm_to_home_app/data/models/cart_item_model.dart';
import 'package:farm_to_home_app/data/models/cart_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('cart totals, savings and quantity are calculated correctly', () {
    const CartItemModel item = CartItemModel(
      id: 'cart-item-1',
      productId: 'vegetable_tomato',
      name: 'Tomato (టమాటా)',
      imageUrl: 'assets/images/vegetables/tomato.png',
      category: 'vegetables',
      unit: '500 g',
      shoppingMode: 'home',
      unitPrice: 40,
      mrp: 50,
      quantity: 2,
      farmerId: 'farmer_green_valley',
    );

    final CartModel cart = CartModel(
      userId: 'test-user',
      shoppingMode: 'home',
      items: const <CartItemModel>[item],
      couponCode: 'FRESH10',
      couponDiscount: 8,
    );

    expect(cart.itemCount, 2);
    expect(cart.subtotal, 80);
    expect(cart.productSavings, 20);
    expect(cart.total, 72);
  });
}
