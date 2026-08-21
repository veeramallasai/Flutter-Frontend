import '../../core/network/api_client.dart';
import '../models/review_model.dart';

class ReviewRepository {
  ReviewRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Stream<List<ReviewModel>> watchProductReviews(String productId) async* {
    yield await getProductReviews(productId);
  }

  Future<List<ReviewModel>> getProductReviews(String productId) async {
    final String id = productId.trim();
    if (id.isEmpty) return <ReviewModel>[];
    final dynamic data =
        (await _apiClient.get('/api/v1/products/$id/reviews')).data;
    final List<ReviewModel> values = _maps(data)
        .map(ReviewModel.fromMap)
        .toList(growable: true)
      ..sort(
        (ReviewModel a, ReviewModel b) =>
            (b.createdAt ?? DateTime(1970))
                .compareTo(a.createdAt ?? DateTime(1970)),
      );
    return List<ReviewModel>.unmodifiable(values);
  }

  Future<String> saveReview(ReviewModel review) async {
    final String productId = review.productId.trim();
    if (productId.isEmpty) {
      throw ArgumentError('Product is required.');
    }

    final dynamic data = (await _apiClient.post(
      '/api/v1/products/$productId/reviews',
      body: <String, dynamic>{
        'userName': review.userName,
        'rating': review.rating,
        'comment': review.comment,
        'images': review.images,
      },
    ))
        .data;

    return data is Map ? (data['id']?.toString() ?? '') : '';
  }

  Future<void> deleteReview(String reviewId) async {
    final String id = reviewId.trim();
    if (id.isEmpty) return;
    await _apiClient.delete('/api/v1/reviews/$id');
  }

  Future<Map<String, dynamic>> getDeliveryPartner(String orderId) async {
    final String id = orderId.trim();
    if (id.isEmpty) return <String, dynamic>{};
    final dynamic data =
        (await _apiClient.get('/api/v1/orders/$id/delivery-partner')).data;
    return _map(data);
  }

  Future<Map<String, dynamic>> getDeliveryPartnerReview(String orderId) async {
    final String id = orderId.trim();
    if (id.isEmpty) return <String, dynamic>{};
    final dynamic data =
        (await _apiClient.get('/api/v1/orders/$id/delivery-partner/review')).data;
    return _map(data);
  }

  Future<Map<String, dynamic>> saveDeliveryPartnerReview({
    required String orderId,
    required double rating,
    String comment = '',
  }) async {
    final String id = orderId.trim();
    if (id.isEmpty) {
      throw ArgumentError('Order is required.');
    }

    final dynamic data = (await _apiClient.post(
      '/api/v1/orders/$id/delivery-partner/review',
      body: <String, dynamic>{
        'rating': rating,
        'comment': comment.trim(),
      },
    ))
        .data;

    return _map(data);
  }

  Future<void> deleteDeliveryPartnerReview(String orderId) async {
    final String id = orderId.trim();
    if (id.isEmpty) return;
    await _apiClient.delete('/api/v1/orders/$id/delivery-partner/review');
  }
}

List<Map<String, dynamic>> _maps(dynamic data) => data is Iterable
    ? data
        .whereType<Map>()
        .map((Map value) => Map<String, dynamic>.from(value))
        .toList()
    : <Map<String, dynamic>>[];

Map<String, dynamic> _map(dynamic data) =>
    data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{};
