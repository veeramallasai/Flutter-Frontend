import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/utils/product_utils.dart';

class ProductModel {
  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.imageUrl,
    required List<String> images,
    required this.shoppingMode,
    required this.unit,
    required this.price,
    required this.mrp,
    required this.stockQuantity,
    required this.inStock,
    required this.isFresh,
    required this.rating,
    required this.reviewCount,
    required this.farmerId,
    required Map<String, String> nutritionInfo,
    required List<String> benefits,
    this.createdAt,
    this.updatedAt,
  })  : images = List<String>.unmodifiable(images),
        nutritionInfo = Map<String, String>.unmodifiable(nutritionInfo),
        benefits = List<String>.unmodifiable(benefits);

  final String id;
  final String name;
  final String description;
  final String category;
  final String imageUrl;
  final List<String> images;
  final String shoppingMode;
  final String unit;
  final double price;
  final double mrp;
  final int stockQuantity;
  final bool inStock;
  final bool isFresh;
  final double rating;
  final int reviewCount;
  final String farmerId;
  final Map<String, String> nutritionInfo;
  final List<String> benefits;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isShopProduct => shoppingMode == 'shop';
  bool get isHomeProduct => !isShopProduct;
  double get savings => mrp > price ? mrp - price : 0;
  int get discountPercent =>
      mrp > price && mrp > 0 ? (((mrp - price) / mrp) * 100).round() : 0;
  List<String> get allImages {
    final List<String> values = <String>[
      imageUrl,
      ...images,
    ].where((String value) => value.trim().isNotEmpty).toSet().toList();
    return List<String>.unmodifiable(values);
  }

  factory ProductModel.fromDocument(
      DocumentSnapshot<Map<String, dynamic>> document,
      ) {
    return ProductModel.fromMap(
      document.data() ?? <String, dynamic>{},
      documentId: document.id,
    );
  }

  factory ProductModel.fromMap(
      Map<String, dynamic> map, {
        String documentId = '',
      }) {
    final double price = _toDouble(map['price'] ?? map['unitPrice']);
    double mrp = _toDouble(map['mrp'], fallback: price);
    if (mrp < price) mrp = price;

    return ProductModel(
      id: _text(documentId.isNotEmpty ? documentId : map['id']),
      name: ProductUtils.localizedName(
        _text(map['name'], fallback: 'Fresh Product'),
      ),
      description: _text(map['description']),
      category: _text(map['category']),
      imageUrl: _text(map['imageUrl'] ?? map['image']),
      images: _stringList(map['images'] ?? map['imageUrls']),
      shoppingMode:
      _text(map['shoppingMode']).toLowerCase() == 'shop' ? 'shop' : 'home',
      unit: _text(map['unit'], fallback: '1 unit'),
      price: price,
      mrp: mrp,
      stockQuantity: _toInt(map['stockQuantity'] ?? map['stock']),
      inStock: _toBool(map['inStock'], fallback: true),
      isFresh: _toBool(map['isFresh'], fallback: true),
      rating: _toDouble(map['rating']),
      reviewCount: _toInt(map['reviewCount'] ?? map['reviews']),
      farmerId: _text(map['farmerId']),
      nutritionInfo: _stringMap(map['nutritionInfo']),
      benefits: _stringList(map['benefits']),
      createdAt: _toDateTime(map['createdAt']),
      updatedAt: _toDateTime(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'imageUrl': imageUrl,
      'images': images,
      'shoppingMode': shoppingMode,
      'unit': unit,
      'price': price,
      'mrp': mrp,
      'stockQuantity': stockQuantity,
      'inStock': inStock,
      'isFresh': isFresh,
      'rating': rating,
      'reviewCount': reviewCount,
      'farmerId': farmerId,
      'nutritionInfo': nutritionInfo,
      'benefits': benefits,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }

  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? imageUrl,
    List<String>? images,
    String? shoppingMode,
    String? unit,
    double? price,
    double? mrp,
    int? stockQuantity,
    bool? inStock,
    bool? isFresh,
    double? rating,
    int? reviewCount,
    String? farmerId,
    Map<String, String>? nutritionInfo,
    List<String>? benefits,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: ProductUtils.localizedName(name ?? this.name),
      description: description ?? this.description,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      images: images ?? this.images,
      shoppingMode: shoppingMode ?? this.shoppingMode,
      unit: unit ?? this.unit,
      price: price ?? this.price,
      mrp: mrp ?? this.mrp,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      inStock: inStock ?? this.inStock,
      isFresh: isFresh ?? this.isFresh,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      farmerId: farmerId ?? this.farmerId,
      nutritionInfo: nutritionInfo ?? this.nutritionInfo,
      benefits: benefits ?? this.benefits,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

String _text(dynamic value, {String fallback = ''}) {
  final String text = value?.toString().trim() ?? '';
  return text.isEmpty ? fallback : text;
}

double _toDouble(dynamic value, {double fallback = 0}) {
  if (value is num) return value.toDouble();
  final String cleaned = value
      ?.toString()
      .replaceAll(',', '')
      .replaceAll(RegExp(r'[^0-9.\-]'), '') ??
      '';
  return double.tryParse(cleaned) ?? fallback;
}

int _toInt(dynamic value, {int fallback = 0}) {
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

bool _toBool(dynamic value, {bool fallback = false}) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final String text = _text(value).toLowerCase();
  if (<String>{'true', 'yes', '1'}.contains(text)) return true;
  if (<String>{'false', 'no', '0'}.contains(text)) return false;
  return fallback;
}

List<String> _stringList(dynamic value) {
  if (value is! Iterable) return <String>[];
  return value
      .map(_text)
      .where((String item) => item.isNotEmpty)
      .toList(growable: false);
}

Map<String, String> _stringMap(dynamic value) {
  if (value is! Map) return <String, String>{};
  return value.map(
        (dynamic key, dynamic item) =>
        MapEntry<String, String>(_text(key), _text(item)),
  )..removeWhere((String key, String item) => key.isEmpty || item.isEmpty);
}

DateTime? _toDateTime(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  return DateTime.tryParse(value?.toString() ?? '');
}
