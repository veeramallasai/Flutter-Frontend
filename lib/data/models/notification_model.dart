import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    this.type = 'general',
    this.imageUrl = '',
    this.route = '',
    Map<String, dynamic> data = const <String, dynamic>{},
    this.isRead = false,
    this.createdAt,
  }) : data = Map<String, dynamic>.unmodifiable(data);

  final String id;
  final String userId;
  final String title;
  final String body;
  final String type;
  final String imageUrl;
  final String route;
  final Map<String, dynamic> data;
  final bool isRead;
  final DateTime? createdAt;

  bool get hasAction => route.isNotEmpty || data.isNotEmpty;

  factory NotificationModel.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) =>
      NotificationModel.fromMap(doc.data() ?? <String, dynamic>{}, documentId: doc.id);

  factory NotificationModel.fromMap(Map<String, dynamic> map, {String documentId = ''}) => NotificationModel(
        id: _text(documentId.isNotEmpty ? documentId : map['id']),
        userId: _text(map['userId'] ?? map['uid']),
        title: _text(map['title'], fallback: 'Farm To Home'),
        body: _text(map['body'] ?? map['message']),
        type: _text(map['type'], fallback: 'general').toLowerCase(),
        imageUrl: _text(map['imageUrl'] ?? map['image']),
        route: _text(map['route'] ?? map['actionRoute']),
        data: _map(map['data']),
        isRead: _boolean(map['isRead'] ?? map['read']),
        createdAt: _date(map['createdAt'] ?? map['timestamp']),
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id, 'userId': userId, 'title': title, 'body': body,
        'type': type, 'imageUrl': imageUrl, 'route': route, 'data': data,
        'isRead': isRead,
        if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      };

  NotificationModel copyWith({String? id, String? userId, String? title,
      String? body, String? type, String? imageUrl, String? route,
      Map<String, dynamic>? data, bool? isRead, DateTime? createdAt}) => NotificationModel(
        id: id ?? this.id, userId: userId ?? this.userId,
        title: title ?? this.title, body: body ?? this.body,
        type: type ?? this.type, imageUrl: imageUrl ?? this.imageUrl,
        route: route ?? this.route, data: data ?? this.data,
        isRead: isRead ?? this.isRead, createdAt: createdAt ?? this.createdAt,
      );
}

String _text(dynamic value, {String fallback = ''}) {
  final String result = value?.toString().trim() ?? '';
  return result.isEmpty ? fallback : result;
}
bool _boolean(dynamic value) => value is bool ? value :
    <String>{'true', '1', 'yes'}.contains('$value'.toLowerCase());
Map<String, dynamic> _map(dynamic value) => value is Map
    ? Map<String, dynamic>.from(value) : <String, dynamic>{};
DateTime? _date(dynamic value) => value is Timestamp ? value.toDate() :
    value is DateTime ? value : DateTime.tryParse(value?.toString() ?? '');
