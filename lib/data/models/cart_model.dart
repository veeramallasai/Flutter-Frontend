import 'cart_item_model.dart';

class CartModel {
  CartModel({
    required this.userId,
    required this.shoppingMode,
    required List<CartItemModel> items,
    this.couponCode = '',
    this.couponDiscount = 0,
    this.updatedAt,
  }) : items = List<CartItemModel>.unmodifiable(items);

  final String userId;
  final String shoppingMode;
  final List<CartItemModel> items;
  final String couponCode;
  final double couponDiscount;
  final DateTime? updatedAt;

  int get itemCount => items.fold<int>(
    0,
    (int total, CartItemModel item) => total + item.quantity,
  );
  double get subtotal => items.fold<double>(
    0,
    (double total, CartItemModel item) => total + item.subtotal,
  );
  double get productSavings => items.fold<double>(
    0,
    (double total, CartItemModel item) => total + item.savings,
  );
  double get total =>
      (subtotal - couponDiscount).clamp(0, double.infinity).toDouble();
  bool get isEmpty => items.isEmpty;

  factory CartModel.empty(String userId, {String shoppingMode = 'home'}) {
    return CartModel(
      userId: userId,
      shoppingMode: shoppingMode == 'shop' ? 'shop' : 'home',
      items: <CartItemModel>[],
    );
  }

  factory CartModel.fromDocument(
    dynamic document,
  ) {
    if (document is Map<String, dynamic>) {
      return CartModel.fromMap(document);
    }
    return CartModel.fromMap(
      (document as dynamic)?.data() as Map<String, dynamic>? ?? <String, dynamic>{},
      documentId: (document as dynamic)?.id?.toString() ?? '',
    );
  }

  factory CartModel.fromMap(
    Map<String, dynamic> map, {
    String documentId = '',
  }) {
    final dynamic rawItems = map['items'];
    final List<CartItemModel> items =
        rawItems is Iterable
            ? rawItems
                .whereType<Map>()
                .map(
                  (Map item) => CartItemModel.fromMap(
                    item.map(
                      (dynamic key, dynamic value) =>
                          MapEntry<String, dynamic>(key.toString(), value),
                    ),
                  ),
                )
                .toList(growable: false)
            : <CartItemModel>[];

    return CartModel(
      userId: _text(map['userId'], fallback: documentId),
      shoppingMode:
          _text(map['shoppingMode']).toLowerCase() == 'shop' ? 'shop' : 'home',
      items: items,
      couponCode: _text(map['couponCode']),
      couponDiscount: _toDouble(map['couponDiscount']),
      updatedAt: _toDateTime(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
    'userId': userId,
    'shoppingMode': shoppingMode,
    'items': items.map((CartItemModel item) => item.toMap()).toList(),
    'couponCode': couponCode,
    'couponDiscount': couponDiscount,
    if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
  };

  CartModel copyWith({
    String? userId,
    String? shoppingMode,
    List<CartItemModel>? items,
    String? couponCode,
    double? couponDiscount,
    DateTime? updatedAt,
  }) {
    return CartModel(
      userId: userId ?? this.userId,
      shoppingMode: shoppingMode ?? this.shoppingMode,
      items: items ?? this.items,
      couponCode: couponCode ?? this.couponCode,
      couponDiscount: couponDiscount ?? this.couponDiscount,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

String _text(dynamic value, {String fallback = ''}) {
  final String text = value?.toString().trim() ?? '';
  return text.isEmpty ? fallback : text;
}

double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

DateTime? _toDateTime(dynamic value) {
  if (value is DateTime) return value;
  return DateTime.tryParse(value?.toString() ?? '');
}
