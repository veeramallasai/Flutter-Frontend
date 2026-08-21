import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/payment_model.dart';

class PaymentRemoteSource {
  PaymentRemoteSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _payments =>
      _firestore.collection('payments');

  Stream<List<PaymentModel>> watchUserPayments(
      String userId, {
        int limit = 50,
      }) {
    final String normalizedUserId = userId.trim();
    if (normalizedUserId.isEmpty) {
      return Stream<List<PaymentModel>>.value(<PaymentModel>[]);
    }

    return _payments
        .where('userId', isEqualTo: normalizedUserId)
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snapshot) {
      final List<PaymentModel> payments = snapshot.docs
          .map(PaymentModel.fromDocument)
          .toList(growable: true);
      return _sortAndLimit(payments, limit);
    });
  }

  Future<List<PaymentModel>> getUserPayments(
      String userId, {
        int limit = 50,
      }) async {
    final String normalizedUserId = userId.trim();
    if (normalizedUserId.isEmpty) return <PaymentModel>[];

    final QuerySnapshot<Map<String, dynamic>> snapshot = await _payments
        .where('userId', isEqualTo: normalizedUserId)
        .get();
    final List<PaymentModel> payments = snapshot.docs
        .map(PaymentModel.fromDocument)
        .toList(growable: true);
    return _sortAndLimit(payments, limit);
  }

  Stream<PaymentModel?> watchPayment(String paymentId) {
    final String id = paymentId.trim();
    if (id.isEmpty) return Stream<PaymentModel?>.value(null);

    return _payments.doc(id).snapshots().map(
          (DocumentSnapshot<Map<String, dynamic>> document) {
        if (!document.exists || document.data() == null) return null;
        return PaymentModel.fromDocument(document);
      },
    );
  }

  Future<PaymentModel?> getPayment(String paymentId) async {
    final String id = paymentId.trim();
    if (id.isEmpty) return null;

    final DocumentSnapshot<Map<String, dynamic>> document =
    await _payments.doc(id).get();
    if (!document.exists || document.data() == null) return null;
    return PaymentModel.fromDocument(document);
  }

  Future<PaymentModel?> getPaymentForOrder(String orderId) async {
    final String id = orderId.trim();
    if (id.isEmpty) return null;

    final QuerySnapshot<Map<String, dynamic>> snapshot = await _payments
        .where('orderId', isEqualTo: id)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    return PaymentModel.fromDocument(snapshot.docs.first);
  }

  Future<String> createPayment(PaymentModel payment) async {
    final DocumentReference<Map<String, dynamic>> reference =
    payment.id.trim().isEmpty
        ? _payments.doc()
        : _payments.doc(payment.id.trim());

    await reference.set(<String, dynamic>{
      ...payment.toMap(),
      'id': reference.id,
      'paymentId': reference.id,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return reference.id;
  }

  Future<void> updatePaymentStatus({
    required String paymentId,
    required String status,
    String transactionId = '',
  }) async {
    final String id = paymentId.trim();
    final String normalizedStatus = status.trim().toLowerCase();
    if (id.isEmpty || normalizedStatus.isEmpty) {
      throw ArgumentError('Payment ID and status are required.');
    }

    await _payments.doc(id).update(<String, dynamic>{
      'status': normalizedStatus,
      if (transactionId.trim().isNotEmpty)
        'transactionId': transactionId.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  List<PaymentModel> _sortAndLimit(
      List<PaymentModel> payments,
      int limit,
      ) {
    payments.sort((PaymentModel first, PaymentModel second) {
      final DateTime firstDate =
          first.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final DateTime secondDate =
          second.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return secondDate.compareTo(firstDate);
    });

    if (limit <= 0 || payments.length <= limit) {
      return List<PaymentModel>.unmodifiable(payments);
    }
    return List<PaymentModel>.unmodifiable(payments.take(limit));
  }
}
