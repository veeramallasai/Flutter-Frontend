import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/models/user_model.dart';
import '../data/repositories/user_repository.dart';

class ProfileProvider extends ChangeNotifier {
  ProfileProvider({UserRepository? repository})
    : _repository = repository ?? UserRepository();

  final UserRepository _repository;
  StreamSubscription<UserModel?>? _subscription;
  UserModel? _profile;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  bool _disposed = false;

  UserModel? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  void listen() {
    _subscription?.cancel();
    _isLoading = true;
    _notify();
    try {
      _subscription = _repository.watchCurrentUser().listen(
        (UserModel? value) {
          _profile = value;
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

  Future<bool> save(UserModel profile) async {
    if (_isSaving) return false;
    _isSaving = true;
    _errorMessage = null;
    _notify();
    try {
      await _repository.saveProfile(profile);
      _profile = profile;
      return true;
    } catch (error) {
      _errorMessage = error.toString();
      return false;
    } finally {
      _isSaving = false;
      _notify();
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
