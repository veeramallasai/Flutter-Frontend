import 'dart:convert';

import 'package:farm_to_home_app/core/auth/backend_auth.dart';
import 'package:farm_to_home_app/core/network/api_client.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('pending email verification is a successful registration state', () async {
    final ApiClient apiClient = ApiClient(
      client: MockClient((http.Request request) async {
        expect(request.url.path, '/api/v1/auth/register');
        return http.Response(
          jsonEncode(<String, dynamic>{
            'success': true,
            'data': <String, dynamic>{
              'email': 'sai@example.com',
              'maskedEmail': 's***i@example.com',
              'requiresEmailVerification': true,
              'message':
                  'Registration successful. Please verify the OTP sent to your email.',
              'expiresInSeconds': 600,
            },
            'message':
                'Registration successful. Please verify the OTP sent to your email.',
          }),
          200,
          headers: <String, String>{'content-type': 'application/json'},
        );
      }),
      accessTokenProvider: () async => null,
    );
    final BackendAuth auth = BackendAuth.forTesting(apiClient);

    final UserCredential credential = await auth.createUserWithEmailAndPassword(
      email: 'sai@example.com',
      password: 'StrongPass9',
      firstName: 'Sai',
      lastName: 'Sai',
    );

    expect(credential.user?.email, 'sai@example.com');
    expect(credential.authenticationPending, isTrue);
    expect(credential.emailVerificationSent, isTrue);
    expect(auth.currentUser, isNull);
  });

  test('string pending flag is accepted', () async {
    final ApiClient apiClient = ApiClient(
      client: MockClient((http.Request request) async {
        return http.Response(
          jsonEncode(<String, dynamic>{
            'success': true,
            'data': <String, dynamic>{
              'email': 'sai@example.com',
              'requiresEmailVerification': 'true',
            },
          }),
          200,
          headers: <String, String>{'content-type': 'application/json'},
        );
      }),
      accessTokenProvider: () async => null,
    );

    final UserCredential credential = await BackendAuth.forTesting(
      apiClient,
    ).createUserWithEmailAndPassword(
      email: 'sai@example.com',
      password: 'StrongPass9',
    );

    expect(credential.authenticationPending, isTrue);
    expect(credential.emailVerificationSent, isTrue);
  });
}
