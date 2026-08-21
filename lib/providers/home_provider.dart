import 'package:flutter/foundation.dart';

import '../data/models/category_model.dart';
import '../data/models/product_model.dart';
import '../data/repositories/category_repository.dart';
import '../data/repositories/product_repository.dart';

class HomeProvider extends ChangeNotifier {
  HomeProvider({
    ProductRepository? productRepository,
    CategoryRepository? categoryRepository,
  }) : _productRepository = productRepository ?? ProductRepository(),
       _categoryRepository = categoryRepository ?? CategoryRepository();

  final ProductRepository _productRepository;
  final CategoryRepository _categoryRepository;
  List<ProductModel> _products = <ProductModel>[];
  List<CategoryModel> _categories = <CategoryModel>[];
  String _shoppingMode = 'home';
  bool _isLoading = false;
  String? _errorMessage;

  List<ProductModel> get products => List<ProductModel>.unmodifiable(_products);
  List<ProductModel> get featuredProducts =>
      List<ProductModel>.unmodifiable(_products.take(12));
  List<CategoryModel> get categories =>
      List<CategoryModel>.unmodifiable(_categories);
  String get shoppingMode => _shoppingMode;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> load({String? shoppingMode}) async {
    if (shoppingMode != null) {
      _shoppingMode = shoppingMode.toLowerCase() == 'shop' ? 'shop' : 'home';
    }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _categories = await _categoryRepository.getCategories();
      _products = await _productRepository.getProducts(
        shoppingMode: _shoppingMode,
        limit: 200,
      );
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setShoppingMode(String value) => load(shoppingMode: value);

  List<ProductModel> productsForCategory(String category) {
    final String value = category.trim().toLowerCase();
    return _products
        .where(
          (ProductModel product) =>
              product.category.trim().toLowerCase() == value,
        )
        .toList(growable: false);
  }
}
