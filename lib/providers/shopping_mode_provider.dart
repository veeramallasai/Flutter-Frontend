import 'package:flutter/foundation.dart';

import '../data/repositories/user_repository.dart';

class ShoppingModeProvider extends ChangeNotifier {
  ShoppingModeProvider({UserRepository? repository})
      : _repository = repository ?? UserRepository();

  final UserRepository _repository;
  String _mode = 'home';
  bool _isUpdating = false;
  String? _errorMessage;

  String get mode => _mode;
  bool get isHome => _mode == 'home';
  bool get isShop => _mode == 'shop';
  bool get isUpdating => _isUpdating;
  String? get errorMessage => _errorMessage;

  void initialize(String value) {
    _mode = _normalize(value);
    notifyListeners();
  }

  Future<bool> setMode(String value) async {
    final String next = _normalize(value);
    if (next == _mode || _isUpdating) return next == _mode;
    final String previous = _mode;
    _mode = next;
    _isUpdating = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _repository.updateShoppingMode(next);
      return true;
    } catch (error) {
      _mode = previous;
      _errorMessage = error.toString();
      return false;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  String _normalize(String value) =>
      value.trim().toLowerCase() == 'shop' ? 'shop' : 'home';
}
