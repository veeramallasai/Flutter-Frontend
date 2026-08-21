import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  SecureStorageService({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  Future<String?> read(String key) async {
    final String safeKey = _validateKey(key);
    return _storage.read(key: safeKey);
  }

  Future<void> write(String key, String value) async {
    final String safeKey = _validateKey(key);
    await _storage.write(key: safeKey, value: value);
  }

  Future<void> delete(String key) async {
    final String safeKey = _validateKey(key);
    await _storage.delete(key: safeKey);
  }

  Future<void> clear() => _storage.deleteAll();

  Future<bool> containsKey(String key) async => await read(key) != null;

  String _validateKey(String value) {
    final String key = value.trim();
    if (key.isEmpty) {
      throw ArgumentError.value(value, 'key', 'Key cannot be empty.');
    }
    return key;
  }
}
