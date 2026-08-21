import 'package:flutter/foundation.dart';

import '../data/models/product_model.dart';
import '../data/repositories/product_repository.dart';

class SearchProvider extends ChangeNotifier {
  SearchProvider({ProductRepository? repository})
      : _repository = repository ?? ProductRepository();

  final ProductRepository _repository;
  List<ProductModel> _results = <ProductModel>[];
  String _query = '';
  String _category = '';
  String _shoppingMode = 'home';
  bool _isSearching = false;
  String? _errorMessage;
  int _requestId = 0;

  List<ProductModel> get results => List<ProductModel>.unmodifiable(_results);
  String get query => _query;
  String get category => _category;
  String get shoppingMode => _shoppingMode;
  bool get isSearching => _isSearching;
  String? get errorMessage => _errorMessage;

  Future<void> search(
    String query, {
    String? category,
    String? shoppingMode,
  }) async {
    _query = query.trim();
    if (category != null) _category = category.trim();
    if (shoppingMode != null) {
      _shoppingMode = shoppingMode.toLowerCase() == 'shop' ? 'shop' : 'home';
    }
    final int currentRequest = ++_requestId;
    _isSearching = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final List<ProductModel> values = await _repository.searchProducts(
        _query,
        category: _category,
        shoppingMode: _shoppingMode,
      );
      if (currentRequest == _requestId) _results = values;
    } catch (error) {
      if (currentRequest == _requestId) _errorMessage = error.toString();
    } finally {
      if (currentRequest == _requestId) {
        _isSearching = false;
        notifyListeners();
      }
    }
  }

  void clear() {
    _requestId++;
    _query = '';
    _category = '';
    _results = <ProductModel>[];
    _isSearching = false;
    _errorMessage = null;
    notifyListeners();
  }
}
