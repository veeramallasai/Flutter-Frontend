import '../models/delivery_slot_model.dart';
import '../remote/delivery_remote_source.dart';

class DeliveryRepository {
  DeliveryRepository({DeliveryRemoteSource? remoteSource})
      : _remoteSource = remoteSource ?? DeliveryRemoteSource();

  final DeliveryRemoteSource _remoteSource;

  Stream<List<DeliverySlotModel>> watchSlots({
    required String method,
    DateTime? date,
  }) {
    return _remoteSource.watchSlots(method: method, date: date);
  }

  Future<List<DeliverySlotModel>> getSlots({
    required String method,
    DateTime? date,
  }) {
    return _remoteSource.getSlots(method: method, date: date);
  }

  Future<void> reserveSlot(String slotId) {
    return _remoteSource.reserveSlot(slotId);
  }
}
