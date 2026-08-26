import 'package:farm_to_home_app/core/auth/backend_auth.dart';

class AuthRemoteSource {
  AuthRemoteSource({BackendAuth? auth}) : _auth = auth ?? BackendAuth.instance;

  final BackendAuth _auth;

  User? get currentUser => _auth.currentUser;
  Stream<User?> watchAuthState() => _auth.authStateChanges();

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) => _auth.signInWithEmailAndPassword(
    email: email.trim().toLowerCase(),
    password: password,
  );

  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
  }) => _auth.createUserWithEmailAndPassword(
    email: email.trim().toLowerCase(),
    password: password,
  );

  Future<UserCredential> signInWithCredential(AuthCredential credential) =>
      _auth.signInWithCredential(credential);

  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim().toLowerCase());

  Future<void> sendEmailVerification() async {
    final User? user = currentUser;
    if (user == null) throw StateError('Please login to continue.');
    if (!user.emailVerified) await user.sendEmailVerification();
  }

  Future<void> reload() => currentUser?.reload() ?? Future<void>.value();
  Future<void> signOut() => _auth.signOut();
}
