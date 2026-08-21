import '../../core/network/api_client.dart';
import '../../core/network/api_response.dart';
import '../models/address_model.dart';

class AddressRemoteSource {
  AddressRemoteSource({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<List<AddressModel>> getAddresses() async {
    final ApiResponse<dynamic> response = await _client.get('/api/v1/addresses');
    final dynamic raw = response.data;
    if (raw is! Iterable) return <AddressModel>[];
    return raw
        .whereType<Map>()
        .map((Map<dynamic, dynamic> value) => AddressModel.fromMap(_map(value)))
        .toList(growable: false);
  }

  Future<AddressModel> saveAddress(AddressModel address) async {
    final ApiResponse<dynamic> response = address.id.trim().isEmpty
        ? await _client.post('/api/v1/addresses', body: _payload(address))
        : await _client.put(
            '/api/v1/addresses/${Uri.encodeComponent(address.id.trim())}',
            body: _payload(address),
          );
    return _address(response.data);
  }

  Future<void> deleteAddress(String addressId) async {
    final String id = Uri.encodeComponent(addressId.trim());
    await _client.delete('/api/v1/addresses/$id');
  }

  Future<AddressModel> setDefault(String addressId) async {
    final String id = Uri.encodeComponent(addressId.trim());
    final ApiResponse<dynamic> response =
        await _client.patch('/api/v1/addresses/$id/default');
    return _address(response.data);
  }

  Map<String, dynamic> _payload(AddressModel address) => <String, dynamic>{
        'fullName': address.fullName.trim(),
        'phone': address.phone.trim(),
        'addressLine1': address.addressLine1.trim(),
        'addressLine2': address.addressLine2.trim(),
        'city': address.city.trim(),
        'state': address.state.trim(),
        'postalCode': address.postalCode.trim(),
        'landmark': address.landmark.trim(),
        'type': address.type.trim(),
        'isDefault': address.isDefault,
        'latitude': address.latitude,
        'longitude': address.longitude,
      };

  AddressModel _address(dynamic raw) {
    if (raw is! Map) throw StateError('Invalid address response from server.');
    return AddressModel.fromMap(_map(raw));
  }

  Map<String, dynamic> _map(Map<dynamic, dynamic> raw) => raw.map(
        (dynamic key, dynamic value) =>
            MapEntry<String, dynamic>(key.toString(), value),
      );
}
