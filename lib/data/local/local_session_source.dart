import 'dart:async';

import '../models/auth_session_model.dart';

class LocalSessionSource {
  final StreamController<AuthSessionModel> _changes =
      StreamController<AuthSessionModel>.broadcast();
  AuthSessionModel _session = const AuthSessionModel(
    userId: '',
    isAuthenticated: false,
  );

  AuthSessionModel get current => _session;

  Stream<AuthSessionModel> watch() async* {
    yield _session;
    yield* _changes.stream;
  }

  Future<void> save(AuthSessionModel session) async {
    _session = session;
    _changes.add(session);
  }

  Future<void> clear() => save(
        const AuthSessionModel(userId: '', isAuthenticated: false),
      );

  Future<void> dispose() => _changes.close();
}
