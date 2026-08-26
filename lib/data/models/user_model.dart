class UserModel {
  const UserModel({
    required this.uid,
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.phoneNumber = '',
    this.photoUrl = '',
    this.shoppingMode = 'home',
    this.accountType = 'customer',
    this.isPhoneVerified = false,
    this.isProfileComplete = false,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    this.lastLoginAt,
  });

  final String uid;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String photoUrl;
  final String shoppingMode;
  final String accountType;
  final bool isPhoneVerified;
  final bool isProfileComplete;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastLoginAt;

  String get displayName {
    final String name = '$firstName $lastName'.trim();
    return name.isNotEmpty
        ? name
        : email.isNotEmpty
        ? email.split('@').first
        : 'Farm Friend';
  }

  bool get isShopOwner => shoppingMode == 'shop' || accountType == 'shop_owner';

  factory UserModel.fromDocument(dynamic doc) {
    if (doc is Map<String, dynamic>) {
      return UserModel.fromMap(doc, docId: (doc['uid'] ?? doc['id'] ?? '').toString());
    }
    try {
      final map = (doc as dynamic).data() as Map<String, dynamic>? ?? <String, dynamic>{};
      return UserModel.fromMap(map, docId: doc.id.toString());
    } catch (_) {
      return const UserModel(uid: '');
    }
  }

  factory UserModel.fromMap(
    Map<String, dynamic> map, {
    String docId = '',
    String documentId = '',
  }) {
    final String id = docId.isNotEmpty ? docId : (documentId.isNotEmpty ? documentId : map['uid'] ?? map['id'] ?? '');
    return UserModel(
      uid: _text(id),
      firstName: _text(map['firstName']),
      lastName: _text(map['lastName']),
      email: _text(map['email']).toLowerCase(),
      phoneNumber: _text(map['phoneNumber'] ?? map['phone']),
      photoUrl: _text(map['photoUrl'] ?? map['profileImage']),
      shoppingMode:
          _text(map['shoppingMode'], fallback: 'home').toLowerCase() == 'shop'
              ? 'shop'
              : 'home',
      accountType: _text(map['accountType'], fallback: 'customer'),
      isPhoneVerified: _boolean(map['phoneVerified'] ?? map['isPhoneVerified']),
      isProfileComplete:
          _boolean(map['isProfileComplete'], fallback: _text(map['firstName']).isNotEmpty),
      isActive: _boolean(map['isActive'], fallback: true),
      createdAt: _date(map['createdAt']),
      updatedAt: _date(map['updatedAt']),
      lastLoginAt: _date(map['lastLoginAt']),
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
    'uid': uid,
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'phoneNumber': phoneNumber,
    'photoUrl': photoUrl,
    'shoppingMode': shoppingMode,
    'accountType': accountType,
    'isPhoneVerified': isPhoneVerified,
    'isProfileComplete': isProfileComplete,
    'isActive': isActive,
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    if (lastLoginAt != null) 'lastLoginAt': lastLoginAt!.toIso8601String(),
  };

  UserModel copyWith({
    String? uid,
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? photoUrl,
    String? shoppingMode,
    String? accountType,
    bool? isPhoneVerified,
    bool? isProfileComplete,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
  }) => UserModel(
    uid: uid ?? this.uid,
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    email: email ?? this.email,
    phoneNumber: phoneNumber ?? this.phoneNumber,
    photoUrl: photoUrl ?? this.photoUrl,
    shoppingMode: shoppingMode ?? this.shoppingMode,
    accountType: accountType ?? this.accountType,
    isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
    isProfileComplete: isProfileComplete ?? this.isProfileComplete,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    lastLoginAt: lastLoginAt ?? this.lastLoginAt,
  );
}

String _text(dynamic value, {String fallback = ''}) {
  final String result = value?.toString().trim() ?? '';
  return result.isEmpty ? fallback : result;
}

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
