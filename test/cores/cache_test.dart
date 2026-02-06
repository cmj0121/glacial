import 'package:flutter_test/flutter_test.dart';
import 'package:glacial/cores/cache.dart';

void main() {
  group('LRUCache', () {
    late LRUCache<String, String> cache;

    setUp(() {
      cache = LRUCache<String, String>(maxSizePerDomain: 3);
    });

    test('put and get items', () {
      cache.put('domain1', 'key1', 'value1');
      cache.put('domain1', 'key2', 'value2');

      expect(cache.get('domain1', 'key1'), 'value1');
      expect(cache.get('domain1', 'key2'), 'value2');
    });

    test('returns null for missing items', () {
      expect(cache.get('domain1', 'nonexistent'), isNull);
      expect(cache.get('nonexistent', 'key1'), isNull);
    });

    test('isolates items by domain', () {
      cache.put('domain1', 'key1', 'value1');
      cache.put('domain2', 'key1', 'value2');

      expect(cache.get('domain1', 'key1'), 'value1');
      expect(cache.get('domain2', 'key1'), 'value2');
    });

    test('evicts oldest items when at capacity', () {
      cache.put('domain1', 'key1', 'value1');
      cache.put('domain1', 'key2', 'value2');
      cache.put('domain1', 'key3', 'value3');
      cache.put('domain1', 'key4', 'value4');

      // key1 should be evicted (oldest)
      expect(cache.get('domain1', 'key1'), isNull);
      expect(cache.get('domain1', 'key2'), 'value2');
      expect(cache.get('domain1', 'key3'), 'value3');
      expect(cache.get('domain1', 'key4'), 'value4');
    });

    test('accessing item promotes it to most recently used', () {
      cache.put('domain1', 'key1', 'value1');
      cache.put('domain1', 'key2', 'value2');
      cache.put('domain1', 'key3', 'value3');

      // Access key1 to promote it
      cache.get('domain1', 'key1');

      // Add new item, should evict key2 (now oldest)
      cache.put('domain1', 'key4', 'value4');

      expect(cache.get('domain1', 'key1'), 'value1'); // promoted, should exist
      expect(cache.get('domain1', 'key2'), isNull); // evicted
      expect(cache.get('domain1', 'key3'), 'value3');
      expect(cache.get('domain1', 'key4'), 'value4');
    });

    test('updating existing key promotes it', () {
      cache.put('domain1', 'key1', 'value1');
      cache.put('domain1', 'key2', 'value2');
      cache.put('domain1', 'key3', 'value3');

      // Update key1
      cache.put('domain1', 'key1', 'updated');

      // Add new item, should evict key2 (now oldest)
      cache.put('domain1', 'key4', 'value4');

      expect(cache.get('domain1', 'key1'), 'updated');
      expect(cache.get('domain1', 'key2'), isNull);
    });

    test('contains checks for key existence', () {
      cache.put('domain1', 'key1', 'value1');

      expect(cache.contains('domain1', 'key1'), isTrue);
      expect(cache.contains('domain1', 'key2'), isFalse);
      expect(cache.contains('domain2', 'key1'), isFalse);
    });

    test('remove deletes item', () {
      cache.put('domain1', 'key1', 'value1');
      cache.put('domain1', 'key2', 'value2');

      final removed = cache.remove('domain1', 'key1');

      expect(removed, 'value1');
      expect(cache.get('domain1', 'key1'), isNull);
      expect(cache.get('domain1', 'key2'), 'value2');
    });

    test('clearDomain removes all items for domain', () {
      cache.put('domain1', 'key1', 'value1');
      cache.put('domain1', 'key2', 'value2');
      cache.put('domain2', 'key1', 'value3');

      cache.clearDomain('domain1');

      expect(cache.get('domain1', 'key1'), isNull);
      expect(cache.get('domain1', 'key2'), isNull);
      expect(cache.get('domain2', 'key1'), 'value3');
    });

    test('clear removes all items', () {
      cache.put('domain1', 'key1', 'value1');
      cache.put('domain2', 'key1', 'value2');

      cache.clear();

      expect(cache.get('domain1', 'key1'), isNull);
      expect(cache.get('domain2', 'key1'), isNull);
      expect(cache.totalSize, 0);
    });

    test('sizeOf returns correct count per domain', () {
      cache.put('domain1', 'key1', 'value1');
      cache.put('domain1', 'key2', 'value2');
      cache.put('domain2', 'key1', 'value3');

      expect(cache.sizeOf('domain1'), 2);
      expect(cache.sizeOf('domain2'), 1);
      expect(cache.sizeOf('domain3'), 0);
    });

    test('totalSize returns count across all domains', () {
      cache.put('domain1', 'key1', 'value1');
      cache.put('domain1', 'key2', 'value2');
      cache.put('domain2', 'key1', 'value3');

      expect(cache.totalSize, 3);
    });

    test('putAll adds multiple items', () {
      cache.putAll('domain1', {'key1': 'value1', 'key2': 'value2'});

      expect(cache.get('domain1', 'key1'), 'value1');
      expect(cache.get('domain1', 'key2'), 'value2');
    });

    test('keys returns all keys for domain', () {
      cache.put('domain1', 'key1', 'value1');
      cache.put('domain1', 'key2', 'value2');

      expect(cache.keys('domain1').toList(), containsAll(['key1', 'key2']));
      expect(cache.keys('domain2').toList(), isEmpty);
    });

    test('values returns all values for domain', () {
      cache.put('domain1', 'key1', 'value1');
      cache.put('domain1', 'key2', 'value2');

      expect(cache.values('domain1').toList(), containsAll(['value1', 'value2']));
      expect(cache.values('domain2').toList(), isEmpty);
    });

    test('handles null domain', () {
      cache.put(null, 'key1', 'value1');

      expect(cache.get(null, 'key1'), 'value1');
      expect(cache.sizeOf(null), 1);
    });
  });
}
