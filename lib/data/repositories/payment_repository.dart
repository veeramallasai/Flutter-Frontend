import 'package:firebase_auth/firebase_auth.dart';

import '../models/payment_model.dart';
import '../remote/payment_remote_source.dart';

class PaymentRepository {
  PaymentRepository({
    PaymentRemoteSource? remoteSource,
    FirebaseAuth? auth,
  })  : _remoteSource = remoteSource ?? PaymentRemoteSource(),
        _auth = auth ?? FirebaseAuth.instance;

  final PaymentRemoteSource _remoteSource;
  final FirebaseAuth _auth;

  String? get currentUserId => _auth.currentUser?.uid;

  Stream<List<PaymentModel>> watchCurrentUserPayments({int limit = 50}) {
    return _remoteSource.watchUserPayments(_requireUserId(), limit: limit);
  }

  Future<List<PaymentModel>> getCurrentUserPayments({int limit = 50}) {
    return _remoteSource.getUserPayments(_requireUserId(), limit: limit);
  }

  Stream<PaymentModel?> watchPayment(String paymentId) {
    final String userId = _requireUserId();
    return _remoteSource.watchPayment(paymentId).map((PaymentModel? payment) {
      if (payment != null) _verifyOwnership(payment, userId);
      return payment;
    });
  }

  Future<PaymentModel?> getPayment(String paymentId) async {
    final String userId = _requireUserId();
    final PaymentModel? payment = await _remoteSource.getPayment(paymentId);
    if (payment != null) _verifyOwnership(payment, userId);
    return payment;
  }

  Future<PaymentModel?> getPaymentForOrder(String orderId) async {
    final String userId = _requireUserId();
    final PaymentModel? payment =
    await _remoteSource.getPaymentForOrder(orderId);
    if (payment != null) _verifyOwnership(payment, userId);
    return payment;
  }

  Future<String> createPayment(PaymentModel payment) {
    final String userId = _requireUserId();
    final PaymentModel userPayment = payment.userId == userId
        ? payment
        : payment.copyWith(userId: userId);
    return _remoteSource.createPayment(userPayment);
  }

  Future<void> updatePaymentStatus({
    required String paymentId,
    required String status,
    String transactionId = '',
  }) async {
    final PaymentModel? payment = await getPayment(paymentId);
    if (payment == null) throw StateError('Payment not found.');

    await _remoteSource.updatePaymentStatus(
      paymentId: paymentId,
      status: status,
      transactionId: transactionId,
    );
  }

  void _verifyOwnership(PaymentModel payment, String userId) {
    if (payment.userId != userId) {
      throw StateError('You do not have access to this payment.');
    }
  }

  String _requireUserId() {
    final String userId = currentUserId?.trim() ?? '';
    if (userId.isEmpty) throw StateError('Please login to continue.');
    return userId;
  }
}
