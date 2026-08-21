import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/models/farmer_model.dart';
import '../data/repositories/farmer_repository.dart';

class FarmerProvider extends ChangeNotifier {
  FarmerProvider({FarmerRepository? repository})
      : _repository = repository ?? FarmerRepository();

  final FarmerRepository _repository;

  StreamSubscription<List<FarmerModel>>? _farmersSubscription;
  StreamSubscription<FarmerModel?>? _selectedFarmerSubscription;
  List<FarmerModel> _farmers = <FarmerModel>[];
  FarmerModel? _selectedFarmer;
  String _selectedFarmerId = '';
  String _searchQuery = '';
  int _limit = 100;
  bool _isLoading = false;
  bool _isFarmerLoading = false;
  String? _errorMessage;
  bool _disposed = false;

  List<FarmerModel> get farmers =>
      List<FarmerModel>.unmodifiable(_farmers);
  FarmerModel? get selectedFarmer => _selectedFarmer;
  String get selectedFarmerId => _selectedFarmerId;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  bool get isFarmerLoading => _isFarmerLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage?.trim().isNotEmpty ?? false;

  List<FarmerModel> get visibleFarmers {
    final String query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return farmers;

    return _farmers.where((FarmerModel farmer) {
      return farmer.name.toLowerCase().contains(query) ||
          farmer.farmName.toLowerCase().contains(query) ||
          farmer.location.toLowerCase().contains(query) ||
          farmer.speciality.toLowerCase().contains(query);
    }).toList(growable: false);
  }

  void listenToFarmers({int limit = 100}) {
    _limit = limit;
    _farmersSubscription?.cancel();
    _isLoading = true;
    _errorMessage = null;
    _notify();

    try {
      _farmersSubscription = _repository.watchFarmers(limit: limit).listen(
            (List<FarmerModel> values) {
          if (_disposed) return;
          _farmers = List<FarmerModel>.from(values);
          _isLoading = false;
          _errorMessage = null;
          _syncSelectedFarmerFromList();
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

  Future<void> refresh() async {
    _isLoading = true;
    _errorMessage = null;
    _notify();

    try {
      _farmers = await _repository.getFarmers(limit: _limit);
      _syncSelectedFarmerFromList();
      _errorMessage = null;
    } catch (error) {
      _errorMessage = _friendlyError(error);
    } finally {
      _isLoading = false;
      _notify();
    }
  }

  void watchFarmer(String farmerId) {
    final String id = farmerId.trim();
    _selectedFarmerSubscription?.cancel();
    _selectedFarmerId = id;
    _selectedFarmer = farmerById(id);

    if (id.isEmpty) {
      _isFarmerLoading = false;
      _notify();
      return;
    }

    _isFarmerLoading = _selectedFarmer == null;
    _errorMessage = null;
    _notify();

    try {
      _selectedFarmerSubscription = _repository.watchFarmer(id).listen(
            (FarmerModel? farmer) {
          if (_disposed) return;
          _selectedFarmer = farmer;
          _isFarmerLoading = false;
          _errorMessage = null;
          _notify();
        },
        onError: (Object error, StackTrace stackTrace) {
          if (_disposed) return;
          _isFarmerLoading = false;
          _errorMessage = _friendlyError(error);
          _notify();
        },
      );
    } catch (error) {
      _isFarmerLoading = false;
      _errorMessage = _friendlyError(error);
      _notify();
    }
  }

  Future<FarmerModel?> loadFarmer(String farmerId) async {
    final String id = farmerId.trim();
    if (id.isEmpty) return null;

    _selectedFarmerId = id;
    _selectedFarmer = farmerById(id);
    if (_selectedFarmer != null) {
      _notify();
      return _selectedFarmer;
    }

    _isFarmerLoading = true;
    _errorMessage = null;
    _notify();

    try {
      _selectedFarmer = await _repository.getFarmer(id);
      return _selectedFarmer;
    } catch (error) {
      _errorMessage = _friendlyError(error);
      return null;
    } finally {
      _isFarmerLoading = false;
      _notify();
    }
  }

  FarmerModel? farmerById(String farmerId) {
    final String id = farmerId.trim();
    for (final FarmerModel farmer in _farmers) {
      if (farmer.id == id) return farmer;
    }
    return null;
  }

  void setSearchQuery(String query) {
    final String value = query.trim();
    if (_searchQuery == value) return;
    _searchQuery = value;
    _notify();
  }

  void clearSelectedFarmer() {
    _selectedFarmerSubscription?.cancel();
    _selectedFarmerSubscription = null;
    _selectedFarmer = null;
    _selectedFarmerId = '';
    _isFarmerLoading = false;
    _notify();
  }

  void clearError() {
    _errorMessage = null;
    _notify();
  }

  void _syncSelectedFarmerFromList() {
    if (_selectedFarmerId.isEmpty) return;
    _selectedFarmer = farmerById(_selectedFarmerId) ?? _selectedFarmer;
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  String _friendlyError(Object error) {
    String message = error.toString().trim();
    if (message.startsWith('Bad state: ')) {
      message = message.substring('Bad state: '.length);
    }
    return message.isEmpty ? 'Unable to load farmer details.' : message;
  }

  @override
  void dispose() {
    _disposed = true;
    _farmersSubscription?.cancel();
    _selectedFarmerSubscription?.cancel();
    super.dispose();
  }
}
