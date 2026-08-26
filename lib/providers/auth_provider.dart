import 'dart:async';

import 'package:farm_to_home_app/core/auth/backend_auth.dart';
import 'package:flutter/foundation.dart';

import '../core/enums/auth_state.dart';
import '../core/errors/error_handler.dart';
import '../data/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthRepository? repository})
    : _repository = repository ?? AuthRepository() {
    _subscription = _repository.watchAuthState().listen(_onUserChanged);
    _onUserChanged(_repository.currentUser);
  }

  final AuthRepository _repository;
  StreamSubscription<User?>? _subscription;
  User? _user;
  AuthState _state = AuthState.initial;
  String? _errorMessage;
  bool _disposed = false;

  User? get user => _user;
  AuthState get state => _state;
  bool get isLoading => _state == AuthState.loading;
  bool get isAuthenticated => _user != null;
  String? get errorMessage => _errorMessage;

  Future<bool> signIn(String email, String password) =>
      _run(() => _repository.signInWithEmail(email: email, password: password));

  Future<bool> register({
    required String email,
    required String password,
    required String firstName,
    String lastName = '',
    String phoneNumber = '',
  }) => _run(
    () => _repository.registerWithEmail(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
    ),
  );

  Future<bool> sendPasswordReset(String email) =>
      _run(() => _repository.sendPasswordReset(email));

  Future<bool> signOut() => _run(_repository.signOut);

  Future<bool> _run(Future<dynamic> Function() action) async {
    _state = AuthState.loading;
    _errorMessage = null;
    _notify();
    try {
      await action();
      _user = _repository.currentUser;
      _state =
          _user == null ? AuthState.unauthenticated : AuthState.authenticated;
      return true;
    } catch (error) {
      _state = AuthState.error;
      _errorMessage = ErrorHandler.message(error);
      return false;
    } finally {
      _notify();
    }
  }

  void clearError() {
    _errorMessage = null;
    if (_state == AuthState.error) {
      _state =
          _user == null ? AuthState.unauthenticated : AuthState.authenticated;
    }
    _notify();
  }

  void _onUserChanged(User? user) {
    _user = user;
    if (_state != AuthState.loading) {
      _state =
          user == null ? AuthState.unauthenticated : AuthState.authenticated;
    }
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
