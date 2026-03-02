// Tests for media API extensions.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/mastodon/extensions.dart';

import '../../../helpers/mock_http.dart';
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

  group('MediaExtensions with mock HTTP (success paths)', () {
    late HttpOverrides? originalOverrides;

    setUp(() {
      originalOverrides = HttpOverrides.current;
    });

    tearDown(() {
      HttpOverrides.global = originalOverrides;
    });

    test('fetchCustomEmojis success returns emojis', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        return (200, '[{"shortcode":"blobcat","url":"https://example.com/emoji/blobcat.png","static_url":"https://example.com/emoji/blobcat.png","visible_in_picker":true}]');
      });

      final mockAuth = const AccessStatusSchema(
        domain: 'example.com',
        accessToken: 'test-token',
      );
      final result = await mockAuth.fetchCustomEmojis();
      expect(result.length, 1);
      expect(result.first.shortcode, 'blobcat');
    });

    test('getMedia success returns attachment', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        return (200, attachmentJson(id: 'media-99'));
      });

      final mockAuth = const AccessStatusSchema(
        domain: 'example.com',
        accessToken: 'test-token',
      );
      final result = await mockAuth.getMedia(id: 'media-99');
      expect(result, isNotNull);
      expect(result!.id, 'media-99');
    });

    test('updateMedia success returns updated attachment', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        return (200, attachmentJson(id: 'media-99', description: 'Updated'));
      });

      final mockAuth = const AccessStatusSchema(
        domain: 'example.com',
        accessToken: 'test-token',
      );
      final result = await mockAuth.updateMedia(id: 'media-99', description: 'Updated', focus: '0.5,0.5');
      expect(result.id, 'media-99');
    });

    test('deleteMedia success completes without error', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        return (200, '{}');
      });

      final mockAuth = const AccessStatusSchema(
        domain: 'example.com',
        accessToken: 'test-token',
      );
      await mockAuth.deleteMedia(id: 'media-99');
    });

    test('uploadMedia success returns attachment', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        return (200, attachmentJson(id: 'uploaded-1'));
      });

      // Create a temporary file to upload
      final tempFile = File('${Directory.systemTemp.path}/test_upload.jpg');
      tempFile.writeAsBytesSync([0xFF, 0xD8, 0xFF, 0xE0]); // minimal JPEG header

      try {
        final mockAuth = const AccessStatusSchema(
          domain: 'example.com',
          accessToken: 'test-token',
        );
        final result = await mockAuth.uploadMedia(tempFile.path);
        expect(result.id, 'uploaded-1');
      } finally {
        if (tempFile.existsSync()) tempFile.deleteSync();
      }
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
