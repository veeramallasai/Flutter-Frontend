import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';

class UserRemoteSource {
  UserRemoteSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _user(String userId) {
    final String id = userId.trim();
    if (id.isEmpty) throw ArgumentError('User ID cannot be empty.');
    return _firestore.collection('users').doc(id);
  }

  Stream<UserModel?> watchUser(String userId) =>
      _user(userId).snapshots().map(
            (DocumentSnapshot<Map<String, dynamic>> document) =>
                document.exists ? UserModel.fromDocument(document) : null,
          );

  Future<UserModel?> getUser(String userId) async {
    final DocumentSnapshot<Map<String, dynamic>> document =
        await _user(userId).get();
    return document.exists ? UserModel.fromDocument(document) : null;
  }

  Future<void> saveUser(UserModel user) => _user(user.uid).set(
        <String, dynamic>{
          ...user.toMap(),
          if (user.createdAt == null) 'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

  Future<void> updateFields(
    String userId,
    Map<String, dynamic> fields,
  ) => _user(userId).set(
        <String, dynamic>{
          ...fields,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

  Future<void> deactivate(String userId) => updateFields(
        userId,
        <String, dynamic>{'isActive': false},
      );
}
