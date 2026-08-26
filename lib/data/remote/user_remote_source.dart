import '../../core/network/api_client.dart';
import '../models/user_model.dart';

class UserRemoteSource {
  UserRemoteSource({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Stream<UserModel?> watchUser(String userId) async* {
    yield await getUser(userId);
  }

  Future<UserModel?> getUser(String userId) async {
    try {
      final response = await _apiClient.get('/api/v1/users/me');
      if (response.data is Map) {
        return UserModel.fromMap(
          Map<String, dynamic>.from(response.data as Map),
          docId: userId,
        );
      }
    } catch (_) {}
    return null;
  }

  Future<void> saveUser(UserModel user) async {
    await _apiClient.put(
      '/api/v1/users/me',
      body: <String, dynamic>{
        'firstName': user.firstName,
        'lastName': user.lastName,
        'phoneNumber': user.phoneNumber,
        'photoUrl': user.photoUrl,
        'shoppingMode': user.shoppingMode,
      },
    );
  }

  Future<void> updateFields(String userId, Map<String, dynamic> fields) async {
    await _apiClient.put('/api/v1/users/me', body: fields);
  }

  Future<void> deactivate(String userId) async {
    await updateFields(userId, <String, dynamic>{'isActive': false});
  }
}
