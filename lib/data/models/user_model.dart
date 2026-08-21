import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  const UserModel({
    required this.uid,
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.phoneNumber = '',
    this.photoUrl = '',
    this.shoppingMode = 'home',
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
  final bool isPhoneVerified;
  final bool isProfileComplete;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastLoginAt;

  String get displayName {
    final String name = '$firstName $lastName'.trim();
    return name.isNotEmpty ? name : email.isNotEmpty ? email.split('@').first : 'Farm Friend';
  }
  bool get isShopOwner => shoppingMode == 'shop';

  factory UserModel.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) =>
      UserModel.fromMap(doc.data() ?? <String, dynamic>{}, documentId: doc.id);

  factory UserModel.fromMap(Map<String, dynamic> map, {String documentId = ''}) => UserModel(
        uid: _text(documentId.isNotEmpty ? documentId : map['uid'] ?? map['id']),
        firstName: _text(map['firstName']),
        lastName: _text(map['lastName']),
        email: _text(map['email']).toLowerCase(),
        phoneNumber: _text(map['phoneNumber'] ?? map['phone']),
        photoUrl: _text(map['photoUrl'] ?? map['profileImage']),
        shoppingMode: _text(map['shoppingMode'], fallback: 'home').toLowerCase() == 'shop' ? 'shop' : 'home',
        isPhoneVerified: _boolean(map['isPhoneVerified'] ?? map['phoneVerified']),
        isProfileComplete: _boolean(map['isProfileComplete'] ?? map['profileComplete']),
        isActive: _boolean(map['isActive'] ?? map['active'], fallback: true),
        createdAt: _date(map['createdAt']),
        updatedAt: _date(map['updatedAt']),
        lastLoginAt: _date(map['lastLoginAt']),
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'uid': uid, 'firstName': firstName, 'lastName': lastName,
        'email': email, 'phoneNumber': phoneNumber, 'photoUrl': photoUrl,
        'shoppingMode': shoppingMode, 'isPhoneVerified': isPhoneVerified,
        'isProfileComplete': isProfileComplete, 'isActive': isActive,
        if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
        if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
        if (lastLoginAt != null) 'lastLoginAt': Timestamp.fromDate(lastLoginAt!),
      };

  UserModel copyWith({String? uid, String? firstName, String? lastName,
      String? email, String? phoneNumber, String? photoUrl, String? shoppingMode,
      bool? isPhoneVerified, bool? isProfileComplete, bool? isActive,
      DateTime? createdAt, DateTime? updatedAt, DateTime? lastLoginAt}) => UserModel(
        uid: uid ?? this.uid, firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName, email: email ?? this.email,
        phoneNumber: phoneNumber ?? this.phoneNumber, photoUrl: photoUrl ?? this.photoUrl,
        shoppingMode: shoppingMode ?? this.shoppingMode,
        isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
        isProfileComplete: isProfileComplete ?? this.isProfileComplete,
        isActive: isActive ?? this.isActive, createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt, lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      );
}

String _text(dynamic value, {String fallback = ''}) {
  final String result = value?.toString().trim() ?? '';
  return result.isEmpty ? fallback : result;
}
bool _boolean(dynamic value, {bool fallback = false}) => value is bool ? value :
    value == null ? fallback : <String>{'true', '1', 'yes'}.contains('$value'.toLowerCase());
DateTime? _date(dynamic value) => value is Timestamp ? value.toDate() :
    value is DateTime ? value : DateTime.tryParse(value?.toString() ?? '');
