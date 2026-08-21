import 'dart:convert';

import 'package:http/http.dart' as http;

typedef AccessTokenProvider = Future<String?> Function();

class RequestInterceptor {
  const RequestInterceptor({
    this.accessTokenProvider,
    this.defaultHeaders = const <String, String>{},
  });

  final AccessTokenProvider? accessTokenProvider;
  final Map<String, String> defaultHeaders;

  Future<http.Request> prepare(
    String method,
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final http.Request request = http.Request(method.toUpperCase(), uri);
    request.headers.addAll(<String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json; charset=utf-8',
      ...defaultHeaders,
      ...?headers,
    });
    final String token = (await accessTokenProvider?.call())?.trim() ?? '';
    if (token.isNotEmpty) request.headers['Authorization'] = 'Bearer $token';
    if (body != null) {
      request.body = body is String ? body : jsonEncode(body);
    }
    return request;
  }
}
