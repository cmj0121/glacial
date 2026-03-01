// Tests for media API extensions.
import 'package:flutter_test/flutter_test.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/mastodon/extensions.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  AccessStatusSchema noDomainAuth() =>
      const AccessStatusSchema(domain: '', accessToken: 'token');

  const auth = AccessStatusSchema(
    domain: 'nonexistent-server-12345.invalid',
    accessToken: 'test-token',
  );

  group('Media checkSignedIn guards', () {
    test('uploadMedia throws when not signed in', () {
      final status = MockAccessStatus.anonymous();
      expect(() => status.uploadMedia('/test.jpg'), throwsException);
    });

    test('getMedia throws when not signed in', () {
      final status = MockAccessStatus.anonymous();
      expect(() => status.getMedia(id: 'media-1'), throwsException);
    });

    test('updateMedia throws when not signed in', () {
      final status = MockAccessStatus.anonymous();
      expect(() => status.updateMedia(id: 'media-1'), throwsException);
    });

    test('deleteMedia throws when not signed in', () {
      final status = MockAccessStatus.anonymous();
      expect(() => status.deleteMedia(id: 'media-1'), throwsException);
    });
  });

  group('MediaExtensions with no domain', () {
    test('fetchCustomEmojis completes when no domain', () async {
      final result = await noDomainAuth().fetchCustomEmojis();
      expect(result, isEmpty);
    });

    test('getMedia returns null when no domain (after checkSignedIn passes)', () async {
      final result = await noDomainAuth().getMedia(id: 'media-1');
      expect(result, isNull);
    });

    test('deleteMedia completes when no domain', () async {
      await noDomainAuth().deleteMedia(id: 'media-1');
    });
  });

  group('MediaExtensions with valid domain exercises HTTP call lines', () {
    // fetchCustomEmojis uses getAPI which catches errors
    test('fetchCustomEmojis completes with empty list on network error', () async {
      final result = await auth.fetchCustomEmojis();
      expect(result, isEmpty);
    });

    // getMedia uses getAPI which catches errors → returns null
    test('getMedia returns null on network error', () async {
      final result = await auth.getMedia(id: 'media-1');
      expect(result, isNull);
    });

    // updateMedia uses putAPI which throws
    test('updateMedia throws on network error', () {
      expect(
        () => auth.updateMedia(id: 'media-1', description: 'test'),
        throwsA(anything),
      );
    });

    // deleteMedia uses deleteAPI which throws
    test('deleteMedia throws on network error', () {
      expect(() => auth.deleteMedia(id: 'media-1'), throwsA(anything));
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
