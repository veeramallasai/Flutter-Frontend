class AuthSessionModel {
  const AuthSessionModel({
    required this.userId,
    this.email = '',
    this.phoneNumber = '',
    this.provider = 'password',
    this.isAuthenticated = false,
    this.createdAt,
    this.expiresAt,
    this.lastSeenAt,
  });

  final String userId;
  final String email;
  final String phoneNumber;
  final String provider;
  final bool isAuthenticated;
  final DateTime? createdAt;
  final DateTime? expiresAt;
  final DateTime? lastSeenAt;

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
  bool get isValid => isAuthenticated && userId.isNotEmpty && !isExpired;

  factory AuthSessionModel.fromMap(Map<String, dynamic> map) =>
      AuthSessionModel(
        userId: _text(map['userId'] ?? map['uid']),
        email: _text(map['email']),
        phoneNumber: _text(map['phoneNumber'] ?? map['phone']),
        provider: _text(map['provider'], fallback: 'password'),
        isAuthenticated: _boolean(map['isAuthenticated'] ?? map['signedIn']),
        createdAt: _date(map['createdAt']),
        expiresAt: _date(map['expiresAt']),
        lastSeenAt: _date(map['lastSeenAt']),
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
    'userId': userId,
    'email': email,
    'phoneNumber': phoneNumber,
    'provider': provider,
    'isAuthenticated': isAuthenticated,
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    if (expiresAt != null) 'expiresAt': expiresAt!.toIso8601String(),
    if (lastSeenAt != null) 'lastSeenAt': lastSeenAt!.toIso8601String(),
  };

  AuthSessionModel copyWith({
    String? userId,
    String? email,
    String? phoneNumber,
    String? provider,
    bool? isAuthenticated,
    DateTime? createdAt,
    DateTime? expiresAt,
    DateTime? lastSeenAt,
  }) => AuthSessionModel(
    userId: userId ?? this.userId,
    email: email ?? this.email,
    phoneNumber: phoneNumber ?? this.phoneNumber,
    provider: provider ?? this.provider,
    isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    createdAt: createdAt ?? this.createdAt,
    expiresAt: expiresAt ?? this.expiresAt,
    lastSeenAt: lastSeenAt ?? this.lastSeenAt,
  );
}

String _text(dynamic value, {String fallback = ''}) {
  final String result = value?.toString().trim() ?? '';
  return result.isEmpty ? fallback : result;
}

bool _boolean(dynamic value) =>
    value is bool
        ? value
        : <String>{'true', '1', 'yes'}.contains('$value'.toLowerCase());

DateTime? _date(dynamic value) =>
    value is DateTime
        ? value
        : DateTime.tryParse(value?.toString() ?? '');
