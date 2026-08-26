class ProductUnitModel {
  const ProductUnitModel({
    required this.id,
    required this.label,
    this.shortLabel = '',
    this.quantity = 1,
    this.unitType = 'piece',
    this.priceMultiplier = 1,
    this.isDefault = false,
    this.isActive = true,
  });

  final String id;
  final String label;
  final String shortLabel;
  final double quantity;
  final String unitType;
  final double priceMultiplier;
  final bool isDefault;
  final bool isActive;

  String get displayLabel => shortLabel.isEmpty ? label : shortLabel;
  double priceFor(double basePrice) => basePrice * priceMultiplier;

  factory ProductUnitModel.fromMap(Map<String, dynamic> map) =>
      ProductUnitModel(
        id: _text(map['id'] ?? map['value']),
        label: _text(map['label'] ?? map['name'], fallback: '1 piece'),
        shortLabel: _text(map['shortLabel']),
        quantity: _number(map['quantity'], fallback: 1),
        unitType: _text(map['unitType'] ?? map['type'], fallback: 'piece'),
        priceMultiplier: _number(
          map['priceMultiplier'] ?? map['multiplier'],
          fallback: 1,
        ),
        isDefault: _boolean(map['isDefault']),
        isActive: _boolean(map['isActive'] ?? map['active'], fallback: true),
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
    'id': id,
    'label': label,
    'shortLabel': shortLabel,
    'quantity': quantity,
    'unitType': unitType,
    'priceMultiplier': priceMultiplier,
    'isDefault': isDefault,
    'isActive': isActive,
  };

  ProductUnitModel copyWith({
    String? id,
    String? label,
    String? shortLabel,
    double? quantity,
    String? unitType,
    double? priceMultiplier,
    bool? isDefault,
    bool? isActive,
  }) => ProductUnitModel(
    id: id ?? this.id,
    label: label ?? this.label,
    shortLabel: shortLabel ?? this.shortLabel,
    quantity: quantity ?? this.quantity,
    unitType: unitType ?? this.unitType,
    priceMultiplier: priceMultiplier ?? this.priceMultiplier,
    isDefault: isDefault ?? this.isDefault,
    isActive: isActive ?? this.isActive,
  );
}

String _text(dynamic value, {String fallback = ''}) {
  final String result = value?.toString().trim() ?? '';
  return result.isEmpty ? fallback : result;
}

double _number(dynamic value, {double fallback = 0}) =>
    value is num ? value.toDouble() : double.tryParse('$value') ?? fallback;
bool _boolean(dynamic value, {bool fallback = false}) =>
    value is bool
        ? value
        : value == null
        ? fallback
        : <String>{'true', '1', 'yes'}.contains('$value'.toLowerCase());
