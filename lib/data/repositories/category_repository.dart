import '../../core/constants/asset_paths.dart';
import '../../core/network/api_client.dart';
import '../local/local_product_catalog.dart';
import '../models/category_model.dart';

class CategoryRepository {
  CategoryRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  List<CategoryModel> get localCategories => <CategoryModel>[
        _local('vegetables', 'Vegetables', 0),
        _local('fruits', 'Fruits', 1),
        _local('dairy', 'Dairy', 2),
        _local('seasonal', 'Seasonal', 3),
      ];

  Stream<List<CategoryModel>> watchCategories() async* {
    yield localCategories;
    final List<CategoryModel> values = await getCategories();
    if (!_sameIds(values, localCategories)) yield values;
  }

  Future<List<CategoryModel>> getCategories() async {
    try {
      final dynamic data = (await _apiClient.get('/api/v1/catalog/categories')).data;
      final List<CategoryModel> values = _maps(data)
          .map(CategoryModel.fromMap)
          .where((CategoryModel item) => item.isActive)
          .map(_withLocalImage)
          .toList(growable: true)
        ..sort((CategoryModel a, CategoryModel b) => a.sortOrder.compareTo(b.sortOrder));
      return values.isEmpty ? localCategories : List<CategoryModel>.unmodifiable(values);
    } catch (_) {
      return localCategories;
    }
  }

  CategoryModel _withLocalImage(CategoryModel category) => category.imageUrl.isNotEmpty
      ? category
      : category.copyWith(imageUrl: AssetPaths.categoryImage(category.id) ?? '');

  CategoryModel _local(String id, String name, int order) => CategoryModel(
        id: id,
        name: name,
        description: 'Fresh $name selected for you',
        imageUrl: AssetPaths.categoryImage(id) ?? '',
        productCount: LocalProductCatalog.products(category: id).length,
        sortOrder: order,
      );
}

List<Map<String, dynamic>> _maps(dynamic data) => data is Iterable
    ? data.whereType<Map>().map((Map value) => Map<String, dynamic>.from(value)).toList()
    : <Map<String, dynamic>>[];

bool _sameIds(List<CategoryModel> a, List<CategoryModel> b) =>
    a.length == b.length && a.map((CategoryModel item) => item.id).join('|') ==
        b.map((CategoryModel item) => item.id).join('|');
