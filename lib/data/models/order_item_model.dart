import '../../core/utils/product_utils.dart';

class OrderItemModel {
  const OrderItemModel({
    required this.cartItemId,
    required this.productId,
    required this.name,
    required this.category,
    required this.imageUrl,
    required this.shoppingMode,
    required this.unit,
    required this.unitPrice,
    required this.mrp,
    required this.quantity,
    required this.inStock,
  });

  final String cartItemId;
  final String productId;
  final String name;
  final String category;
  final String imageUrl;
  final String shoppingMode;
  final String unit;
  final double unitPrice;
  final double mrp;
  final int quantity;
  final bool inStock;

  double get lineTotal => unitPrice * quantity;

  double get lineMrp => mrp * quantity;

  double get savings {
    final double value = lineMrp - lineTotal;
    return value < 0 ? 0 : value;
  }

  bool get isShopOrder => shoppingMode == 'shop';

  bool get isHomeOrder => !isShopOrder;

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    final double unitPrice = _toDouble(map['unitPrice'] ?? map['price']);

    double mrp = _toDouble(map['mrp'], fallback: unitPrice);

    if (mrp < unitPrice) {
      mrp = unitPrice;
    }

    return OrderItemModel(
      cartItemId: _text(map['cartItemId'] ?? map['documentId']),
      productId: _text(map['productId']),
      name: ProductUtils.localizedName(
        _text(map['name'] ?? map['productName'], fallback: 'Fresh Product'),
      ),
      category: _text(map['category']),
      imageUrl: _text(map['imageUrl'] ?? map['image']),
      shoppingMode: _normalizeShoppingMode(map['shoppingMode']),
      unit: _text(map['unit'], fallback: '1 unit'),
      unitPrice: unitPrice,
      mrp: mrp,
      quantity: _positiveInt(map['quantity'], fallback: 1),
      inStock: _toBool(map['inStock'], fallback: true),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'cartItemId': cartItemId,
      'productId': productId,
      'name': name,
      'category': category,
      'imageUrl': imageUrl,
      'shoppingMode': shoppingMode,
      'unit': unit,
      'unitPrice': unitPrice,
      'mrp': mrp,
      'quantity': quantity,
      'lineTotal': lineTotal,
      'inStock': inStock,
    };
  }

  OrderItemModel copyWith({
    String? cartItemId,
    String? productId,
    String? name,
    String? category,
    String? imageUrl,
    String? shoppingMode,
    String? unit,
    double? unitPrice,
    double? mrp,
    int? quantity,
    bool? inStock,
  }) {
    return OrderItemModel(
      cartItemId: cartItemId ?? this.cartItemId,
      productId: productId ?? this.productId,
      name: ProductUtils.localizedName(name ?? this.name),
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      shoppingMode:
          shoppingMode == null
              ? this.shoppingMode
              : _normalizeShoppingMode(shoppingMode),
      unit: unit ?? this.unit,
      unitPrice: unitPrice ?? this.unitPrice,
      mrp: mrp ?? this.mrp,
      quantity: quantity ?? this.quantity,
      inStock: inStock ?? this.inStock,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is OrderItemModel &&
        other.cartItemId == cartItemId &&
        other.productId == productId &&
        other.name == name &&
        other.category == category &&
        other.imageUrl == imageUrl &&
        other.shoppingMode == shoppingMode &&
        other.unit == unit &&
        other.unitPrice == unitPrice &&
        other.mrp == mrp &&
        other.quantity == quantity &&
        other.inStock == inStock;
  }

  @override
  int get hashCode {
    return Object.hash(
      cartItemId,
      productId,
      name,
      category,
      imageUrl,
      shoppingMode,
      unit,
      unitPrice,
      mrp,
      quantity,
      inStock,
    );
  }

  @override
  String toString() {
    return 'OrderItemModel('
        'productId: $productId, '
        'name: $name, '
        'quantity: $quantity, '
        'unitPrice: $unitPrice'
        ')';
  }
}

String _normalizeShoppingMode(dynamic value) {
  return _text(value).toLowerCase() == 'shop' ? 'shop' : 'home';
}

String _text(dynamic value, {String fallback = ''}) {
  if (value == null) {
    return fallback;
  }

  final String text = value.toString().trim();
  return text.isEmpty ? fallback : text;
}

double _toDouble(dynamic value, {double fallback = 0}) {
  if (value is num) {
    return value.toDouble();
  }

  final String cleaned =
      value
          ?.toString()
          .replaceAll(',', '')
          .replaceAll(RegExp(r'[^0-9.\-]'), '') ??
      '';

  return double.tryParse(cleaned) ?? fallback;
}

int _positiveInt(dynamic value, {int fallback = 1}) {
  final int parsed;

  if (value is num) {
    parsed = value.toInt();
  } else {
    parsed = int.tryParse(value?.toString().trim() ?? '') ?? fallback;
  }

  return parsed < 1 ? fallback : parsed;
}

bool _toBool(dynamic value, {bool fallback = false}) {
  if (value is bool) {
    return value;
  }

  if (value is num) {
    return value != 0;
  }

  final String normalized = _text(value).toLowerCase();

  if (normalized == 'true' || normalized == 'yes' || normalized == '1') {
    return true;
  }

  if (normalized == 'false' || normalized == 'no' || normalized == '0') {
    return false;
  }

  return fallback;
}
