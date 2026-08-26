import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farm_to_home_app/core/auth/backend_auth.dart';

import 'user_repository.dart';

class AuthRepository {
  AuthRepository({BackendAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? BackendAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  final BackendAuth _auth;
  final FirebaseFirestore _firestore;

  User? get currentUser => _auth.currentUser;
  bool get isSignedIn => currentUser != null;
  Stream<User?> watchAuthState() => _auth.authStateChanges();

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final UserCredential result = await _auth.signInWithEmailAndPassword(
      email: email.trim().toLowerCase(),
      password: password,
    );
    await _recordLogin(result.user);
    await UserRepository(auth: _auth, firestore: _firestore).syncCurrentUser();
    return result;
  }

  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
    required String firstName,
    String lastName = '',
    String phoneNumber = '',
  }) async {
    final UserCredential result = await _auth.createUserWithEmailAndPassword(
      email: email.trim().toLowerCase(),
      password: password,
    );
    final User? user = result.user;
    if (user != null) {
      final String displayName = '$firstName $lastName'.trim();
      if (displayName.isNotEmpty) await user.updateDisplayName(displayName);
      await _firestore.collection('users').doc(user.uid).set(<String, dynamic>{
        'uid': user.uid,
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'email': user.email ?? email.trim().toLowerCase(),
        'emailVerified': user.emailVerified,
        'phoneNumber': phoneNumber.trim(),
        'shoppingMode': 'home',
        'isActive': true,
        'isProfileComplete': firstName.trim().isNotEmpty,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      await UserRepository(
        auth: _auth,
        firestore: _firestore,
      ).syncCurrentUser();
    }
    return result;
  }

  Future<UserCredential> signInWithCredential(AuthCredential credential) async {
    final UserCredential result = await _auth.signInWithCredential(credential);
    await _recordLogin(result.user);
    await UserRepository(auth: _auth, firestore: _firestore).syncCurrentUser();
    return result;
  }

  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim().toLowerCase());

  Future<void> reloadUser() => currentUser?.reload() ?? Future<void>.value();

  Future<void> signOut() => _auth.signOut();

  Future<void> _recordLogin(User? user) async {
    if (user == null) return;
    await _firestore.collection('users').doc(user.uid).set(<String, dynamic>{
      'uid': user.uid,
      'email': user.email ?? '',
      'emailVerified': user.emailVerified,
      'phoneNumber': user.phoneNumber ?? '',
      'photoUrl': user.photoURL ?? '',
      'isActive': true,
      'lastLoginAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
