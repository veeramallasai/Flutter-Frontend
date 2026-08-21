import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/models/payment_model.dart';
import '../data/repositories/payment_repository.dart';

class PaymentProvider extends ChangeNotifier {
  PaymentProvider({PaymentRepository? repository})
      : _repository = repository ?? PaymentRepository();

  final PaymentRepository _repository;

  StreamSubscription<List<PaymentModel>>? _subscription;
  List<PaymentModel> _payments = <PaymentModel>[];
  bool _isLoading = false;
  bool _isProcessing = false;
  String _processingPaymentId = '';
  String? _errorMessage;
  bool _disposed = false;

  List<PaymentModel> get payments =>
      List<PaymentModel>.unmodifiable(_payments);
  bool get isLoading => _isLoading;
  bool get isProcessing => _isProcessing;
  String get processingPaymentId => _processingPaymentId;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage?.trim().isNotEmpty ?? false;
  PaymentModel? get latestPayment =>
      _payments.isEmpty ? null : _payments.first;

  void listenToPayments({int limit = 50}) {
    _subscription?.cancel();
    _isLoading = true;
    _errorMessage = null;
    _notify();

    try {
      _subscription = _repository
          .watchCurrentUserPayments(limit: limit)
          .listen(
            (List<PaymentModel> values) {
          if (_disposed) return;
          _payments = List<PaymentModel>.from(values);
          _isLoading = false;
          _errorMessage = null;
          _notify();
        },
        onError: (Object error, StackTrace stackTrace) {
          if (_disposed) return;
          _isLoading = false;
          _errorMessage = _friendlyError(error);
          _notify();
        },
      );
    } catch (error) {
      _isLoading = false;
      _errorMessage = _friendlyError(error);
      _notify();
    }
  }

  Future<void> refresh({int limit = 50}) async {
    _isLoading = true;
    _errorMessage = null;
    _notify();

    try {
      _payments = await _repository.getCurrentUserPayments(limit: limit);
      _errorMessage = null;
    } catch (error) {
      _errorMessage = _friendlyError(error);
    } finally {
      _isLoading = false;
      _notify();
    }
  }

  Future<bool> updateStatus({
    required String paymentId,
    required String status,
    String transactionId = '',
  }) async {
    if (_isProcessing || paymentId.trim().isEmpty) return false;

    _isProcessing = true;
    _processingPaymentId = paymentId.trim();
    _errorMessage = null;
    _notify();

    try {
      await _repository.updatePaymentStatus(
        paymentId: paymentId,
        status: status,
        transactionId: transactionId,
      );
      return true;
    } catch (error) {
      _errorMessage = _friendlyError(error);
      return false;
    } finally {
      _isProcessing = false;
      _processingPaymentId = '';
      _notify();
    }
  }

  PaymentModel? findPayment(String paymentId) {
    final String id = paymentId.trim();
    for (final PaymentModel payment in _payments) {
      if (payment.id == id || payment.paymentId == id) return payment;
    }
    return null;
  }

  void clearError() {
    _errorMessage = null;
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  String _friendlyError(Object error) {
    String message = error.toString().trim();
    if (message.startsWith('Bad state: ')) {
      message = message.substring('Bad state: '.length);
    }
    return message.isEmpty ? 'Unable to process payment.' : message;
  }

  @override
  void dispose() {
    _disposed = true;
    _subscription?.cancel();
    super.dispose();
  }
}
