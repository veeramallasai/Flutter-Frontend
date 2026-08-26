class ApiResponse<T> {
  const ApiResponse({
    required this.isSuccess,
    this.data,
    this.message = '',
    this.statusCode = 0,
    this.errorCode = '',
    this.metadata = const <String, dynamic>{},
  });

  final bool isSuccess;
  final T? data;
  final String message;
  final int statusCode;
  final String errorCode;
  final Map<String, dynamic> metadata;

  bool get hasData => data != null;

  factory ApiResponse.success(
    T data, {
    String message = '',
    int statusCode = 200,
    Map<String, dynamic> metadata = const <String, dynamic>{},
  }) {
    return ApiResponse<T>(
      isSuccess: true,
      data: data,
      message: message,
      statusCode: statusCode,
      metadata: Map<String, dynamic>.unmodifiable(metadata),
    );
  }

  factory ApiResponse.failure({
    required String message,
    int statusCode = 0,
    String errorCode = '',
    Map<String, dynamic> metadata = const <String, dynamic>{},
  }) {
    return ApiResponse<T>(
      isSuccess: false,
      message: message,
      statusCode: statusCode,
      errorCode: errorCode,
      metadata: Map<String, dynamic>.unmodifiable(metadata),
    );
  }

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic value) decoder,
  ) {
    final int statusCode = _integer(json['statusCode'] ?? json['status']);
    final bool success =
        json['success'] == true || (statusCode >= 200 && statusCode < 300);
    return ApiResponse<T>(
      isSuccess: success,
      data: json['data'] == null ? null : decoder(json['data']),
      message: json['message']?.toString() ?? '',
      statusCode: statusCode,
      errorCode:
          json['errorCode']?.toString() ?? json['code']?.toString() ?? '',
      metadata: _map(json['metadata'] ?? json['meta']),
    );
  }

  ApiResponse<R> map<R>(R Function(T value) transform) {
    return ApiResponse<R>(
      isSuccess: isSuccess,
      data: data == null ? null : transform(data as T),
      message: message,
      statusCode: statusCode,
      errorCode: errorCode,
      metadata: metadata,
    );
  }
}

int _integer(dynamic value) =>
    value is num ? value.toInt() : int.tryParse('$value') ?? 0;
Map<String, dynamic> _map(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};
