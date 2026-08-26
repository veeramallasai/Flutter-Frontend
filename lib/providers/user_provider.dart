import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/models/user_model.dart';
import '../data/repositories/user_repository.dart';

class UserProvider extends ChangeNotifier {
  UserProvider({UserRepository? repository})
    : _repository = repository ?? UserRepository();

  final UserRepository _repository;
  StreamSubscription<UserModel?>? _subscription;
  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;
  bool _disposed = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void listen() {
    _subscription?.cancel();
    _isLoading = true;
    _notify();
    try {
      _subscription = _repository.watchCurrentUser().listen(
        (UserModel? value) {
          _user = value;
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
    } catch (error) {
      _isLoading = false;
      _errorMessage = error.toString();
      _notify();
    }
  }

  Future<bool> refresh() async {
    _isLoading = true;
    _notify();
    try {
      _user = await _repository.getCurrentUser();
      _errorMessage = null;
      return true;
    } catch (error) {
      _errorMessage = error.toString();
      return false;
    } finally {
      _isLoading = false;
      _notify();
    }
  }

  Future<bool> save(UserModel value) async {
    try {
      await _repository.saveProfile(value);
      _user = value;
      _errorMessage = null;
      _notify();
      return true;
    } catch (error) {
      _errorMessage = error.toString();
      _notify();
      return false;
    }
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
