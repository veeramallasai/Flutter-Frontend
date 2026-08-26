import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farm_to_home_app/core/auth/backend_auth.dart';

import '../../core/network/api_client.dart';
import '../models/user_model.dart';

class UserRepository {
  UserRepository({
    FirebaseFirestore? firestore,
    BackendAuth? auth,
    ApiClient? apiClient,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? BackendAuth.instance,
       _apiClient = apiClient ?? ApiClient();

  final FirebaseFirestore _firestore;
  final BackendAuth _auth;
  final ApiClient _apiClient;

  DocumentReference<Map<String, dynamic>> _user(String id) =>
      _firestore.collection('users').doc(id);

  Stream<UserModel?> watchCurrentUser() {
    final String id = _requireUserId();
    return _user(id).snapshots().map(
      (DocumentSnapshot<Map<String, dynamic>> doc) =>
          doc.exists
              ? UserModel.fromDocument(doc)
              : _fromAuth(_auth.currentUser!),
    );
  }

  Future<UserModel> getCurrentUser() async {
    final String id = _requireUserId();
    final DocumentSnapshot<Map<String, dynamic>> doc = await _user(id).get();
    return doc.exists
        ? UserModel.fromDocument(doc)
        : _fromAuth(_auth.currentUser!);
  }

  Future<void> saveProfile(UserModel profile) async {
    final String id = _requireUserId();
    await _user(id).set(<String, dynamic>{
      ...profile.copyWith(uid: id).toMap(),
      if (profile.createdAt == null) 'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    final User? authUser = _auth.currentUser;
    if (authUser != null && profile.displayName.trim().isNotEmpty) {
      await authUser.updateDisplayName(profile.displayName.trim());
    }
    await syncCurrentUser(
      accountType: profile.isShopOwner ? 'shop_owner' : 'customer',
    );
  }

  Future<void> updateShoppingMode(String mode) async {
    final String normalized =
        mode.trim().toLowerCase() == 'shop' ? 'shop' : 'home';
    await _user(_requireUserId()).set(<String, dynamic>{
      'shoppingMode': normalized,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    await syncCurrentUser();
  }

  /// Mirrors the Firebase-authenticated customer into PostgreSQL.
  ///
  /// The backend derives UID, email and verification flags from the verified
  /// Firebase ID token. Client profile values are only used for editable
  /// fields such as name, photo and shopping mode.
  Future<void> syncCurrentUser({String? accountType}) async {
    final User? authUser = _auth.currentUser;
    if (authUser == null) throw StateError('Please login to continue.');

    await authUser.reload();
    final User refreshedUser = _auth.currentUser ?? authUser;
    await refreshedUser.getIdToken(true);

    final DocumentSnapshot<Map<String, dynamic>> document =
        await _user(refreshedUser.uid).get();
    final Map<String, dynamic> profile = document.data() ?? <String, dynamic>{};
    final List<String> names = (refreshedUser.displayName ?? '').trim().split(
      RegExp(r'\s+'),
    );

    String text(dynamic value) => value?.toString().trim() ?? '';
    final String firstName =
        text(profile['firstName']).isNotEmpty
            ? text(profile['firstName'])
            : names.isEmpty
            ? ''
            : names.first;
    final String lastName =
        text(profile['lastName']).isNotEmpty
            ? text(profile['lastName'])
            : names.length <= 1
            ? ''
            : names.skip(1).join(' ');

    final bool phoneVerified =
        refreshedUser.phoneNumber?.trim().isNotEmpty == true;
    await _user(refreshedUser.uid).set(<String, dynamic>{
      'email': refreshedUser.email ?? text(profile['email']),
      'emailVerified': refreshedUser.emailVerified,
      'phoneVerified': phoneVerified,
      if (phoneVerified) 'phoneNumber': refreshedUser.phoneNumber,
      'lastLoginAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    final String requestedAccountType =
        accountType ?? text(profile['accountType']);

    await _apiClient.put(
      '/api/v1/users/me',
      body: <String, dynamic>{
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber':
            refreshedUser.phoneNumber ?? text(profile['phoneNumber']),
        'photoUrl': refreshedUser.photoURL ?? text(profile['photoUrl']),
        'shoppingMode':
            text(profile['shoppingMode']).toLowerCase() == 'shop'
                ? 'shop'
                : 'home',
        'accountType':
            requestedAccountType == 'shop_owner' ? 'shop_owner' : 'customer',
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

  String _requireUserId() {
    final String id = _auth.currentUser?.uid.trim() ?? '';
    if (id.isEmpty) throw StateError('Please login to continue.');
    return id;
  }
}
