import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/backend_config.dart';
import '../errors/error_handler.dart';
import '../errors/network_exception.dart';
import '../services/secure_storage_service.dart';
import 'api_response.dart';
import 'network_info.dart';
import 'request_interceptor.dart';

class ApiClient {
  ApiClient({
    http.Client? client,
    NetworkInfo? networkInfo,
    RequestInterceptor? interceptor,
    AccessTokenProvider? accessTokenProvider,
    Duration? timeout,
  }) : _client = client ?? http.Client(),
       _networkInfo = networkInfo,
       _interceptor =
           interceptor ??
           RequestInterceptor(
             accessTokenProvider:
                 accessTokenProvider ??
                 () => SecureStorageService().read('access_token'),
           ),
       _timeout = timeout ?? BackendConfig.receiveTimeout;

  final http.Client _client;
  final NetworkInfo? _networkInfo;
  final RequestInterceptor _interceptor;
  final Duration _timeout;

  Future<ApiResponse<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) =>
      _request('GET', path, queryParameters: queryParameters, headers: headers);

  Future<ApiResponse<dynamic>> post(
    String path, {
    Object? body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) => _request(
    'POST',
    path,
    body: body,
    queryParameters: queryParameters,
    headers: headers,
  );

  Future<ApiResponse<dynamic>> put(
    String path, {
    Object? body,
    Map<String, dynamic>? queryParameters,
  }) => _request('PUT', path, body: body, queryParameters: queryParameters);
  Future<ApiResponse<dynamic>> patch(String path, {Object? body}) =>
      _request('PATCH', path, body: body);
  Future<ApiResponse<dynamic>> delete(
    String path, {
    Object? body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) => _request(
    'DELETE',
    path,
    body: body,
    queryParameters: queryParameters,
    headers: headers,
  );

  Future<ApiResponse<dynamic>> _request(
    String method,
    String path, {
    Object? body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    if (_networkInfo != null && !await _networkInfo.isConnected) {
      throw NetworkException.offline;
    }
    try {
      final Uri uri = BackendConfig.uri(path, queryParameters: queryParameters);
      final http.Request request = await _interceptor.prepare(
        method,
        uri,
        headers: headers,
        body: body,
      );
      final http.StreamedResponse streamed = await _client
          .send(request)
          .timeout(_timeout);
      final http.Response response = await http.Response.fromStream(streamed);
      final dynamic decoded = _decode(response.body);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw NetworkException.fromStatusCode(
          response.statusCode,
          details: decoded,
        );
      }
      if (decoded is Map<String, dynamic>) {
        final bool isSuccessFlag =
            decoded['success'] != false && decoded['isSuccess'] != false;
        if (!isSuccessFlag) {
          final String errMsg =
              (decoded['message'] ?? decoded['error'] ?? 'Operation failed')
                  .toString();
          throw NetworkException(
            message: errMsg,
            statusCode: response.statusCode,
            details: decoded,
          );
        }
        return ApiResponse<dynamic>(
          isSuccess: true,
          data: decoded['data'] ?? decoded,
          message: decoded['message']?.toString() ?? '',
          statusCode: response.statusCode,
          metadata: _map(decoded['metadata'] ?? decoded['meta']),
        );
      }
      return ApiResponse<dynamic>.success(
        decoded,
        statusCode: response.statusCode,
      );
    } on TimeoutException {
      throw NetworkException.timeout;
    } on NetworkException {
      rethrow;
    } catch (error, stackTrace) {
      throw ErrorHandler.handle(error, stackTrace);
    }
  }

  dynamic _decode(String body) {
    if (body.trim().isEmpty) return null;
    try {
      return jsonDecode(body);
    } on FormatException {
      return body;
    }
  }

  Map<String, dynamic> _map(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

  void dispose() => _client.close();
}
