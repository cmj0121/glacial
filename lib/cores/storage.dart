// The shared library to access the data in local storage, which may be the shared preferences
// or security storage.
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:glacial/features/models.dart';

// The provider to declare the system preference settings or global variables.
final reloadProvider = StateProvider<bool>((ref) => false);
final preferenceProvider = StateProvider<SystemPreferenceSchema?>((ref) => null);
final accessStatusProvider = StateProvider<AccessStatusSchema?>((ref) => null);

class Storage {
  static SharedPreferences? _prefs;
  static final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  // Singleton instance of Storage and private constructor, pass pruge=true to
  // clear the storage before initializing.
  static Future<void> init({bool purge = false}) async {
    _prefs = await SharedPreferences.getInstance();
    if (purge) {
      await _prefs?.clear();
      await _secureStorage.deleteAll();
    }
  }

  // Erase all data in the storage, both secure and non-secure.
  Future<void> purge() async {
    await _prefs?.clear();
    await _secureStorage.deleteAll();
  }

  // Get the raw string value from the storage.
  Future<String?> getString(String key, {bool secure = false}) async {
    return secure ? await _secureStorage.read(key: key) : _prefs?.getString(key);
  }

  // Save the raw string value to the storage.
  Future<void> setString(String key, String value, {bool secure = false}) async {
    return secure ? await _secureStorage.write(key: key, value: value) : await _prefs?.setString(key, value);
  }

  // Remove the raw string value from the storage.
  Future<void> remove(String key, {bool secure = false}) async {
    return secure ? await _secureStorage.delete(key: key) : await _prefs?.remove(key);
  }
}

// vim: set ts=2 sw=2 sts=2 et:
