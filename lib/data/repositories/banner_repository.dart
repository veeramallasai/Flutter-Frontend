import '../../core/constants/asset_paths.dart';
import '../../core/network/api_client.dart';
import '../models/banner_model.dart';

class BannerRepository {
  BannerRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  List<BannerModel> get localBanners => <BannerModel>[
        const BannerModel(
          id: 'fresh_vegetables',
          title: 'Fresh from local farms',
          subtitle: 'Handpicked vegetables delivered with care',
          imageUrl: AssetPaths.categoryVegetables,
          actionLabel: 'Shop now',
          route: '/category-products?category=vegetables',
        ),
        const BannerModel(
          id: 'seasonal_fruits',
          title: 'Seasonal favourites',
          subtitle: 'Naturally fresh fruits at honest prices',
          imageUrl: AssetPaths.categorySeasonal,
          actionLabel: 'Explore',
          route: '/category-products?category=seasonal',
          priority: 1,
        ),
      ];

  Stream<List<BannerModel>> watchBanners() async* {
    yield localBanners;
    final List<BannerModel> values = await getBanners();
    if (!_sameIds(values, localBanners)) yield values;
  }

  Future<List<BannerModel>> getBanners() async {
    try {
      final dynamic data = (await _apiClient.get('/api/v1/catalog/banners')).data;
      final List<BannerModel> values = _maps(data)
          .map(BannerModel.fromMap)
          .where((BannerModel banner) => banner.isVisible)
          .toList(growable: true)
        ..sort((BannerModel a, BannerModel b) => a.priority.compareTo(b.priority));
      return values.isEmpty ? localBanners : List<BannerModel>.unmodifiable(values);
    } catch (_) {
      return localBanners;
    }
  }
}

List<Map<String, dynamic>> _maps(dynamic data) => data is Iterable
    ? data.whereType<Map>().map((Map value) => Map<String, dynamic>.from(value)).toList()
    : <Map<String, dynamic>>[];

bool _sameIds(List<BannerModel> a, List<BannerModel> b) =>
    a.length == b.length && a.map((BannerModel item) => item.id).join('|') ==
        b.map((BannerModel item) => item.id).join('|');
