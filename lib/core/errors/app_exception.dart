class AppException implements Exception {
  const AppException({
    required this.message,
    this.code = 'unknown',
    this.details,
    this.isRetryable = false,
  });

  final String message;
  final String code;
  final Object? details;
  final bool isRetryable;

  AppException copyWith({
    String? message,
    String? code,
    Object? details,
    bool? isRetryable,
  }) {
    return AppException(
      message: message ?? this.message,
      code: code ?? this.code,
      details: details ?? this.details,
      isRetryable: isRetryable ?? this.isRetryable,
    );
  }

  @override
  String toString() => 'AppException(code: $code, message: $message)';
}
