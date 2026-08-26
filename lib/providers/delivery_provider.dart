import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/models/delivery_selection_model.dart';
import '../data/models/delivery_slot_model.dart';
import '../data/repositories/delivery_repository.dart';

class DeliveryProvider extends ChangeNotifier {
  DeliveryProvider({DeliveryRepository? repository})
    : _repository = repository ?? DeliveryRepository();

  final DeliveryRepository _repository;
  StreamSubscription<List<DeliverySlotModel>>? _subscription;
  List<DeliverySlotModel> _slots = <DeliverySlotModel>[];
  String _shoppingMode = 'home';
  String _method = 'quick';
  DateTime? _selectedDate;
  DeliverySlotModel? _selectedSlot;
  bool _isLoading = false;
  bool _isReserving = false;
  String? _errorMessage;
  bool _disposed = false;

  List<DeliverySlotModel> get slots =>
      List<DeliverySlotModel>.unmodifiable(_slots);
  String get shoppingMode => _shoppingMode;
  String get method => _method;
  DateTime? get selectedDate => _selectedDate;
  DeliverySlotModel? get selectedSlot => _selectedSlot;
  bool get isLoading => _isLoading;
  bool get isReserving => _isReserving;
  String? get errorMessage => _errorMessage;

  void initialize({required String shoppingMode, String method = 'quick'}) {
    _shoppingMode = shoppingMode.toLowerCase() == 'shop' ? 'shop' : 'home';
    _method = method.trim().toLowerCase();
    _selectedDate ??= DateTime.now();
    listenToSlots();
  }

  void setMethod(String method) {
    final String value = method.trim().toLowerCase();
    if (_method == value) return;
    _method = value;
    _selectedSlot = null;
    listenToSlots();
  }

  void setDate(DateTime date) {
    _selectedDate = DateTime(date.year, date.month, date.day);
    _selectedSlot = null;
    listenToSlots();
  }

  void selectSlot(DeliverySlotModel slot) {
    if (!slot.canBook) return;
    _selectedSlot = slot;
    _notify();
  }

  void listenToSlots() {
    _subscription?.cancel();
    _isLoading = true;
    _errorMessage = null;
    _notify();
    try {
      _subscription = _repository
          .watchSlots(method: _method, date: _selectedDate)
          .listen(
            (List<DeliverySlotModel> values) {
              if (_disposed) return;
              _slots = List<DeliverySlotModel>.from(values);
              _isLoading = false;
              _errorMessage = null;
              _notify();
            },
            onError: (Object error, StackTrace stackTrace) {
              if (_disposed) return;
              _isLoading = false;
              _errorMessage = _friendlyError(error);
              _notify();
            },
          );
    } catch (error) {
      _isLoading = false;
      _errorMessage = _friendlyError(error);
      _notify();
    }
  }

  Future<bool> reserveSelectedSlot() async {
    final DeliverySlotModel? slot = _selectedSlot;
    if (slot == null || _isReserving) return false;
    _isReserving = true;
    _errorMessage = null;
    _notify();
    try {
      await _repository.reserveSlot(slot.id);
      return true;
    } catch (error) {
      _errorMessage = _friendlyError(error);
      return false;
    } finally {
      _isReserving = false;
      _notify();
    }
  }

  DeliverySelectionModel buildSelection({String instructions = ''}) {
    final DeliverySlotModel? slot = _selectedSlot;
    return DeliverySelectionModel(
      shoppingMode: _shoppingMode,
      method: _method,
      deliveryDate: _selectedDate,
      slotId: slot?.id ?? '',
      slotLabel: slot?.label ?? 'Earliest available',
      deliveryFee: slot?.fee ?? (_method == 'quick' ? 49 : 0),
      instructions: instructions.trim(),
      createdAt: DateTime.now(),
    );
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  String _friendlyError(Object error) {
    String message = error.toString().trim();
    if (message.startsWith('Bad state: ')) {
      message = message.substring('Bad state: '.length);
    }
    return message.isEmpty ? 'Unable to load delivery slots.' : message;
  }

  @override
  void dispose() {
    _disposed = true;
    _subscription?.cancel();
    super.dispose();
  }
}
