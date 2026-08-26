import '../../core/utils/product_utils.dart';
import 'product_model.dart';

class CartItemModel {
  const CartItemModel({
    required this.id,
    required this.productId,
    required this.name,
    required this.imageUrl,
    required this.category,
    required this.unit,
    required this.shoppingMode,
    required this.unitPrice,
    required this.mrp,
    required this.quantity,
    required this.farmerId,
  });

  final String id;
  final String productId;
  final String name;
  final String imageUrl;
  final String category;
  final String unit;
  final String shoppingMode;
  final double unitPrice;
  final double mrp;
  final int quantity;
  final String farmerId;

  double get subtotal => unitPrice * quantity;
  double get mrpTotal => mrp * quantity;
  double get savings => mrpTotal > subtotal ? mrpTotal - subtotal : 0;

  factory CartItemModel.fromProduct(
    ProductModel product, {
    int quantity = 1,
    String? unit,
    String? shoppingMode,
  }) {
    final String itemUnit =
        unit?.trim().isNotEmpty == true ? unit!.trim() : product.unit;
    final String mode =
        shoppingMode?.trim().toLowerCase() == 'shop'
            ? 'shop'
            : product.shoppingMode;

    return CartItemModel(
      id: '${product.id}_${_key(itemUnit)}_$mode',
      productId: product.id,
      name: ProductUtils.localizedName(product.name),
      imageUrl: product.imageUrl,
      category: product.category,
      unit: itemUnit,
      shoppingMode: mode,
      unitPrice: product.price,
      mrp: product.mrp,
      quantity: quantity < 1 ? 1 : quantity,
      farmerId: product.farmerId,
    );
  }

  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      id: _text(map['id']),
      productId: _text(map['productId']),
      name: ProductUtils.localizedName(
        _text(map['name'], fallback: 'Fresh Product'),
      ),
      imageUrl: _text(map['imageUrl'] ?? map['image']),
      category: _text(map['category']),
      unit: _text(map['unit'], fallback: '1 unit'),
      shoppingMode:
          _text(map['shoppingMode']).toLowerCase() == 'shop' ? 'shop' : 'home',
      unitPrice: _toDouble(map['unitPrice'] ?? map['price']),
      mrp: _toDouble(map['mrp'] ?? map['unitPrice'] ?? map['price']),
      quantity: _toInt(map['quantity'], fallback: 1),
      farmerId: _text(map['farmerId']),
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
    'id': id,
    'productId': productId,
    'name': name,
    'imageUrl': imageUrl,
    'category': category,
    'unit': unit,
    'shoppingMode': shoppingMode,
    'unitPrice': unitPrice,
    'mrp': mrp,
    'quantity': quantity,
    'farmerId': farmerId,
  };

  CartItemModel copyWith({
    String? id,
    String? productId,
    String? name,
    String? imageUrl,
    String? category,
    String? unit,
    String? shoppingMode,
    double? unitPrice,
    double? mrp,
    int? quantity,
    String? farmerId,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      name: ProductUtils.localizedName(name ?? this.name),
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      unit: unit ?? this.unit,
      shoppingMode: shoppingMode ?? this.shoppingMode,
      unitPrice: unitPrice ?? this.unitPrice,
      mrp: mrp ?? this.mrp,
      quantity: quantity ?? this.quantity,
      farmerId: farmerId ?? this.farmerId,
    );
  }
}

String _key(String value) {
  return value.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
}

String _text(dynamic value, {String fallback = ''}) {
  final String text = value?.toString().trim() ?? '';
  return text.isEmpty ? fallback : text;
}

double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

int _toInt(dynamic value, {int fallback = 0}) {
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}
