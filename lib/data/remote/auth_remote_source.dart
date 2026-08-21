import 'package:firebase_auth/firebase_auth.dart';

class AuthRemoteSource {
  AuthRemoteSource({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

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

  Future<UserCredential> verifyPhoneOtp({
    required String verificationId,
    required String smsCode,
  }) => signInWithCredential(
        PhoneAuthProvider.credential(
          verificationId: verificationId.trim(),
          smsCode: smsCode.trim(),
        ),
      );

  Future<void> requestPhoneOtp({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(FirebaseAuthException error) onFailed,
    void Function(PhoneAuthCredential credential)? onAutoVerified,
    void Function(String verificationId)? onTimeout,
    int? forceResendingToken,
  }) => _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber.trim(),
        forceResendingToken: forceResendingToken,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          onAutoVerified?.call(credential);
        },
        verificationFailed: onFailed,
        codeSent: onCodeSent,
        codeAutoRetrievalTimeout: (String verificationId) =>
            onTimeout?.call(verificationId),
      );

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
