import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../../data/repositories/device_repository.dart';

class NotificationService {
  NotificationService({
    FirebaseMessaging? messaging,
    DeviceRepository? deviceRepository,
  })  : _messaging = messaging ?? FirebaseMessaging.instance,
        _deviceRepository = deviceRepository ?? DeviceRepository();

  final FirebaseMessaging _messaging;
  final DeviceRepository _deviceRepository;

  Stream<RemoteMessage> get foregroundMessages =>
      FirebaseMessaging.onMessage;

  Stream<RemoteMessage> get openedMessages =>
      FirebaseMessaging.onMessageOpenedApp;

  Stream<String> get tokenRefreshes => _messaging.onTokenRefresh;

  Future<NotificationSettings> requestPermission({
    bool sound = true,
    bool badge = true,
    bool alert = true,
  }) => _messaging.requestPermission(
        alert: alert,
        badge: badge,
        sound: sound,
        provisional: false,
      );

  Future<String?> getToken({String? vapidKey}) =>
      _messaging.getToken(vapidKey: vapidKey);

  Future<RemoteMessage?> getInitialMessage() =>
      _messaging.getInitialMessage();

  Future<void> subscribeToTopic(String topic) =>
      _messaging.subscribeToTopic(_cleanTopic(topic));

  Future<void> unsubscribeFromTopic(String topic) =>
      _messaging.unsubscribeFromTopic(_cleanTopic(topic));

  Future<void> deleteToken() => _messaging.deleteToken();

  Future<bool> registerCurrentDevice({String? vapidKey}) async {
    try {
      final NotificationSettings settings = await requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        return false;
      }
      final String? token = await getToken(vapidKey: vapidKey);
      if (token == null || token.trim().isEmpty) return false;
      await _deviceRepository.register(
        token: token,
        platform: _platformName,
        deviceName: kIsWeb ? 'Web browser' : defaultTargetPlatform.name,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> unregisterCurrentDevice({String? vapidKey}) async {
    try {
      final String? token = await getToken(vapidKey: vapidKey);
      if (token != null && token.trim().isNotEmpty) {
        await _deviceRepository.unregister(token);
      }
    } finally {
      await deleteToken();
    }
  }

  String get _platformName => kIsWeb ? 'web' : defaultTargetPlatform.name;

  String _cleanTopic(String value) {
    final String topic = value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9-_.~%]+'), '-');
    if (topic.isEmpty) {
      throw ArgumentError.value(value, 'topic', 'Topic cannot be empty.');
    }
    return topic;
  }
}
