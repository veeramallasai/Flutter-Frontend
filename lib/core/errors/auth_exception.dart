import 'app_exception.dart';

class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.code = 'auth/unknown',
    super.details,
    super.isRetryable = false,
  });

  factory AuthException.fromCode(String code, {Object? details}) {
    return AuthException(
      code: code,
      message: _messageFor(code),
      details: details,
      isRetryable: <String>{
        'network-request-failed',
        'too-many-requests',
        'internal-error',
      }.contains(code),
    );
  }

  static String _messageFor(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-not-found':
        return 'No account was found with this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'The email or password is incorrect.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Choose a stronger password.';
      case 'invalid-verification-code':
        return 'The verification code is incorrect.';
      case 'session-expired':
        return 'The verification session expired. Please try again.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait and try again.';
      case 'network-request-failed':
        return 'Check your internet connection and try again.';
      default:
        return 'Authentication could not be completed. Please try again.';
    }
  }
}
