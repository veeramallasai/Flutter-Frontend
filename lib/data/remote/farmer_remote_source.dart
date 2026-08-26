import '../../core/network/api_client.dart';
import '../models/farmer_model.dart';

class FarmerRemoteSource {
  FarmerRemoteSource({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Stream<List<FarmerModel>> watchFarmers({int limit = 100}) async* {
    yield await getFarmers(limit: limit);
  }

  Future<List<FarmerModel>> getFarmers({int limit = 100}) async {
    final dynamic data =
        (await _apiClient.get(
          '/api/v1/farmers',
          queryParameters: <String, dynamic>{'limit': limit},
        )).data;
    return _sortAndLimit(
      _maps(data).map(FarmerModel.fromMap).toList(growable: true),
      limit,
    );
  }

  Stream<FarmerModel?> watchFarmer(String farmerId) async* {
    yield await getFarmer(farmerId);
  }

  Future<FarmerModel?> getFarmer(String farmerId) async {
    final String id = farmerId.trim();
    if (id.isEmpty) return null;
    final dynamic data = (await _apiClient.get('/api/v1/farmers/$id')).data;
    return data is Map
        ? FarmerModel.fromMap(Map<String, dynamic>.from(data))
        : null;
  }

  Future<String> saveFarmer(FarmerModel farmer) {
    throw UnsupportedError(
      'Farmer profiles are managed by the authenticated admin backend.',
    );
  }

  List<FarmerModel> _sortAndLimit(List<FarmerModel> farmers, int limit) {
    farmers.sort((FarmerModel first, FarmerModel second) {
      if (first.isVerified != second.isVerified)
        return first.isVerified ? -1 : 1;
      final int ratingComparison = second.rating.compareTo(first.rating);
      if (ratingComparison != 0) return ratingComparison;
      return first.name.toLowerCase().compareTo(second.name.toLowerCase());
    });
    if (limit <= 0 || farmers.length <= limit) {
      return List<FarmerModel>.unmodifiable(farmers);
    }
    return List<FarmerModel>.unmodifiable(farmers.take(limit));
  }
}

List<Map<String, dynamic>> _maps(dynamic data) =>
    data is Iterable
        ? data
            .whereType<Map>()
            .map((Map value) => Map<String, dynamic>.from(value))
            .toList()
        : <Map<String, dynamic>>[];
