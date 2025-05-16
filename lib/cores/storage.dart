// The shared library to access the data in local storage, which
// may be the shared preferences or security storage.
import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  static SharedPreferences? _prefs;

  static Future<void> init({bool purge = false}) async {
    _prefs = await SharedPreferences.getInstance();
    if (purge) {
      await _prefs?.clear();
    }
  }

  // Get the raw string value from the storage.
  Future<String?> getString(String key, {bool secure = false}) async {
    return _prefs?.getString(key);
  }

  // Get the list of string from the storage.
  List<String> getStringList(String key) {
    return _prefs?.getStringList(key) ?? [];
  }

  // Set the raw string value to the storage.
  void setString(String key, String value, {bool secure = false}) async {
    await _prefs?.setString(key, value);
  }

  // Set the list of string to the storage.
  void setStringList(String key, List<String> value) async {
    _prefs?.setStringList(key, value);
  }
}

// vim: set ts=2 sw=2 sts=2 et:
