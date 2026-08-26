import 'dart:async';
import 'dart:convert';

import '../errors/app_exception.dart';
import '../errors/network_exception.dart';
import '../network/api_client.dart';
import '../services/secure_storage_service.dart';

class BackendAuthException extends AppException {
  BackendAuthException({required String code, String? message, Object? details})
    : super(
        code: code,
        message: message ?? 'Authentication could not be completed.',
        details: details,
      );

  factory BackendAuthException.fromCode(String code, {Object? details}) {
    return BackendAuthException(
      code: code,
      details: details,
      message: _messageFor(code),
    );
  }

  static String _messageFor(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-not-found':
      case 'invalid-credential':
        return 'The email or password is incorrect.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Choose a stronger password.';
      case 'unsupported-provider':
        return 'This sign-in method is not available.';
      default:
        return 'Authentication could not be completed. Please try again.';
    }
  }

  @override
  String toString() => '$code: $message';
}

class AuthCredential {
  const AuthCredential({this.provider = ''});
  final String provider;
}

class UserInfo {
  const UserInfo(this.providerId);
  final String providerId;
}

class EmailAuthProvider {
  const EmailAuthProvider._();
  static const String PROVIDER_ID = 'password';
  static AuthCredential credential({
    required String email,
    required String password,
  }) => const AuthCredential(provider: PROVIDER_ID);
}

class PhoneAuthCredential extends AuthCredential {
  const PhoneAuthCredential({super.provider = 'phone'});
}

class PhoneAuthProvider {
  const PhoneAuthProvider._();
  static PhoneAuthCredential credential({
    required String verificationId,
    required String smsCode,
  }) => const PhoneAuthCredential();
}

class GoogleAuthProvider extends AuthCredential {
  GoogleAuthProvider() : super(provider: 'google.com');
  void setCustomParameters(Map<String, String> parameters) {}
}

class OAuthProvider extends AuthCredential {
  OAuthProvider(String provider) : super(provider: provider);
  void addScope(String scope) {}
}

class UserMetadata {
  const UserMetadata({this.creationTime, this.lastSignInTime});
  final DateTime? creationTime;
  final DateTime? lastSignInTime;
}

class User {
  User({
    required this.uid,
    required this.email,
    this.phoneNumber,
    this.displayName,
    this.photoURL,
    this.emailVerified = true,
  }) : metadata = UserMetadata(lastSignInTime: DateTime.now());
  final String uid;
  final String? email;
  final String? phoneNumber;
  String? displayName;
  String? photoURL;
  bool emailVerified;
  final UserMetadata metadata;
  List<UserInfo> get providerData => const <UserInfo>[];
  Future<void> reload() async {}
  Future<String?> getIdToken([bool forceRefresh = false]) async =>
      BackendAuth.instance.accessToken;
  Future<void> updateDisplayName(String value) async => displayName = value;
  Future<void> updatePhotoURL(String value) async => photoURL = value;
  Future<void> updatePassword(String value) async {}
  Future<UserCredential> linkWithCredential(AuthCredential credential) async =>
      UserCredential(this);
  Future<void> sendEmailVerification() async =>
      BackendAuth.instance.sendEmailOtp();
}

class UserCredential {
  const UserCredential(this.user);
  final User? user;
}

class BackendAuth {
  BackendAuth._();
  static final BackendAuth instance = BackendAuth._();
  final ApiClient _apiClient = ApiClient();
  final SecureStorageService _storage = SecureStorageService();
  final StreamController<User?> _changes = StreamController<User?>.broadcast();
  User? _currentUser;
  String? _accessToken;
  User? get currentUser => _currentUser;
  String? get accessToken => _accessToken;

