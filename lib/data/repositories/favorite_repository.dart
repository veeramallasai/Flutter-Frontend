import '../../core/network/api_client.dart';
import '../models/product_model.dart';

class FavoriteRepository {
  FavoriteRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<ProductModel>> getFavorites() async {
    final dynamic data = (await _apiClient.get('/api/v1/favorites')).data;
    if (data is! Iterable) return <ProductModel>[];
    return List<ProductModel>.unmodifiable(
      data.whereType<Map>().map(
        (Map value) => ProductModel.fromMap(Map<String, dynamic>.from(value)),
      ),
    );
  }

  Future<void> add(String productId) async {
    final String id = productId.trim();
    if (id.isEmpty) return;
    await _apiClient.post('/api/v1/favorites/$id');
  }

  Future<void> remove(String productId) async {
    final String id = productId.trim();
    if (id.isEmpty) return;
    await _apiClient.delete('/api/v1/favorites/$id');
  }

  Future<bool> contains(String productId) async {
    final String id = productId.trim();
    if (id.isEmpty) return false;
    final List<ProductModel> values = await getFavorites();
    return values.any((ProductModel item) => item.id == id);
  }
}
