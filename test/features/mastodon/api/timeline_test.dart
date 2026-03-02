// Tests for timeline API extensions.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/mastodon/extensions.dart';

import '../../../helpers/mock_http.dart';

void main() {
  const auth = AccessStatusSchema(
    domain: 'nonexistent-server-12345.invalid',
    accessToken: 'test-token',
  );

  group('TimelineExtensions fetchTimeline with no domain', () {
    // getAPIEx throws when no domain
    AccessStatusSchema noDomainAuth() =>
        const AccessStatusSchema(domain: '', accessToken: 'token');

    test('fetchTimeline home throws when no domain', () {
      expect(
        () => noDomainAuth().fetchTimeline(TimelineType.home),
        throwsException,
      );
    });

    test('fetchTimeline local throws when no domain', () {
      expect(
        () => noDomainAuth().fetchTimeline(TimelineType.local),
        throwsException,
      );
    });

    test('fetchTimeline federal throws when no domain', () {
      expect(
        () => noDomainAuth().fetchTimeline(TimelineType.federal),
        throwsException,
      );
    });

    test('fetchTimeline public throws when no domain', () {
      expect(
        () => noDomainAuth().fetchTimeline(TimelineType.public),
        throwsException,
      );
    });

    test('fetchTimeline bookmarks throws when no domain', () {
      expect(
        () => noDomainAuth().fetchTimeline(TimelineType.bookmarks),
        throwsException,
      );
    });

    test('fetchTimeline favourites throws when no domain', () {
      expect(
        () => noDomainAuth().fetchTimeline(TimelineType.favourites),
        throwsException,
      );
    });

    test('fetchTimeline hashtag throws when tag is missing', () {
      expect(
        () => auth.fetchTimeline(TimelineType.hashtag),
        throwsException,
      );
    });

    test('fetchTimeline schedule throws when account is missing', () {
      expect(
        () => auth.fetchTimeline(TimelineType.schedule),
        throwsException,
      );
    });

    test('fetchLinkTimeline throws when no domain', () {
      expect(
        () => noDomainAuth().fetchLinkTimeline(url: 'https://example.com'),
        throwsException,
      );
    });
  });

  group('TimelineExtensions with valid domain exercises HTTP call lines', () {
    // All fetchTimeline variants use getAPIEx which throws on network error
    test('fetchTimeline home throws on network error', () {
      expect(
        () => auth.fetchTimeline(TimelineType.home),
        throwsA(anything),
      );
    });

    test('fetchTimeline local throws on network error', () {
      expect(
        () => auth.fetchTimeline(TimelineType.local),
        throwsA(anything),
      );
    });

    test('fetchTimeline hashtag throws on network error', () {
      expect(
        () => auth.fetchTimeline(TimelineType.hashtag, tag: 'flutter'),
        throwsA(anything),
      );
    });

    test('fetchTimeline list throws on network error', () {
      expect(
        () => auth.fetchTimeline(TimelineType.list, listId: 'list-1'),
        throwsA(anything),
      );
    });

    test('fetchLinkTimeline throws on network error', () {
      expect(
        () => auth.fetchLinkTimeline(url: 'https://example.com/article'),
        throwsA(anything),
      );
    });
  });

  group('TimelineExtensions with mock HTTP (success paths)', () {
    late HttpOverrides? originalOverrides;

    setUp(() {
      originalOverrides = HttpOverrides.current;
    });

    tearDown(() {
      HttpOverrides.global = originalOverrides;
    });

    test('fetchTimeline home success returns parsed statuses', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        return (200, statusListJson(count: 2));
      });

      final mockAuth = const AccessStatusSchema(
        domain: 'example.com',
        accessToken: 'test-token',
      );
      final (statuses, _) = await mockAuth.fetchTimeline(TimelineType.home);
      expect(statuses.length, 2);
      expect(statuses.first.id, 'status-1');
    });

    test('fetchTimeline local success returns parsed statuses', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        return (200, '[]');
      });

      final mockAuth = const AccessStatusSchema(
        domain: 'example.com',
        accessToken: 'test-token',
      );
      final (statuses, _) = await mockAuth.fetchTimeline(TimelineType.local);
      expect(statuses, isEmpty);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
