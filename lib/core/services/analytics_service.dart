import 'package:flutter/foundation.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  AnalyticsService({FirebaseAnalytics? analytics})
    : _analytics = analytics ?? FirebaseAnalytics.instance;

  final FirebaseAnalytics _analytics;

  Future<void> logEvent(
    String event, {
    Map<String, Object?> parameters = const <String, Object?>{},
  }) async {
    final String name = _normalize(event);
    if (name.isEmpty) return;
    if (kDebugMode) debugPrint('[Analytics] $name $parameters');
    await _analytics.logEvent(
      name: name,
      parameters: <String, Object>{
        for (final MapEntry<String, Object?> entry in parameters.entries)
          if (entry.value != null) entry.key: entry.value!,
      },
    );
  }

  Future<void> logScreen(String screenName) => logEvent(
    'screen_view',
    parameters: <String, Object?>{'screen_name': screenName.trim()},
  );

  Future<void> logLogin(String method) =>
      logEvent('login', parameters: <String, Object?>{'method': method.trim()});

  Future<void> logAddToCart({
    required String productId,
    required double value,
  }) => logEvent(
    'add_to_cart',
    parameters: <String, Object?>{
      'product_id': productId,
      'value': value,
      'currency': 'INR',
    },
  );

  Future<void> logPurchase({required String orderId, required double value}) =>
      logEvent(
        'purchase',
        parameters: <String, Object?>{
          'order_id': orderId,
          'value': value,
          'currency': 'INR',
        },
      );

  String _normalize(String value) => value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9_]+'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');
}
