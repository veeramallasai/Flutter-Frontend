import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/models/category_model.dart';
import '../data/repositories/category_repository.dart';

class CategoryProvider extends ChangeNotifier {
  CategoryProvider({CategoryRepository? repository})
      : _repository = repository ?? CategoryRepository();

  final CategoryRepository _repository;
  StreamSubscription<List<CategoryModel>>? _subscription;
  List<CategoryModel> _categories = <CategoryModel>[];
  String _selectedId = '';
  bool _isLoading = false;
  String? _errorMessage;
  bool _disposed = false;

  List<CategoryModel> get categories =>
      List<CategoryModel>.unmodifiable(_categories);
  String get selectedId => _selectedId;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void listenToCategories() {
    _subscription?.cancel();
    _isLoading = true;
    _notify();
    _subscription = _repository.watchCategories().listen(
      (List<CategoryModel> values) {
        _categories = values;
        _selectedId = _selectedId.isEmpty && values.isNotEmpty
            ? values.first.id
            : _selectedId;
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

  Future<void> refresh() async {
    _isLoading = true;
    _notify();
    try {
      _categories = await _repository.getCategories();
      _errorMessage = null;
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      _notify();
    }
  }

  void select(String categoryId) {
    _selectedId = categoryId.trim();
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
