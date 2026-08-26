import '../../core/network/api_client.dart';
import '../../core/network/api_response.dart';
import '../models/product_model.dart';

class ProductRemoteSource {
  ProductRemoteSource({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Stream<List<ProductModel>> watchProducts({
    String category = '',
    String shoppingMode = '',
    int limit = 200,
  }) {
    return Stream<List<ProductModel>>.fromFuture(
      getProducts(category: category, shoppingMode: shoppingMode, limit: limit),
    ).asBroadcastStream();
  }

  Future<List<ProductModel>> getProducts({
    String category = '',
    String shoppingMode = '',
    int limit = 200,
  }) async {
    final ApiResponse<dynamic> response = await _client.get(
      '/api/v1/products',
      queryParameters: <String, dynamic>{
        'category': category.trim(),
        'shoppingMode': shoppingMode.trim(),
        'limit': limit,
      },
    );
    final dynamic raw = response.data;
    if (raw is! Iterable) return <ProductModel>[];
    return raw
        .whereType<Map>()
        .map(
          (Map<dynamic, dynamic> value) => ProductModel.fromMap(
            value.map(
              (dynamic key, dynamic item) =>
                  MapEntry<String, dynamic>(key.toString(), item),
            ),
          ),
        )
        .toList(growable: false);
  }

  Stream<ProductModel?> watchProduct(String productId) =>
      Stream<ProductModel?>.fromFuture(
        getProduct(productId),
      ).asBroadcastStream();

  Future<ProductModel?> getProduct(
    String productId, {
    String shoppingMode = 'home',
  }) async {
    final String id = productId.trim();
    if (id.isEmpty) return null;
    final ApiResponse<dynamic> response = await _client.get(
      '/api/v1/products/$id',
      queryParameters: <String, dynamic>{'shoppingMode': shoppingMode},
    );
    final dynamic raw = response.data;
    if (raw is! Map) return null;
    return ProductModel.fromMap(
      raw.map(
        (dynamic key, dynamic value) =>
            MapEntry<String, dynamic>(key.toString(), value),
      ),
      documentId: id,
    );
  }

  Future<String> saveProduct(ProductModel product) {
    throw UnsupportedError('Product changes require an admin API.');
  }

  Future<void> updateStock({
    required String productId,
    required int stockQuantity,
  }) {
    throw UnsupportedError(
      'Stock is managed by the backend order transaction.',
    );
  }
}
