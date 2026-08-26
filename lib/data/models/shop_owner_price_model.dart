import 'package:cloud_firestore/cloud_firestore.dart';

class ShopOwnerPriceModel {
  const ShopOwnerPriceModel({
    required this.id,
    required this.productId,
    this.unit = '1 unit',
    this.minimumQuantity = 1,
    this.price = 0,
    this.mrp = 0,
    this.isActive = true,
    this.updatedAt,
  });

  final String id;
  final String productId;
  final String unit;
  final int minimumQuantity;
  final double price;
  final double mrp;
  final bool isActive;
  final DateTime? updatedAt;

  double get savings => mrp > price ? mrp - price : 0;
  int get discountPercent =>
      mrp > price && mrp > 0 ? (savings * 100 / mrp).round() : 0;

  factory ShopOwnerPriceModel.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) => ShopOwnerPriceModel.fromMap(
    doc.data() ?? <String, dynamic>{},
    documentId: doc.id,
  );

  factory ShopOwnerPriceModel.fromMap(
    Map<String, dynamic> map, {
    String documentId = '',
  }) {
    final double price = _number(map['price'] ?? map['wholesalePrice']);
    final double inputMrp = _number(map['mrp'] ?? map['retailPrice']);
    return ShopOwnerPriceModel(
      id: _text(documentId.isNotEmpty ? documentId : map['id']),
      productId: _text(map['productId']),
      unit: _text(map['unit'], fallback: '1 unit'),
      minimumQuantity: _integer(
        map['minimumQuantity'] ?? map['minQuantity'],
        fallback: 1,
      ),
      price: price,
      mrp: inputMrp < price ? price : inputMrp,
      isActive: _boolean(map['isActive'] ?? map['active'], fallback: true),
      updatedAt: _date(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
    'id': id,
    'productId': productId,
    'unit': unit,
    'minimumQuantity': minimumQuantity,
    'price': price,
    'mrp': mrp,
    'isActive': isActive,
    if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
  };

  ShopOwnerPriceModel copyWith({
    String? id,
    String? productId,
    String? unit,
    int? minimumQuantity,
    double? price,
    double? mrp,
    bool? isActive,
    DateTime? updatedAt,
  }) => ShopOwnerPriceModel(
    id: id ?? this.id,
    productId: productId ?? this.productId,
    unit: unit ?? this.unit,
    minimumQuantity: minimumQuantity ?? this.minimumQuantity,
    price: price ?? this.price,
    mrp: mrp ?? this.mrp,
    isActive: isActive ?? this.isActive,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}

String _text(dynamic value, {String fallback = ''}) {
  final String result = value?.toString().trim() ?? '';
  return result.isEmpty ? fallback : result;
}

double _number(dynamic value) =>
    value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
int _integer(dynamic value, {int fallback = 0}) =>
    value is num ? value.toInt() : int.tryParse('$value') ?? fallback;
bool _boolean(dynamic value, {bool fallback = false}) =>
    value is bool
        ? value
        : value == null
        ? fallback
        : <String>{'true', '1', 'yes'}.contains('$value'.toLowerCase());
DateTime? _date(dynamic value) =>
    value is Timestamp
        ? value.toDate()
        : value is DateTime
        ? value
        : DateTime.tryParse(value?.toString() ?? '');
