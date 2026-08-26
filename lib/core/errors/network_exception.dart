import 'app_exception.dart';

class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.code = 'network/unknown',
    super.details,
    super.isRetryable = true,
    this.statusCode,
  });

  final int? statusCode;

  factory NetworkException.fromStatusCode(int statusCode, {Object? details}) {
    String message;
    switch (statusCode) {
      case 400:
        message = 'Some information is invalid. Please check and try again.';
        break;
      case 401:
        message = 'Your session expired. Please login again.';
        break;
      case 403:
        message = 'You do not have permission to perform this action.';
        break;
      case 404:
        message = 'The requested information was not found.';
        break;
      case 409:
        message = 'The request conflicts with an existing record.';
        break;
      case 429:
        message = 'Too many requests. Please wait and try again.';
        break;
      default:
        message =
            statusCode >= 500
                ? 'The server is temporarily unavailable.'
                : 'The request could not be completed.';
    }
    if (details is Map) {
      final String backendMessage = details['message']?.toString().trim() ?? '';
      if (backendMessage.isNotEmpty) message = backendMessage;
    }
    return NetworkException(
      message: message,
      code: 'http/$statusCode',
      statusCode: statusCode,
      details: details,
      isRetryable: statusCode == 408 || statusCode == 429 || statusCode >= 500,
    );
  }

  static const NetworkException timeout = NetworkException(
    message: 'The request timed out. Please try again.',
    code: 'network/timeout',
  );
  static const NetworkException offline = NetworkException(
    message: 'No internet connection. Please check your network.',
    code: 'network/offline',
  );
}
