typedef PreferenceReader = Future<Object?> Function(String key);
typedef PreferenceWriter = Future<void> Function(String key, Object value);
typedef PreferenceRemover = Future<void> Function(String key);
typedef PreferencesClearer = Future<void> Function();

class LocalPreferences {
  LocalPreferences({
    PreferenceReader? reader,
    PreferenceWriter? writer,
    PreferenceRemover? remover,
    PreferencesClearer? clearer,
  })  : _reader = reader,
        _writer = writer,
        _remover = remover,
        _clearer = clearer;

  final PreferenceReader? _reader;
  final PreferenceWriter? _writer;
  final PreferenceRemover? _remover;
  final PreferencesClearer? _clearer;
  final Map<String, Object> _memory = <String, Object>{};

  Future<T?> get<T>(String key) async {
    final String safeKey = _key(key);
    final Object? value = _reader == null
        ? _memory[safeKey]
        : await _reader(safeKey);
    return value is T ? value : null;
  }

  Future<String> getString(String key, {String fallback = ''}) async =>
      await get<String>(key) ?? fallback;

  Future<bool> getBool(String key, {bool fallback = false}) async =>
      await get<bool>(key) ?? fallback;

  Future<int> getInt(String key, {int fallback = 0}) async =>
      await get<int>(key) ?? fallback;

  Future<void> set(String key, Object value) async {
    final String safeKey = _key(key);
    if (_writer != null) {
      await _writer(safeKey, value);
    } else {
      _memory[safeKey] = value;
    }
  }

  Future<void> remove(String key) async {
    final String safeKey = _key(key);
    if (_remover != null) {
      await _remover(safeKey);
    } else {
      _memory.remove(safeKey);
    }
  }

  Future<void> clear() async {
    if (_clearer != null) {
      await _clearer();
    } else {
      _memory.clear();
    }
  }

  String _key(String value) {
    final String key = value.trim();
    if (key.isEmpty) throw ArgumentError('Preference key cannot be empty.');
    return key;
  }
}
