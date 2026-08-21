import '../../core/network/api_client.dart';

class EmailOtpRepository {
  EmailOtpRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> sendOtp() async {
    final dynamic data =
        (await _apiClient.post('/api/v1/auth/email-otp/send')).data;
    return _map(data);
  }

  Future<Map<String, dynamic>> verifyOtp(String otp) async {
    final dynamic data = (await _apiClient.post(
      '/api/v1/auth/email-otp/verify',
      body: <String, dynamic>{'otp': otp.trim()},
    )).data;
    return _map(data);
  }

  Future<Map<String, dynamic>> status() async {
    final dynamic data =
        (await _apiClient.get('/api/v1/auth/email-otp/status')).data;
    return _map(data);
  }
}

Map<String, dynamic> _map(dynamic data) =>
    data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{};
