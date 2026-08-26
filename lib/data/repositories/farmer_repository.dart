import '../models/farmer_model.dart';
import '../remote/farmer_remote_source.dart';

class FarmerRepository {
  FarmerRepository({FarmerRemoteSource? remoteSource})
    : _remoteSource = remoteSource ?? FarmerRemoteSource();

  final FarmerRemoteSource _remoteSource;

  Stream<List<FarmerModel>> watchFarmers({int limit = 100}) {
    return _remoteSource.watchFarmers(limit: limit);
  }

  Future<List<FarmerModel>> getFarmers({int limit = 100}) {
    return _remoteSource.getFarmers(limit: limit);
  }

  Stream<FarmerModel?> watchFarmer(String farmerId) {
    return _remoteSource.watchFarmer(farmerId);
  }

  Future<FarmerModel?> getFarmer(String farmerId) {
    return _remoteSource.getFarmer(farmerId);
  }

  Future<List<FarmerModel>> searchFarmers(
    String query, {
    int limit = 100,
  }) async {
    final List<FarmerModel> farmers = await getFarmers(limit: limit);
    final String value = query.trim().toLowerCase();
    if (value.isEmpty) return farmers;

    return farmers
        .where((FarmerModel farmer) {
          return farmer.name.toLowerCase().contains(value) ||
              farmer.farmName.toLowerCase().contains(value) ||
              farmer.location.toLowerCase().contains(value) ||
              farmer.speciality.toLowerCase().contains(value);
        })
        .toList(growable: false);
  }

  Future<String> saveFarmer(FarmerModel farmer) {
    return _remoteSource.saveFarmer(farmer);
  }
}
