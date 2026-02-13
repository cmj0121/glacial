import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:glacial/cores/storage.dart';
import 'package:glacial/cores/timeline_cache.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TimelineCacheExtension', () {
    late Storage storage;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await Storage.init();
      storage = Storage();
    });

    test('cacheTimeline saves and loadCachedTimeline retrieves', () async {
      const key = 'example.com@123';
      const type = 'home';
      const json = '[{"id":"1","content":"hello"}]';

      await storage.cacheTimeline(key, type, json);
      final result = await storage.loadCachedTimeline(key, type);

      expect(result, json);
    });

    test('loadCachedTimeline returns null when no cache exists', () async {
      final result = await storage.loadCachedTimeline('nokey', 'home');
      expect(result, isNull);
    });

    test('getCacheTime returns correct timestamp after caching', () async {
      const key = 'example.com@456';
      const type = 'local';

      final before = DateTime.now();
      await storage.cacheTimeline(key, type, '[]');
      final after = DateTime.now();

      final cacheTime = await storage.getCacheTime(key, type);
      expect(cacheTime, isNotNull);
      expect(cacheTime!.isAfter(before.subtract(const Duration(seconds: 1))), isTrue);
      expect(cacheTime.isBefore(after.add(const Duration(seconds: 1))), isTrue);
    });

    test('getCacheTime returns null when not cached', () async {
      final result = await storage.getCacheTime('nokey', 'home');
      expect(result, isNull);
    });

    test('clearTimelineCaches removes all cache keys', () async {
      const key = 'example.com@789';

      await storage.cacheTimeline(key, 'home', '[{"id":"1"}]');
      await storage.cacheTimeline(key, 'local', '[{"id":"2"}]');
      await storage.cacheTimeline(key, 'public', '[{"id":"3"}]');

      await storage.clearTimelineCaches(key);

      expect(await storage.loadCachedTimeline(key, 'home'), isNull);
      expect(await storage.loadCachedTimeline(key, 'local'), isNull);
      expect(await storage.loadCachedTimeline(key, 'public'), isNull);
      expect(await storage.getCacheTime(key, 'home'), isNull);
      expect(await storage.getCacheTime(key, 'local'), isNull);
    });

    test('different composite keys do not collide', () async {
      const key1 = 'server.a@user1';
      const key2 = 'server.a@user2';
      const type = 'home';

      await storage.cacheTimeline(key1, type, '["data_1"]');
      await storage.cacheTimeline(key2, type, '["data_2"]');

      expect(await storage.loadCachedTimeline(key1, type), '["data_1"]');
      expect(await storage.loadCachedTimeline(key2, type), '["data_2"]');
    });

    test('different timeline types do not collide', () async {
      const key = 'server.b@user1';

      await storage.cacheTimeline(key, 'home', '["home_data"]');
      await storage.cacheTimeline(key, 'local', '["local_data"]');

      expect(await storage.loadCachedTimeline(key, 'home'), '["home_data"]');
      expect(await storage.loadCachedTimeline(key, 'local'), '["local_data"]');
    });

    test('caching overwrites previous data', () async {
      const key = 'example.com@123';
      const type = 'home';

      await storage.cacheTimeline(key, type, '["old"]');
      await storage.cacheTimeline(key, type, '["new"]');

      expect(await storage.loadCachedTimeline(key, type), '["new"]');
    });

    test('caching empty JSON is valid', () async {
      const key = 'example.com@123';
      const type = 'home';

      await storage.cacheTimeline(key, type, '[]');
      expect(await storage.loadCachedTimeline(key, type), '[]');
    });

    test('clearTimelineCaches does not affect other accounts', () async {
      const key1 = 'server.a@user1';
      const key2 = 'server.a@user2';

      await storage.cacheTimeline(key1, 'home', '["data_1"]');
      await storage.cacheTimeline(key2, 'home', '["data_2"]');

      await storage.clearTimelineCaches(key1);

      expect(await storage.loadCachedTimeline(key1, 'home'), isNull);
      expect(await storage.loadCachedTimeline(key2, 'home'), '["data_2"]');
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
