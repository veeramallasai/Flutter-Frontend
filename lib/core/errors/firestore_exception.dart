import 'app_exception.dart';

class FirestoreException extends AppException {
  const FirestoreException({
    required super.message,
    super.code = 'firestore/unknown',
    super.details,
    super.isRetryable = false,
  });

  factory FirestoreException.fromCode(String code, {Object? details}) {
    String message;
    switch (code) {
      case 'permission-denied':
        message = 'You do not have permission to access this information.';
        break;
      case 'not-found':
        message = 'The requested information was not found.';
        break;
      case 'already-exists':
        message = 'This record already exists.';
        break;
      case 'unavailable':
        message = 'The service is temporarily unavailable. Please try again.';
        break;
      case 'deadline-exceeded':
        message = 'The request took too long. Please try again.';
        break;
      default:
        message = 'Unable to load the requested information.';
    }
    return FirestoreException(
      code: code,
      message: message,
      details: details,
      isRetryable: <String>{
        'unavailable',
        'deadline-exceeded',
        'aborted',
      }.contains(code),
    );
  }
}
