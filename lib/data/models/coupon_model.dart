import 'package:cloud_firestore/cloud_firestore.dart';

class CouponModel {
  const CouponModel({
    required this.id,
    required this.code,
    required this.title,
    this.description = '',
    this.discountType = 'percentage',
    this.discountValue = 0,
    this.minimumOrder = 0,
    this.maximumDiscount = 0,
    this.isActive = true,
    this.startsAt,
    this.endsAt,
    this.usageLimit = 0,
    this.usedCount = 0,
  });

  final String id;
  final String code;
  final String title;
  final String description;
  final String discountType;
  final double discountValue;
  final double minimumOrder;
  final double maximumDiscount;
  final bool isActive;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final int usageLimit;
  final int usedCount;

  bool get isCurrentlyValid {
    final DateTime now = DateTime.now();
    return isActive && (usageLimit <= 0 || usedCount < usageLimit) &&
        (startsAt == null || !now.isBefore(startsAt!)) &&
        (endsAt == null || !now.isAfter(endsAt!));
  }

  double discountFor(double subtotal) {
    if (!isCurrentlyValid || subtotal < minimumOrder) return 0;
    double discount = discountType == 'fixed'
        ? discountValue : subtotal * discountValue / 100;
    if (maximumDiscount > 0 && discount > maximumDiscount) discount = maximumDiscount;
    return discount.clamp(0, subtotal).toDouble();
  }

  factory CouponModel.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) =>
      CouponModel.fromMap(doc.data() ?? <String, dynamic>{}, documentId: doc.id);

  factory CouponModel.fromMap(Map<String, dynamic> map, {String documentId = ''}) => CouponModel(
        id: _text(documentId.isNotEmpty ? documentId : map['id']),
        code: _text(map['code']).toUpperCase(),
        title: _text(map['title'], fallback: 'Fresh savings'),
        description: _text(map['description']),
        discountType: _text(map['discountType'] ?? map['type'], fallback: 'percentage').toLowerCase(),
        discountValue: _number(map['discountValue'] ?? map['value']),
        minimumOrder: _number(map['minimumOrder'] ?? map['minOrder']),
        maximumDiscount: _number(map['maximumDiscount'] ?? map['maxDiscount']),
        isActive: _boolean(map['isActive'] ?? map['active'], fallback: true),
        startsAt: _date(map['startsAt'] ?? map['startDate']),
        endsAt: _date(map['endsAt'] ?? map['endDate']),
        usageLimit: _integer(map['usageLimit']),
        usedCount: _integer(map['usedCount']),
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id, 'code': code, 'title': title, 'description': description,
        'discountType': discountType, 'discountValue': discountValue,
        'minimumOrder': minimumOrder, 'maximumDiscount': maximumDiscount,
        'isActive': isActive, 'usageLimit': usageLimit, 'usedCount': usedCount,
        if (startsAt != null) 'startsAt': Timestamp.fromDate(startsAt!),
        if (endsAt != null) 'endsAt': Timestamp.fromDate(endsAt!),
      };

  CouponModel copyWith({String? id, String? code, String? title,
      String? description, String? discountType, double? discountValue,
      double? minimumOrder, double? maximumDiscount, bool? isActive,
      DateTime? startsAt, DateTime? endsAt, int? usageLimit, int? usedCount}) => CouponModel(
        id: id ?? this.id, code: code ?? this.code, title: title ?? this.title,
        description: description ?? this.description,
        discountType: discountType ?? this.discountType,
        discountValue: discountValue ?? this.discountValue,
        minimumOrder: minimumOrder ?? this.minimumOrder,
        maximumDiscount: maximumDiscount ?? this.maximumDiscount,
        isActive: isActive ?? this.isActive, startsAt: startsAt ?? this.startsAt,
        endsAt: endsAt ?? this.endsAt, usageLimit: usageLimit ?? this.usageLimit,
        usedCount: usedCount ?? this.usedCount,
      );
}

String _text(dynamic value, {String fallback = ''}) {
  final String result = value?.toString().trim() ?? '';
  return result.isEmpty ? fallback : result;
}
double _number(dynamic value) => value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
int _integer(dynamic value) => value is num ? value.toInt() : int.tryParse('$value') ?? 0;
bool _boolean(dynamic value, {bool fallback = false}) => value is bool ? value :
    value == null ? fallback : <String>{'true', '1', 'yes'}.contains('$value'.toLowerCase());
DateTime? _date(dynamic value) => value is Timestamp ? value.toDate() :
    value is DateTime ? value : DateTime.tryParse(value?.toString() ?? '');
