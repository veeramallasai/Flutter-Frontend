import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/auth_session_model.dart';

class SessionRepository {
  SessionRepository({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Stream<AuthSessionModel> watchSession() {
    return _auth.authStateChanges().map(_sessionFromUser);
  }

  AuthSessionModel get currentSession => _sessionFromUser(_auth.currentUser);

  Future<void> touchSession() async {
    final User? user = _auth.currentUser;
    if (user == null) return;
    await _firestore.collection('user_sessions').doc(user.uid).set(
      <String, dynamic>{
        ..._sessionFromUser(user).toMap(),
        'lastSeenAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> endSession() async {
    final String? id = _auth.currentUser?.uid;
    if (id != null) {
      await _firestore.collection('user_sessions').doc(id).set(
        <String, dynamic>{
          'isAuthenticated': false,
          'lastSeenAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    }
    await _auth.signOut();
  }

  AuthSessionModel _sessionFromUser(User? user) {
    if (user == null) {
      return const AuthSessionModel(userId: '', isAuthenticated: false);
    }
    final String provider = user.providerData.isEmpty
        ? 'password'
        : user.providerData.first.providerId;
    return AuthSessionModel(
      userId: user.uid,
      email: user.email ?? '',
      phoneNumber: user.phoneNumber ?? '',
      provider: provider,
      isAuthenticated: true,
      createdAt: user.metadata.creationTime,
      lastSeenAt: user.metadata.lastSignInTime,
    );
  }
}
