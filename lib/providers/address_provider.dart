import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/models/address_model.dart';
import '../data/repositories/address_repository.dart';

class AddressProvider extends ChangeNotifier {
  AddressProvider({AddressRepository? repository})
      : _repository = repository ?? AddressRepository();

  final AddressRepository _repository;
  List<AddressModel> _addresses = <AddressModel>[];
  String _selectedAddressId = '';
  bool _isLoading = false;
  bool _isUpdating = false;
  String? _errorMessage;
  bool _disposed = false;
  int _loadGeneration = 0;

  List<AddressModel> get addresses => List<AddressModel>.unmodifiable(_addresses);
  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
  String? get errorMessage => _errorMessage;
  String get selectedAddressId => _selectedAddressId;

  AddressModel? get selectedAddress {
    for (final AddressModel address in _addresses) {
      if (address.id == _selectedAddressId) return address;
    }
    return null;
  }

  void listenToAddresses() {
    unawaited(refreshAddresses());
  }

  Future<void> refreshAddresses({String preferredId = ''}) async {
    final int generation = ++_loadGeneration;
    _isLoading = true;
    _errorMessage = null;
    _notify();
    try {
      final List<AddressModel> values = await _repository.getAddresses();
      if (_disposed || generation != _loadGeneration) return;
      _addresses = List<AddressModel>.from(values);
      _selectAvailableAddress(preferredId: preferredId);
    } catch (error) {
      if (_disposed || generation != _loadGeneration) return;
      _errorMessage = _friendlyError(error);
    } finally {
      if (!_disposed && generation == _loadGeneration) {
        _isLoading = false;
        _notify();
      }
    }
  }

  void selectAddress(String addressId) {
    final String id = addressId.trim();
    if (_addresses.any((AddressModel address) => address.id == id)) {
      _selectedAddressId = id;
      _notify();
    }
  }

  Future<bool> deleteAddress(String addressId) => _run(
        () => _repository.deleteAddress(addressId),
      );

  Future<bool> setDefault(String addressId) => _run(
        () async {
          await _repository.setDefault(addressId);
        },
        preferredId: addressId,
      );

  Future<bool> _run(
    Future<void> Function() action, {
    String preferredId = '',
  }) async {
    if (_isUpdating) return false;
    _isUpdating = true;
    _errorMessage = null;
    _notify();
    try {
      await action();
      final List<AddressModel> values = await _repository.getAddresses();
      if (_disposed) return false;
      _addresses = List<AddressModel>.from(values);
      _selectAvailableAddress(preferredId: preferredId);
      return true;
    } catch (error) {
      _errorMessage = _friendlyError(error);
      return false;
    } finally {
      _isUpdating = false;
      _notify();
    }
  }

  void _selectAvailableAddress({String preferredId = ''}) {
    final String preferred = preferredId.trim();
    if (preferred.isNotEmpty &&
        _addresses.any((AddressModel address) => address.id == preferred)) {
      _selectedAddressId = preferred;
      return;
    }
    if (_addresses.any(
      (AddressModel address) => address.id == _selectedAddressId,
    )) {
      return;
    }
    if (_addresses.isEmpty) {
      _selectedAddressId = '';
      return;
    }
    _selectedAddressId = _addresses
        .firstWhere(
          (AddressModel address) => address.isDefault,
          orElse: () => _addresses.first,
        )
        .id;
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  String _friendlyError(Object error) {
    String message = error.toString().trim();
    if (message.startsWith('Bad state: ')) message = message.substring(11);
    return message.isEmpty ? 'Unable to update address.' : message;
  }

  @override
  void dispose() {
    _disposed = true;
    _loadGeneration += 1;
    super.dispose();
  }
}
