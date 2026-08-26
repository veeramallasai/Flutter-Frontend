class OfferModel {
  const OfferModel({
    required this.id,
    required this.title,
    this.description = '',
    this.code = '',
    this.discountType = 'percentage',
    this.discountValue = 0,
    this.minimumOrder = 0,
    this.maximumDiscount = 0,
    this.imageUrl = '',
    this.isActive = true,
    this.startsAt,
    this.endsAt,
  });

  final String id;
  final String title;
  final String description;
  final String code;
  final String discountType;
  final double discountValue;
  final double minimumOrder;
  final double maximumDiscount;
  final String imageUrl;
  final bool isActive;
  final DateTime? startsAt;
  final DateTime? endsAt;

  bool get isAvailable {
    final DateTime now = DateTime.now();
    return isActive &&
        (startsAt == null || !now.isBefore(startsAt!)) &&
        (endsAt == null || !now.isAfter(endsAt!));
  }

  factory OfferModel.fromDocument(dynamic doc) {
    if (doc is Map<String, dynamic>) {
      return OfferModel.fromMap(doc, documentId: (doc['id'] ?? '').toString());
    }
    try {
      final map = (doc as dynamic).data() as Map<String, dynamic>? ?? <String, dynamic>{};
      return OfferModel.fromMap(map, documentId: doc.id.toString());
    } catch (_) {
      return const OfferModel(id: '', title: '');
    }
  }

  factory OfferModel.fromMap(
    Map<String, dynamic> map, {
    String documentId = '',
  }) => OfferModel(
    id: _text(documentId.isNotEmpty ? documentId : map['id']),
    title: _text(map['title'], fallback: 'Special Offer'),
    description: _text(map['description']),
    code: _text(map['code']).toUpperCase(),
    discountType: _text(
      map['discountType'] ?? map['type'],
      fallback: 'percentage',
    ),
    discountValue: _number(map['discountValue'] ?? map['value']),
    minimumOrder: _number(map['minimumOrder'] ?? map['minOrder']),
    maximumDiscount: _number(map['maximumDiscount'] ?? map['maxDiscount']),
    imageUrl: _text(map['imageUrl'] ?? map['image']),
    isActive: _boolean(map['isActive'] ?? map['active'], fallback: true),
    startsAt: _date(map['startsAt'] ?? map['startDate']),
    endsAt: _date(map['endsAt'] ?? map['endDate']),
  );

  Map<String, dynamic> toMap() => <String, dynamic>{
    'id': id,
    'title': title,
    'description': description,
    'code': code,
    'discountType': discountType,
    'discountValue': discountValue,
    'minimumOrder': minimumOrder,
    'maximumDiscount': maximumDiscount,
    'imageUrl': imageUrl,
    'isActive': isActive,
    if (startsAt != null) 'startsAt': startsAt!.toIso8601String(),
    if (endsAt != null) 'endsAt': endsAt!.toIso8601String(),
  };

  OfferModel copyWith({
    String? id,
    String? title,
    String? description,
    String? code,
    String? discountType,
    double? discountValue,
    double? minimumOrder,
    double? maximumDiscount,
    String? imageUrl,
    bool? isActive,
    DateTime? startsAt,
    DateTime? endsAt,
  }) => OfferModel(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    code: code ?? this.code,
    discountType: discountType ?? this.discountType,
    discountValue: discountValue ?? this.discountValue,
    minimumOrder: minimumOrder ?? this.minimumOrder,
    maximumDiscount: maximumDiscount ?? this.maximumDiscount,
    imageUrl: imageUrl ?? this.imageUrl,
    isActive: isActive ?? this.isActive,
    startsAt: startsAt ?? this.startsAt,
    endsAt: endsAt ?? this.endsAt,
  );
}

String _text(dynamic value, {String fallback = ''}) {
  final String result = value?.toString().trim() ?? '';
  return result.isEmpty ? fallback : result;
}

double _number(dynamic value) =>
    value is num ? value.toDouble() : double.tryParse('$value') ?? 0;

bool _boolean(dynamic value, {bool fallback = false}) =>
    value is bool
        ? value
        : value == null
        ? fallback
        : <String>{'true', '1', 'yes'}.contains('$value'.toLowerCase());

DateTime? _date(dynamic value) =>
    value is DateTime
        ? value
        : DateTime.tryParse(value?.toString() ?? '');
