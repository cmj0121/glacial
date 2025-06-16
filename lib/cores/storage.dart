// The shared library to access the data in local storage, which
// may be the shared preferences or security storage.
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:glacial/features/models.dart';

// The global provider to declare the selected Mastodon server and access token
final serverProvider = StateProvider<ServerSchema?>((ref) => null);
final accessTokenProvider = StateProvider<String?>((ref) => null);
final accountProvider = StateProvider<AccountSchema?>((ref) => null);

class Storage {
  static SharedPreferences? _prefs;
  static final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  static Future<void> init({bool purge = false}) async {
    _prefs = await SharedPreferences.getInstance();
    if (purge) {
      await _prefs?.clear();
      await _secureStorage.deleteAll();
    }
  }

  // Purge the storage.
  Future<void> purge() async {
    await _prefs?.clear();
    await _secureStorage.deleteAll();
  }

  // Get the raw string value from the storage.
  Future<String?> getString(String key, {bool secure = false}) async {
    return secure ? await _secureStorage.read(key: key) : _prefs?.getString(key);
  }

  // Remove the raw string value from the storage.
  Future<void> remove(String key, {bool secure = false}) async {
    switch (secure) {
      case true:
        await _secureStorage.delete(key: key);
        break;
      case false:
        await _prefs?.remove(key);
        break;
    }
  }

  // Get the list of string from the storage.
  List<String> getStringList(String key) {
    return _prefs?.getStringList(key) ?? [];
  }

  // Set the raw string value to the storage.
  Future<void> setString(String key, String value, {bool secure = false}) async {
    switch (secure) {
      case true:
        await _secureStorage.write(key: key, value: value);
        break;
      case false:
        await _prefs?.setString(key, value);
        break;
    }
  }

  // Set the list of string to the storage.
  Future<void> setStringList(String key, List<String> value) async {
    await _prefs?.setStringList(key, value);
  }
}

// vim: set ts=2 sw=2 sts=2 et:
