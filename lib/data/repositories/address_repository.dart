import 'package:firebase_auth/firebase_auth.dart';

import '../models/address_model.dart';
import '../remote/address_remote_source.dart';

class AddressRepository {
  AddressRepository({AddressRemoteSource? remoteSource, FirebaseAuth? auth})
      : _remoteSource = remoteSource ?? AddressRemoteSource(),
        _auth = auth ?? FirebaseAuth.instance;

  final AddressRemoteSource _remoteSource;
  final FirebaseAuth _auth;

  Stream<List<AddressModel>> watchAddresses() =>
      Stream<List<AddressModel>>.fromFuture(getAddresses());

  Future<List<AddressModel>> getAddresses() {
    _requireUserId();
    return _remoteSource.getAddresses();
  }

  Future<AddressModel> saveAddress(AddressModel address) {
    _requireUserId();
    return _remoteSource.saveAddress(address);
  }

  Future<void> deleteAddress(String addressId) {
    _requireUserId();
    if (addressId.trim().isEmpty) return Future<void>.value();
    return _remoteSource.deleteAddress(addressId);
  }

  Future<AddressModel> setDefault(String addressId) {
    _requireUserId();
    if (addressId.trim().isEmpty) {
      throw ArgumentError.value(addressId, 'addressId', 'Address ID is required.');
    }
    return _remoteSource.setDefault(addressId);
  }

  String _requireUserId() {
    final String userId = _auth.currentUser?.uid.trim() ?? '';
    if (userId.isEmpty) throw StateError('Please login to continue.');
    return userId;
  }
}
