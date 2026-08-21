import '../models/product_model.dart';

class LocalProductCache {
  final Map<String, ProductModel> _products = <String, ProductModel>{};
  DateTime? _updatedAt;

  DateTime? get updatedAt => _updatedAt;
  bool get isEmpty => _products.isEmpty;

  void saveAll(Iterable<ProductModel> products) {
    for (final ProductModel product in products) {
      if (product.id.trim().isNotEmpty) _products[product.id] = product;
    }
    _updatedAt = DateTime.now();
  }

  ProductModel? find(String productId) => _products[productId.trim()];

  List<ProductModel> getProducts({
    String category = '',
    String shoppingMode = '',
    int limit = 0,
  }) {
    final String categoryKey = category.trim().toLowerCase();
    final String modeKey = shoppingMode.trim().toLowerCase();
    Iterable<ProductModel> values = _products.values;
    if (categoryKey.isNotEmpty) {
      values = values.where(
        (ProductModel product) =>
            product.category.trim().toLowerCase() == categoryKey,
      );
    }
    if (modeKey.isNotEmpty) {
      values = values.where(
        (ProductModel product) => product.shoppingMode == modeKey,
      );
    }
    final List<ProductModel> result = values.toList(growable: false);
    return limit > 0 && result.length > limit
        ? List<ProductModel>.unmodifiable(result.take(limit))
        : List<ProductModel>.unmodifiable(result);
  }

  bool isFresh({Duration maxAge = const Duration(minutes: 15)}) {
    final DateTime? time = _updatedAt;
    return time != null && DateTime.now().difference(time) <= maxAge;
  }

  void clear() {
    _products.clear();
    _updatedAt = null;
  }
}
