import 'package:cloud_functions/cloud_functions.dart';

import '../network/api_response.dart';

class CloudFunctionsService {
  CloudFunctionsService({FirebaseFunctions? functions})
    : _functions =
          functions ?? FirebaseFunctions.instanceFor(region: 'asia-south1');

  final FirebaseFunctions _functions;

  Future<ApiResponse<dynamic>> call(
    String functionName, {
    Map<String, dynamic> data = const <String, dynamic>{},
  }) async {
    final String name = functionName.trim().replaceAll(
      RegExp(r'[^a-zA-Z0-9_-]+'),
      '',
    );
    if (name.isEmpty) throw ArgumentError.value(functionName, 'functionName');
    try {
      final HttpsCallableResult<dynamic> result = await _functions
          .httpsCallable(name)
          .call<dynamic>(data);
      return ApiResponse<dynamic>.success(result.data);
    } on FirebaseFunctionsException catch (error) {
      return ApiResponse<dynamic>.failure(
        message: error.message ?? 'Cloud function failed.',
        errorCode: error.code,
      );
    }
  }

  Future<ApiResponse<dynamic>> calculateDeliveryFee({
    required String pincode,
    required double subtotal,
    required String method,
  }) => call(
    'calculateDeliveryFee',
    data: <String, dynamic>{
      'pincode': pincode,
      'subtotal': subtotal,
      'method': method,
    },
  );

  Future<ApiResponse<dynamic>> sendOrderNotification(String orderId) => call(
    'sendOrderNotification',
    data: <String, dynamic>{'orderId': orderId},
  );

  void dispose() {}
}
