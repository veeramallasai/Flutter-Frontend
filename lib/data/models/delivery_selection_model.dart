class DeliverySelectionModel {
  const DeliverySelectionModel({
    required this.shoppingMode,
    required this.method,
    required this.slotId,
    required this.slotLabel,
    required this.deliveryFee,
    this.deliveryDate,
    this.instructions = '',
    this.createdAt,
  });

  final String shoppingMode;
  final String method;
  final DateTime? deliveryDate;
  final String slotId;
  final String slotLabel;
  final double deliveryFee;
  final String instructions;
  final DateTime? createdAt;

  factory DeliverySelectionModel.fromMap(Map<String, dynamic> map) {
    return DeliverySelectionModel(
      shoppingMode:
          _text(map['shoppingMode']).toLowerCase() == 'shop' ? 'shop' : 'home',
      method: _text(map['method'], fallback: 'quick').toLowerCase(),
      deliveryDate: _toDateTime(map['deliveryDate']),
      slotId: _text(map['slotId']),
      slotLabel: _text(map['slotLabel'], fallback: 'Earliest available'),
      deliveryFee: _toDouble(map['deliveryFee']),
      instructions: _text(map['instructions']),
      createdAt: _toDateTime(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
    'shoppingMode': shoppingMode,
    'method': method,
    if (deliveryDate != null) 'deliveryDate': deliveryDate!.toIso8601String(),
    'slotId': slotId,
    'slotLabel': slotLabel,
    'deliveryFee': deliveryFee,
    'instructions': instructions,
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
  };

  DeliverySelectionModel copyWith({
    String? shoppingMode,
    String? method,
    DateTime? deliveryDate,
    String? slotId,
    String? slotLabel,
    double? deliveryFee,
    String? instructions,
    DateTime? createdAt,
  }) {
    return DeliverySelectionModel(
      shoppingMode: shoppingMode ?? this.shoppingMode,
      method: method ?? this.method,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      slotId: slotId ?? this.slotId,
      slotLabel: slotLabel ?? this.slotLabel,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      instructions: instructions ?? this.instructions,
      createdAt: createdAt ?? this.createdAt,
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
