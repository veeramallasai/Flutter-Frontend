import 'package:farm_to_home_app/core/auth/backend_auth.dart';

import 'user_repository.dart';

class AuthRepository {
  AuthRepository({BackendAuth? auth})
    : _auth = auth ?? BackendAuth.instance;

  final BackendAuth _auth;

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
    try {
      await UserRepository(auth: _auth).syncCurrentUser();
    } catch (_) {}
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
      try {
        await UserRepository(auth: _auth).syncCurrentUser();
      } catch (_) {}
    }
    return result;
  }

  Future<UserCredential> signInWithCredential(AuthCredential credential) async {
    final UserCredential result = UserCredential(_auth.currentUser);
    try {
      await UserRepository(auth: _auth).syncCurrentUser();
    } catch (_) {}
    return result;
  }

  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim().toLowerCase());

  Future<void> reloadUser() => currentUser?.reload() ?? Future<void>.value();

  Future<void> signOut() => _auth.signOut();
}
