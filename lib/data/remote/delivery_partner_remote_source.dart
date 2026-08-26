import '../../core/network/api_client.dart';
import '../../core/services/secure_storage_service.dart';
import '../models/delivery_partner_order_model.dart';

class DeliveryPartnerRemoteSource {
  DeliveryPartnerRemoteSource({
    ApiClient? apiClient,
    SecureStorageService? storage,
  }) : _storage = storage ?? SecureStorageService(),
       _apiClient =
           apiClient ??
           ApiClient(
             accessTokenProvider:
                 () => (storage ?? SecureStorageService()).read(accessTokenKey),
           );

  static const String accessTokenKey = 'delivery_partner_access_token';
  static const String refreshTokenKey = 'delivery_partner_refresh_token';

  final SecureStorageService _storage;
  final ApiClient _apiClient;

  Future<void> login({required String email, required String password}) async {
    final response = await _apiClient.post(
      '/api/v1/delivery-partner/auth/login',
      body: <String, dynamic>{
        'email': email.trim().toLowerCase(),
        'password': password,
      },
    );
    final data = response.data;
    if (data is! Map) {
      throw StateError('Invalid delivery partner login response.');
    }
    final accessToken = (data['accessToken'] ?? '').toString().trim();
    if (accessToken.isEmpty) {
      throw StateError('Login response did not contain an access token.');
    }
    await _storage.write(accessTokenKey, accessToken);
    final refreshToken = (data['refreshToken'] ?? '').toString().trim();
    if (refreshToken.isNotEmpty) {
      await _storage.write(refreshTokenKey, refreshToken);
    }
  }

  Future<bool> hasSession() async =>
      (await _storage.read(accessTokenKey))?.trim().isNotEmpty ?? false;

  Future<void> signOut() async {
    await _storage.delete(accessTokenKey);
    await _storage.delete(refreshTokenKey);
  }

  Future<List<DeliveryPartnerOrderModel>> getAssignedDeliveries() async {
    final response = await _apiClient.get('/api/v1/delivery/orders');
    return _orders(response.data);
  }

  Future<List<DeliveryPartnerOrderModel>> getHistory() async {
    final response = await _apiClient.get('/api/v1/delivery/orders/history');
    return _orders(response.data);
  }

  Future<void> accept(String orderId) =>
      _apiClient.put('/api/v1/delivery/orders/${orderId.trim()}/accept');

  Future<void> reject(String orderId) =>
      _apiClient.put('/api/v1/delivery/orders/${orderId.trim()}/reject');

  Future<void> updateStatus(String orderId, String status) => _apiClient.put(
    '/api/v1/delivery/status/${orderId.trim()}',
    queryParameters: <String, dynamic>{'status': status},
  );

  List<DeliveryPartnerOrderModel> _orders(dynamic data) {
    if (data is! Iterable) return <DeliveryPartnerOrderModel>[];
    return data
        .whereType<Map>()
        .map(
          (value) => DeliveryPartnerOrderModel.fromMap(
            Map<String, dynamic>.from(value),
          ),
        )
        .toList(growable: false);
  }
}
