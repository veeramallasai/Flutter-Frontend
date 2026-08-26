import 'package:farm_to_home_app/core/auth/backend_auth.dart';

import '../models/auth_session_model.dart';

class SessionRepository {
  SessionRepository({BackendAuth? auth})
    : _auth = auth ?? BackendAuth.instance;

  final BackendAuth _auth;

  Stream<AuthSessionModel> watchSession() {
    return _auth.authStateChanges().map(_sessionFromUser);
  }

  AuthSessionModel get currentSession => _sessionFromUser(_auth.currentUser);

  Future<void> touchSession() async {
    // Session touched locally / backend
  }

  Future<void> endSession() async {
    await _auth.signOut();
  }

  AuthSessionModel _sessionFromUser(User? user) {
    if (user == null) {
      return const AuthSessionModel(userId: '', isAuthenticated: false);
    }
    final String provider =
        user.providerData.isEmpty
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
