class SupportTicketModel {
  const SupportTicketModel({
    required this.id,
    required this.userId,
    required this.subject,
    required this.message,
    this.category = 'general',
    this.status = 'open',
    this.priority = 'normal',
    this.response = '',
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String userId;
  final String subject;
  final String message;
  final String category;
  final String status;
  final String priority;
  final String response;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isOpen => <String>{'open', 'in_progress'}.contains(status);
  String get statusLabel => status
      .split('_')
      .map(
        (String word) =>
            word.isEmpty
                ? word
                : '${word[0].toUpperCase()}${word.substring(1)}',
      )
      .join(' ');

  factory SupportTicketModel.fromDocument(dynamic doc) {
    if (doc is Map<String, dynamic>) {
      return SupportTicketModel.fromMap(doc, documentId: (doc['id'] ?? '').toString());
    }
    try {
      final map = (doc as dynamic).data() as Map<String, dynamic>? ?? <String, dynamic>{};
      return SupportTicketModel.fromMap(map, documentId: doc.id.toString());
    } catch (_) {
      return const SupportTicketModel(
        id: '',
        userId: '',
        subject: '',
        message: '',
      );
    }
  }

  factory SupportTicketModel.fromMap(
    Map<String, dynamic> map, {
    String documentId = '',
  }) => SupportTicketModel(
    id: _text(documentId.isNotEmpty ? documentId : map['id']),
    userId: _text(map['userId'] ?? map['uid']),
    subject: _text(map['subject'], fallback: 'Support request'),
    message: _text(map['message'] ?? map['description']),
    category: _text(map['category'], fallback: 'general').toLowerCase(),
    status: _text(map['status'], fallback: 'open').toLowerCase(),
    priority: _text(map['priority'], fallback: 'normal').toLowerCase(),
    response: _text(map['response'] ?? map['resolution']),
    createdAt: _date(map['createdAt']),
    updatedAt: _date(map['updatedAt']),
  );

  Map<String, dynamic> toMap() => <String, dynamic>{
    'id': id,
    'userId': userId,
    'subject': subject,
    'message': message,
    'category': category,
    'status': status,
    'priority': priority,
    'response': response,
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
  };

  SupportTicketModel copyWith({
    String? id,
    String? userId,
    String? subject,
    String? message,
    String? category,
    String? status,
    String? priority,
    String? response,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => SupportTicketModel(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    subject: subject ?? this.subject,
    message: message ?? this.message,
    category: category ?? this.category,
    status: status ?? this.status,
    priority: priority ?? this.priority,
    response: response ?? this.response,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}

String _text(dynamic value, {String fallback = ''}) {
  final String result = value?.toString().trim() ?? '';
  return result.isEmpty ? fallback : result;
}

DateTime? _date(dynamic value) =>
    value is DateTime
        ? value
        : DateTime.tryParse(value?.toString() ?? '');
