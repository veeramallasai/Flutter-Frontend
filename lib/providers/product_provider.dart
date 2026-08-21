import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/models/product_model.dart';
import '../data/repositories/product_repository.dart';

class ProductProvider extends ChangeNotifier {
  ProductProvider({ProductRepository? repository})
    : _repository = repository ?? ProductRepository();

  final ProductRepository _repository;

  StreamSubscription<List<ProductModel>>? _subscription;
  List<ProductModel> _products = <ProductModel>[];
  String _selectedCategory = '';
  String _shoppingMode = '';
  String _searchQuery = '';
  int _limit = 200;
  bool _isLoading = false;
  String? _errorMessage;
  bool _disposed = false;

  List<ProductModel> get products => List<ProductModel>.unmodifiable(_products);
  String get selectedCategory => _selectedCategory;
  String get shoppingMode => _shoppingMode;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage?.trim().isNotEmpty ?? false;

  List<ProductModel> get visibleProducts {
    final String query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return products;

    return _products
        .where((ProductModel product) {
          return product.name.toLowerCase().contains(query) ||
              product.category.toLowerCase().contains(query) ||
              product.description.toLowerCase().contains(query);
        })
        .toList(growable: false);
  }

  void listenToProducts({
    String category = '',
    String shoppingMode = '',
    int limit = 200,
  }) {
    _selectedCategory = category.trim();
    _shoppingMode = shoppingMode.trim().toLowerCase();
    _limit = limit;
    _subscription?.cancel();
    _isLoading = true;
    _errorMessage = null;
    _notify();

    try {
      _subscription = _repository
          .watchProducts(
            category: _selectedCategory,
            shoppingMode: _shoppingMode,
            limit: _limit,
          )
          .listen(
            (List<ProductModel> values) {
              if (_disposed) return;
              _products = List<ProductModel>.from(values);
              _isLoading = false;
              _errorMessage = null;
              _notify();
            },
            onError: (Object error, StackTrace stackTrace) {
              if (_disposed) return;
              _isLoading = false;
              _errorMessage = _friendlyError(error);
              _notify();
            },
          );
    } catch (error) {
      _isLoading = false;
      _errorMessage = _friendlyError(error);
      _notify();
    }
  }

  Future<void> refresh() async {
    _isLoading = true;
    _errorMessage = null;
    _notify();

    try {
      _products = await _repository.getProducts(
        category: _selectedCategory,
        shoppingMode: _shoppingMode,
        limit: _limit,
      );
      _errorMessage = null;
    } catch (error) {
      _errorMessage = _friendlyError(error);
    } finally {
      _isLoading = false;
      _notify();
    }
  }

  void setCategory(String category) {
    final String value = category.trim();
    if (_selectedCategory == value) return;
    listenToProducts(
      category: value,
      shoppingMode: _shoppingMode,
      limit: _limit,
    );
  }

  void setShoppingMode(String shoppingMode) {
    final String value = shoppingMode.trim().toLowerCase();
    if (_shoppingMode == value) return;
    listenToProducts(
      category: _selectedCategory,
      shoppingMode: value,
      limit: _limit,
    );
  }

  void setSearchQuery(String query) {
    final String value = query.trim();
    if (_searchQuery == value) return;
    _searchQuery = value;
    _notify();
  }

  ProductModel? findProduct(String productId) {
    final String id = productId.trim();
    for (final ProductModel product in _products) {
      if (product.id == id) return product;
    }
    return null;
  }

  List<ProductModel> relatedProducts(ProductModel product, {int limit = 10}) {
    final String category = product.category.trim().toLowerCase();
    return _products
        .where(
          (ProductModel item) =>
              item.id != product.id &&
              item.category.trim().toLowerCase() == category,
        )
        .take(limit)
        .toList(growable: false);
  }

  void clearFilters() {
    _searchQuery = '';
    listenToProducts(limit: _limit);
  }

  void clearError() {
    _errorMessage = null;
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  String _friendlyError(Object error) {
    String message = error.toString().trim();
    if (message.startsWith('Bad state: ')) {
      message = message.substring('Bad state: '.length);
    }
    return message.isEmpty ? 'Unable to load products.' : message;
  }

  @override
  void dispose() {
    _disposed = true;
    _subscription?.cancel();
    super.dispose();
  }
}
