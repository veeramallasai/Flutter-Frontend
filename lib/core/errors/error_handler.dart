import 'dart:async';

import 'package:farm_to_home_app/core/auth/backend_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' show ClientException;

import 'app_exception.dart';
import 'firestore_exception.dart';
import 'network_exception.dart';

class ErrorHandler {
  ErrorHandler._();

  static AppException handle(Object error, [StackTrace? stackTrace]) {
    if (error is AppException) return error;
    if (error is BackendAuthException) {
      return BackendAuthException.fromCode(error.code, details: error.message);
    }
    if (error is FirebaseException) {
      return FirestoreException.fromCode(error.code, details: error.message);
    }
    if (error is TimeoutException) return NetworkException.timeout;
    if (error is ClientException) {
      return NetworkException(
        message: 'Unable to connect to the server. Please try again.',
        code: 'network/client',
        details: error.message,
      );
    }
    if (error is FormatException) {
      return AppException(
        message: 'The received information could not be read.',
        code: 'format/invalid',
        details: error.message,
      );
    }
    if (error is StateError) {
      final String message = error.message.toString().trim();
      return AppException(
        message:
            message.isEmpty ? 'The action could not be completed.' : message,
        code: 'state/invalid',
        details: error,
      );
    }
    return AppException(
      message: 'Something went wrong. Please try again.',
      details: <String, Object?>{'error': error, 'stackTrace': stackTrace},
    );
  }

  static String message(Object error) => handle(error).message;
  static bool canRetry(Object error) => handle(error).isRetryable;
}
