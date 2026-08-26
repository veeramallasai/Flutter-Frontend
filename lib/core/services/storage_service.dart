import 'dart:typed_data';

class StorageService {
  StorageService();

  bool get isConfigured => true;

  Future<String> upload({
    required String path,
    required Uint8List bytes,
    String contentType = 'application/octet-stream',
  }) async {
    if (bytes.isEmpty) {
      throw ArgumentError.value(bytes, 'bytes', 'File cannot be empty.');
    }
    final String validPath = _validatePath(path);
    return 'https://storage.local/$validPath';
  }

  Future<void> delete(String path) async {
    _validatePath(path);
  }

  Future<String> getDownloadUrl(String path) async {
    final String validPath = _validatePath(path);
    return 'https://storage.local/$validPath';
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
