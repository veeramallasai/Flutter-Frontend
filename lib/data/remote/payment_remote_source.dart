import '../../core/network/api_client.dart';
import '../models/payment_model.dart';

class PaymentRemoteSource {
  PaymentRemoteSource({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Stream<List<PaymentModel>> watchUserPayments(
    String userId, {
    int limit = 50,
  }) async* {
    yield await getUserPayments(userId, limit: limit);
  }

  Future<List<PaymentModel>> getUserPayments(
    String userId, {
    int limit = 50,
  }) async {
    return <PaymentModel>[];
  }

  Stream<PaymentModel?> watchPayment(String paymentId) async* {
    yield await getPayment(paymentId);
  }

  Future<PaymentModel?> getPayment(String paymentId) async {
    return null;
  }

  Future<PaymentModel?> getPaymentForOrder(String orderId) async {
    return null;
  }

  Future<String> createPayment(PaymentModel payment) async {
    return payment.id.isNotEmpty ? payment.id : 'pay_${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<void> updatePaymentStatus({
    required String paymentId,
    required String status,
    String transactionId = '',
  }) async {}
}
