import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/models/auth_session_model.dart';
import '../data/repositories/session_repository.dart';

class SessionProvider extends ChangeNotifier {
  SessionProvider({SessionRepository? repository})
      : _repository = repository ?? SessionRepository() {
    _session = _repository.currentSession;
  }

  final SessionRepository _repository;
  StreamSubscription<AuthSessionModel>? _subscription;
  late AuthSessionModel _session;
  bool _isLoading = false;
  String? _errorMessage;
  bool _disposed = false;

  AuthSessionModel get session => _session;
  bool get isAuthenticated => _session.isValid;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void listen() {
    _subscription?.cancel();
    _isLoading = true;
    _notify();
    _subscription = _repository.watchSession().listen(
      (AuthSessionModel value) {
        _session = value;
        _isLoading = false;
        _errorMessage = null;
        _notify();
      },
      onError: (Object error) {
        _isLoading = false;
        _errorMessage = error.toString();
        _notify();
      },
    );
  }

  Future<void> touch() => _repository.touchSession();

  Future<void> signOut() async {
    await _repository.endSession();
    _session = _repository.currentSession;
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _subscription?.cancel();
    super.dispose();
  }
}
