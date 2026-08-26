import 'package:cloud_firestore/cloud_firestore.dart';

class BannerModel {
  const BannerModel({
    required this.id,
    required this.title,
    this.subtitle = '',
    this.imageUrl = '',
    this.actionLabel = '',
    this.route = '',
    this.priority = 0,
    this.isActive = true,
    this.startsAt,
    this.endsAt,
  });

  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String actionLabel;
  final String route;
  final int priority;
  final bool isActive;
  final DateTime? startsAt;
  final DateTime? endsAt;

  bool get isVisible {
    final DateTime now = DateTime.now();
    return isActive &&
        (startsAt == null || !now.isBefore(startsAt!)) &&
        (endsAt == null || !now.isAfter(endsAt!));
  }

  factory BannerModel.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) => BannerModel.fromMap(
    doc.data() ?? <String, dynamic>{},
    documentId: doc.id,
  );

  factory BannerModel.fromMap(
    Map<String, dynamic> map, {
    String documentId = '',
  }) => BannerModel(
    id: _text(documentId.isNotEmpty ? documentId : map['id']),
    title: _text(map['title'], fallback: 'Farm Fresh Everyday'),
    subtitle: _text(map['subtitle'] ?? map['description']),
    imageUrl: _text(map['imageUrl'] ?? map['image']),
    actionLabel: _text(map['actionLabel'] ?? map['buttonText']),
    route: _text(map['route'] ?? map['actionRoute']),
    priority: _integer(map['priority'] ?? map['sortOrder']),
    isActive: _boolean(map['isActive'] ?? map['active'], fallback: true),
    startsAt: _date(map['startsAt'] ?? map['startDate']),
    endsAt: _date(map['endsAt'] ?? map['endDate']),
  );

  Map<String, dynamic> toMap() => <String, dynamic>{
    'id': id,
    'title': title,
    'subtitle': subtitle,
    'imageUrl': imageUrl,
    'actionLabel': actionLabel,
    'route': route,
    'priority': priority,
    'isActive': isActive,
    if (startsAt != null) 'startsAt': Timestamp.fromDate(startsAt!),
    if (endsAt != null) 'endsAt': Timestamp.fromDate(endsAt!),
  };

  BannerModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? imageUrl,
    String? actionLabel,
    String? route,
    int? priority,
    bool? isActive,
    DateTime? startsAt,
    DateTime? endsAt,
  }) => BannerModel(
    id: id ?? this.id,
    title: title ?? this.title,
    subtitle: subtitle ?? this.subtitle,
    imageUrl: imageUrl ?? this.imageUrl,
    actionLabel: actionLabel ?? this.actionLabel,
    route: route ?? this.route,
    priority: priority ?? this.priority,
    isActive: isActive ?? this.isActive,
    startsAt: startsAt ?? this.startsAt,
    endsAt: endsAt ?? this.endsAt,
  );
}

String _text(dynamic value, {String fallback = ''}) {
  final String result = value?.toString().trim() ?? '';
  return result.isEmpty ? fallback : result;
}

int _integer(dynamic value) =>
    value is num ? value.toInt() : int.tryParse('$value') ?? 0;
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
