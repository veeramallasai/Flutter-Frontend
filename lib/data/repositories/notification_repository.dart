import '../../core/network/api_client.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  NotificationRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Stream<List<NotificationModel>> watchNotifications({int limit = 50}) async* {
    yield await getNotifications(limit: limit);
  }

  Future<List<NotificationModel>> getNotifications({int limit = 50}) async {
    final dynamic data =
        (await _apiClient.get(
          '/api/v1/notifications',
          queryParameters: <String, dynamic>{'limit': limit},
        )).data;
    final List<NotificationModel> values = _maps(
      data,
    ).map(NotificationModel.fromMap).toList(growable: true)..sort(
      (NotificationModel a, NotificationModel b) =>
          (b.createdAt ?? DateTime(1970)).compareTo(
            a.createdAt ?? DateTime(1970),
          ),
    );
    return List<NotificationModel>.unmodifiable(values);
  }

  Stream<int> watchUnreadCount() => watchNotifications().map(
    (List<NotificationModel> values) =>
        values.where((NotificationModel n) => !n.isRead).length,
  );

  Future<void> markAsRead(String notificationId) async {
    final String id = notificationId.trim();
    if (id.isEmpty) return;
    await _apiClient.patch('/api/v1/notifications/$id/read');
  }

  Future<void> markAllAsRead() async {
    await _apiClient.patch('/api/v1/notifications/read-all');
  }

  Future<void> deleteNotification(String notificationId) async {
    final String id = notificationId.trim();
    if (id.isEmpty) return;
    await _apiClient.delete('/api/v1/notifications/$id');
  }

  Future<Map<String, bool>> getPreferences() async {
    final dynamic data =
        (await _apiClient.get('/api/v1/notification-preferences')).data;
    final Map<String, dynamic> value =
        data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{};
    return <String, bool>{
      'orderUpdates': value['orderUpdates'] != false,
      'offers': value['offers'] != false,
    };
  }

  Future<Map<String, bool>> updatePreferences({
    required bool orderUpdates,
    required bool offers,
  }) async {
    final dynamic data =
        (await _apiClient.put(
          '/api/v1/notification-preferences',
          body: <String, dynamic>{
            'orderUpdates': orderUpdates,
            'offers': offers,
          },
        )).data;
    final Map<String, dynamic> value =
        data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{};
    return <String, bool>{
      'orderUpdates': value['orderUpdates'] != false,
      'offers': value['offers'] != false,
    };
  }
}

List<Map<String, dynamic>> _maps(dynamic data) =>
    data is Iterable
        ? data
            .whereType<Map>()
            .map((Map value) => Map<String, dynamic>.from(value))
            .toList()
        : <Map<String, dynamic>>[];
