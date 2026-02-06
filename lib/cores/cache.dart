// A generic LRU (Least Recently Used) cache implementation with domain-based isolation.
import 'dart:collection';

/// A generic LRU cache that stores items per domain with automatic eviction.
///
/// The cache maintains a maximum number of items per domain. When the limit is
/// reached, the least recently accessed item is evicted to make room for new entries.
class LRUCache<K, V> {
  final int maxSizePerDomain;
  final Map<String?, LinkedHashMap<K, V>> _cache = {};

  LRUCache({this.maxSizePerDomain = 500});

  /// Get an item from the cache, promoting it to most recently used.
  V? get(String? domain, K key) {
    final domainCache = _cache[domain];
    if (domainCache == null) return null;

    final value = domainCache.remove(key);
    if (value != null) {
      // Re-insert to mark as most recently used
      domainCache[key] = value;
    }
    return value;
  }

  /// Put an item in the cache, evicting LRU items if necessary.
  void put(String? domain, K key, V value) {
    _cache.putIfAbsent(domain, () => LinkedHashMap<K, V>());
    final domainCache = _cache[domain]!;

    // Remove existing entry to update its position
    domainCache.remove(key);

    // Evict oldest entries if at capacity
    while (domainCache.length >= maxSizePerDomain) {
      final oldestKey = domainCache.keys.first;
      domainCache.remove(oldestKey);
    }

    domainCache[key] = value;
  }

  /// Check if the cache contains a key for the given domain.
  bool contains(String? domain, K key) {
    return _cache[domain]?.containsKey(key) ?? false;
  }

  /// Remove an item from the cache.
  V? remove(String? domain, K key) {
    return _cache[domain]?.remove(key);
  }

  /// Clear all items for a specific domain.
  void clearDomain(String? domain) {
    _cache.remove(domain);
  }

  /// Clear the entire cache.
  void clear() {
    _cache.clear();
  }

  /// Get the current size of the cache for a domain.
  int sizeOf(String? domain) {
    return _cache[domain]?.length ?? 0;
  }

  /// Get the total size across all domains.
  int get totalSize {
    return _cache.values.fold(0, (sum, map) => sum + map.length);
  }

  /// Put multiple items at once.
  void putAll(String? domain, Map<K, V> items) {
    for (final entry in items.entries) {
      put(domain, entry.key, entry.value);
    }
  }

  /// Get all keys for a domain.
  Iterable<K> keys(String? domain) {
    return _cache[domain]?.keys ?? [];
  }

  /// Get all values for a domain.
  Iterable<V> values(String? domain) {
    return _cache[domain]?.values ?? [];
  }
}

// vim: set ts=2 sw=2 sts=2 et:
