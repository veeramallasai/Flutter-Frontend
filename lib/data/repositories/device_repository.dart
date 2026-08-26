import '../../core/network/api_client.dart';

class DeviceRepository {
  DeviceRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<void> register({
    required String token,
    required String platform,
    String deviceName = '',
  }) async {
    final String cleanToken = token.trim();
    if (cleanToken.isEmpty) return;
    await _apiClient.post(
      '/api/v1/devices',
      body: <String, dynamic>{
        'token': cleanToken,
        'platform': platform.trim(),
        'deviceName': deviceName.trim(),
      },
    );
  }

  Future<void> unregister(String token) async {
    final String cleanToken = token.trim();
    if (cleanToken.isEmpty) return;
    await _apiClient.delete(
      '/api/v1/devices',
      queryParameters: <String, dynamic>{'token': cleanToken},
    );
  }
}
