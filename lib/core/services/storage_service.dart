import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  StorageService({FirebaseStorage? storage})
    : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  bool get isConfigured => true;

  Future<String> upload({
    required String path,
    required Uint8List bytes,
    String contentType = 'application/octet-stream',
  }) async {
    if (bytes.isEmpty) {
      throw ArgumentError.value(bytes, 'bytes', 'File cannot be empty.');
    }
    final Reference reference = _storage.ref(_validatePath(path));
    await reference.putData(
      bytes,
      SettableMetadata(contentType: contentType.trim()),
    );
    return reference.getDownloadURL();
  }

  Future<void> delete(String path) {
    return _storage.ref(_validatePath(path)).delete();
  }

  Future<String> getDownloadUrl(String path) {
    return _storage.ref(_validatePath(path)).getDownloadURL();
  }

  String userAvatarPath(String userId) =>
      'users/${_segment(userId)}/avatar.jpg';

  String productImagePath(String productId, String fileName) =>
      'products/${_segment(productId)}/${_segment(fileName)}';

  String _validatePath(String value) {
    final String path = value.trim().replaceAll('\\', '/');
    if (path.isEmpty || path.startsWith('/') || path.contains('../')) {
      throw ArgumentError.value(value, 'path', 'Invalid storage path.');
    }
    return path;
  }

  String _segment(String value) {
    final String segment = value.trim().replaceAll(
      RegExp(r'[^a-zA-Z0-9._-]+'),
      '-',
    );
    if (segment.isEmpty) {
      throw ArgumentError.value(value, 'value', 'Value cannot be empty.');
    }
    return segment;
  }
}
