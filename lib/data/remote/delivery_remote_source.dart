import '../../core/network/api_client.dart';
import '../models/delivery_slot_model.dart';

class DeliveryRemoteSource {
  DeliveryRemoteSource({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Stream<List<DeliverySlotModel>> watchSlots({
    required String method,
    DateTime? date,
  }) async* {
    yield await getSlots(method: method, date: date);
  }

  Future<List<DeliverySlotModel>> getSlots({
    required String method,
    DateTime? date,
  }) async {
    final dynamic data =
        (await _apiClient.get(
          '/api/v1/delivery-slots',
          queryParameters: <String, dynamic>{
            'method': method,
            if (date != null) 'date': _date(date),
          },
        )).data;
    final List<DeliverySlotModel> values = _maps(
      data,
    ).map(DeliverySlotModel.fromMap).toList(growable: true)..sort(
      (DeliverySlotModel a, DeliverySlotModel b) =>
          a.startTime.compareTo(b.startTime),
    );
    return List<DeliverySlotModel>.unmodifiable(values);
  }

  Future<void> reserveSlot(String slotId) async {
    final String id = slotId.trim();
    if (id.isEmpty) return;
    await _apiClient.post('/api/v1/delivery-slots/$id/reserve');
  }
}

String _date(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-'
    '${value.month.toString().padLeft(2, '0')}-'
    '${value.day.toString().padLeft(2, '0')}';

List<Map<String, dynamic>> _maps(dynamic data) =>
    data is Iterable
        ? data
            .whereType<Map>()
            .map((Map value) => Map<String, dynamic>.from(value))
            .toList()
        : <Map<String, dynamic>>[];
