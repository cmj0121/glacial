// Timeline cache extension for offline support.
//
// Caches raw JSON response bodies from timeline API calls in SharedPreferences,
// keyed by composite account key and timeline type. This allows the app to
// display cached content immediately on launch before network data arrives.
import 'package:glacial/cores/storage.dart';

// Known timeline types that may have cached data.
const List<String> _cacheableTypes = [
  'home', 'local', 'federal', 'public', 'favourites', 'bookmarks',
];

extension TimelineCacheExtension on Storage {
  static String _cacheKey(String compositeKey, String type) =>
      'cache_${compositeKey}_$type';

  static String _cacheTimeKey(String compositeKey, String type) =>
      'cache_time_${compositeKey}_$type';

  /// Save raw JSON response body for a timeline's first page.
  Future<void> cacheTimeline(String compositeKey, String type, String jsonBody) async {
    await setString(_cacheKey(compositeKey, type), jsonBody);
    await setString(
      _cacheTimeKey(compositeKey, type),
      DateTime.now().toIso8601String(),
    );
  }

  /// Load cached JSON for a timeline. Returns null if no cache exists.
  Future<String?> loadCachedTimeline(String compositeKey, String type) async {
    return getString(_cacheKey(compositeKey, type));
  }

  /// Get cache timestamp. Returns null if not cached.
  Future<DateTime?> getCacheTime(String compositeKey, String type) async {
    final String? raw = await getString(_cacheTimeKey(compositeKey, type));
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  /// Clear all timeline caches for an account (on logout).
  Future<void> clearTimelineCaches(String compositeKey) async {
    for (final type in _cacheableTypes) {
      await remove(_cacheKey(compositeKey, type));
      await remove(_cacheTimeKey(compositeKey, type));
    }
  }
}

// vim: set ts=2 sw=2 sts=2 et:
