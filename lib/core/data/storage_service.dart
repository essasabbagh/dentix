import 'dart:convert';

import 'package:get_storage/get_storage.dart';

typedef JsonMap = Map<String, dynamic>;
typedef JsonList = List<JsonMap>;

/// A service wrapper around GetStorage that provides a clean API for
/// saving and retrieving primitive types, JSON objects, and JSON lists.
///
/// Handles:
/// - Strings
/// - Bool, Int, Double
/// - JSON Map
/// - JSON List
/// - Removing and clearing storage
/// - Checking existence
class StorageService {
  StorageService(this._box);

  final GetStorage _box;

  // ---------------------------------------------------------------------------
  // Basic Operations
  // ---------------------------------------------------------------------------

  /// Saves any primitive value (String, int, double, bool).
  Future<void> write<T>(String key, T value) => _box.write(key, value);

  /// Reads a primitive value with optional fallback.
  T read<T>(String key, {T? defaultValue}) {
    return _box.read<T>(key) ?? defaultValue as T;
  }

  /// Returns true if the key exists in storage.
  bool has(String key) => _box.hasData(key);

  /// Deletes a single key.
  Future<void> remove(String key) => _box.remove(key);

  /// Clears the entire storage.
  Future<void> clear() => _box.erase();

  // ---------------------------------------------------------------------------
  // String Helpers
  // ---------------------------------------------------------------------------

  Future<void> saveString(String key, String value) => write(key, value);

  String readString(String key, {String defaultValue = ''}) =>
      read<String>(key, defaultValue: defaultValue);

  // ---------------------------------------------------------------------------
  // Bool Helpers
  // ---------------------------------------------------------------------------

  Future<void> saveBool(String key, bool value) => write(key, value);

  bool readBool(String key, {bool defaultValue = false}) =>
      read<bool>(key, defaultValue: defaultValue);

  // ---------------------------------------------------------------------------
  // Numeric Helpers (optional but very useful)
  // ---------------------------------------------------------------------------

  Future<void> saveInt(String key, int value) => write(key, value);

  int readInt(String key, {int defaultValue = 0}) =>
      read<int>(key, defaultValue: defaultValue);

  Future<void> saveDouble(String key, double value) => write(key, value);

  double readDouble(String key, {double defaultValue = 0.0}) =>
      read<double>(key, defaultValue: defaultValue);

  // ---------------------------------------------------------------------------
  // JSON: Map Helpers
  // ---------------------------------------------------------------------------

  /// Saves a JSON Map by encoding it to a string.
  Future<void> saveJson(String key, JsonMap json) {
    final encoded = jsonEncode(json);
    return write(key, encoded);
  }

  /// Reads a JSON Map from storage.
  JsonMap? readJson(String key) {
    final jsonString = _box.read<String>(key);
    if (jsonString == null || jsonString.isEmpty) return null;

    try {
      return jsonDecode(jsonString) as JsonMap;
    } catch (_) {
      return null; // corrupted JSON
    }
  }

  // ---------------------------------------------------------------------------
  // JSON: List Helpers
  // ---------------------------------------------------------------------------

  /// Saves a list of JSON objects to storage.
  Future<void> saveJsonList(String key, JsonList jsonList) {
    final encoded = jsonEncode(jsonList);
    return write(key, encoded);
  }

  /// Reads a list of JSON Maps.
  JsonList readJsonList(String key) {
    final jsonString = _box.read<String>(key);

    if (jsonString == null || jsonString.trim().isEmpty) return [];

    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is List) {
        return decoded.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (_) {
      return []; // corrupted JSON
    }
  }
}
