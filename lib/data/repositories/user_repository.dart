import 'package:farm_to_home_app/core/auth/backend_auth.dart';

import '../../core/network/api_client.dart';
import '../models/user_model.dart';

class UserRepository {
  UserRepository({
    BackendAuth? auth,
    ApiClient? apiClient,
  }) : _auth = auth ?? BackendAuth.instance,
       _apiClient = apiClient ?? ApiClient();

  final BackendAuth _auth;
  final ApiClient _apiClient;

  Stream<UserModel?> watchCurrentUser() async* {
    yield await getCurrentUser();
  }

  Future<UserModel> getCurrentUser() async {
    final User? authUser = _auth.currentUser;
    if (authUser == null) throw StateError('Please login to continue.');

    try {
      final response = await _apiClient.get('/api/v1/users/me');
      if (response.data is Map) {
        return UserModel.fromMap(
          Map<String, dynamic>.from(response.data as Map),
          docId: authUser.uid,
        );
      }
    } catch (_) {}

    return _fromAuth(authUser);
  }

  Future<void> saveProfile(UserModel profile) async {
    final User? authUser = _auth.currentUser;
    if (authUser == null) throw StateError('Please login to continue.');

    if (profile.displayName.trim().isNotEmpty) {
      await authUser.updateDisplayName(profile.displayName.trim());
    }

    await _apiClient.put(
      '/api/v1/users/me',
      body: <String, dynamic>{
        'firstName': profile.firstName.trim(),
        'lastName': profile.lastName.trim(),
        'phoneNumber': profile.phoneNumber.trim(),
        'photoUrl': profile.photoUrl.trim(),
        'shoppingMode': profile.shoppingMode,
        'accountType': profile.accountType,
      },
    );
  }

  Future<void> updateShoppingMode(String mode) async {
    final String normalized =
        mode.trim().toLowerCase() == 'shop' ? 'shop' : 'home';
    final UserModel user = await getCurrentUser();
    await saveProfile(user.copyWith(shoppingMode: normalized));
  }

  Future<void> syncCurrentUser({String? accountType}) async {
    final User? authUser = _auth.currentUser;
    if (authUser == null) throw StateError('Please login to continue.');

    final List<String> names = (authUser.displayName ?? '').trim().split(
      RegExp(r'\s+'),
    );

    final String firstName = names.isEmpty ? '' : names.first;
    final String lastName = names.length <= 1 ? '' : names.skip(1).join(' ');

    await _apiClient.put(
      '/api/v1/users/me',
      body: <String, dynamic>{
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber': authUser.phoneNumber ?? '',
        'photoUrl': authUser.photoURL ?? '',
        'shoppingMode': 'home',
        'accountType': accountType ?? 'customer',
      },
    );
  }

  UserModel _fromAuth(User user) {
    final List<String> names = (user.displayName ?? '').trim().split(
      RegExp(r'\s+'),
    );
    return UserModel(
      uid: user.uid,
      firstName: names.isEmpty ? '' : names.first,
      lastName: names.length <= 1 ? '' : names.skip(1).join(' '),
      email: user.email ?? '',
      phoneNumber: user.phoneNumber ?? '',
      photoUrl: user.photoURL ?? '',
      isPhoneVerified: user.phoneNumber?.isNotEmpty == true,
      isProfileComplete: (user.displayName ?? '').trim().isNotEmpty,
    );
  }
}