  Stream<User?> authStateChanges() async* {
    yield _currentUser;
    yield* _changes.stream;
  }

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/v1/auth/login',
        body: <String, dynamic>{
          'email': email.trim().toLowerCase(),
          'password': password,
        },
      );
      return _complete(response.data, email: email);
    } on NetworkException catch (e) {
      if (e.code == 'http/401' || e.statusCode == 401) {
        throw BackendAuthException(
          code: 'invalid-credential',
          message: 'Account not found or password incorrect. Please register first.',
        );
      }
      rethrow;
    }
  }

  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/v1/auth/register',
        body: <String, dynamic>{
          'email': email.trim().toLowerCase(),
          'password': password,
        },
      );
      return _complete(response.data, email: email);
    } on NetworkException catch (e) {
      if (e.code == 'http/409' || e.statusCode == 409) {
        throw BackendAuthException(
          code: 'email-already-in-use',
          message: 'This email is already registered. Please sign in.',
        );
      }
      rethrow;
    }
  }

  Future<UserCredential> signInWithCredential(AuthCredential credential) async =>
      UserCredential(_currentUser);

  Future<UserCredential> signInWithSocial({
    required String provider,
    required String email,
    String? firstName,
    String? lastName,
    String? photoUrl,
    String? idToken,
  }) async {
    final response = await _apiClient.post(
      '/api/v1/auth/social-login',
      body: <String, dynamic>{
        'provider': provider,
        'email': email.trim().toLowerCase(),
        if (firstName != null && firstName.trim().isNotEmpty)
          'firstName': firstName.trim(),
        if (lastName != null && lastName.trim().isNotEmpty)
          'lastName': lastName.trim(),
        if (photoUrl != null && photoUrl.trim().isNotEmpty)
          'photoUrl': photoUrl.trim(),
        if (idToken != null && idToken.trim().isNotEmpty)
          'idToken': idToken.trim(),
      },
    );
    return _complete(response.data, email: email);
  }

  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    void Function(String, int?)? onCodeSent,
    void Function(BackendAuthException)? onFailed,
    void Function(PhoneAuthCredential)? onAutoVerified,
    void Function(String)? onTimeout,
    int? forceResendingToken,
    Duration? timeout,
    void Function(PhoneAuthCredential)? verificationCompleted,
    void Function(BackendAuthException)? verificationFailed,
    void Function(String, int?)? codeSent,
    void Function(String)? codeAutoRetrievalTimeout,
  }) async {
    final error = BackendAuthException(
      code: 'unsupported-provider',
      message: 'Phone authentication has been removed. Use email OTP.',
    );
    (onFailed ?? verificationFailed)?.call(error);
  }

  Future<void> sendPasswordResetEmail({required String email}) async =>
      _apiClient.post(
        '/api/v1/auth/forgot-password',
        body: <String, dynamic>{'email': email.trim().toLowerCase()},
      );
  Future<void> sendEmailOtp([String? email]) async {
    final String targetEmail =
        (email ?? _currentUser?.email ?? '').trim().toLowerCase();
    await _apiClient.post(
      '/api/v1/auth/email-otp/send',
      body: <String, dynamic>{'email': targetEmail},
    );
  }

  Future<void> verifyResetOtp({
    required String email,
    required String otpCode,
  }) async =>
      _apiClient.post(
        '/api/v1/auth/email-otp/verify-reset',
        body: <String, dynamic>{
          'email': email.trim().toLowerCase(),
          'otp': otpCode.trim(),
        },
      );

  Future<void> resetPassword({
    required String email,
    required String otpCode,
    required String newPassword,
  }) async =>
      _apiClient.post(
        '/api/v1/auth/reset-password',
        body: <String, dynamic>{
          'email': email.trim().toLowerCase(),
          'otpCode': otpCode.trim(),
          'newPassword': newPassword,
        },
      );
  Future<void> reload() async => _currentUser?.reload();

  Future<void> signOut() async {
    _currentUser = null;
    _accessToken = null;
    await _storage.delete('access_token');
    await _storage.delete('refresh_token');
    _changes.add(null);
  }

  Future<UserCredential> _complete(
    dynamic value, {
    required String email,
  }) async {
    if (value is! Map) throw BackendAuthException(code: 'invalid-response');
    final data = Map<String, dynamic>.from(value);
    final token = (data['accessToken'] ?? data['token'] ?? '').toString();
    if (token.trim().isEmpty)
      throw BackendAuthException(
        code: 'authentication-pending',
        message:
            (data['message'] ?? 'Email verification is required.').toString(),
      );
    _accessToken = token;
    await _storage.write('access_token', token);
    final refresh = (data['refreshToken'] ?? '').toString();
    if (refresh.isNotEmpty) await _storage.write('refresh_token', refresh);
    final claims = _claims(token);
    _currentUser = User(
      uid: (claims['sub'] ?? data['userId'] ?? email).toString(),
      email: (data['email'] ?? email).toString(),
      displayName: (data['name'] ?? '').toString(),
    );
    _changes.add(_currentUser);
    return UserCredential(_currentUser);
  }

  Map<String, dynamic> _claims(String token) {
    try {
      final parts = token.split('.');
      if (parts.length < 2) return <String, dynamic>{};
      final decoded = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );
      return decoded is Map
          ? Map<String, dynamic>.from(decoded)
          : <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }
}
