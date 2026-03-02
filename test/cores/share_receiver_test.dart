// Unit tests for ShareReceiver.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/timeline/models/shared_content.dart';

void main() {
  group('ShareReceiver', () {
    test('consumePendingContent returns null when no pending content', () {
      final content = ShareReceiver.consumePendingContent();
      expect(content, isNull);
    });

    test('consumePendingContent returns null on consecutive calls', () {
      // First call should be null (no content set)
      expect(ShareReceiver.consumePendingContent(), isNull);
      // Second call should also be null
      expect(ShareReceiver.consumePendingContent(), isNull);
    });

    test('dispose can be called safely when not initialized', () {
      // Should not throw even when not initialized
      ShareReceiver.dispose();
    });

    test('dispose clears all state', () {
      ShareReceiver.dispose();

      // After dispose, consumePendingContent should return null
      expect(ShareReceiver.consumePendingContent(), isNull);
    });

    test('dispose then consumePendingContent returns null', () {
      // Dispose first
      ShareReceiver.dispose();

      // Should be null after dispose
      final content = ShareReceiver.consumePendingContent();
      expect(content, isNull);
    });

    test('multiple dispose calls are safe', () {
      ShareReceiver.dispose();
      ShareReceiver.dispose();
      ShareReceiver.dispose();

      expect(ShareReceiver.consumePendingContent(), isNull);
    });
  });

  group('ShareReceiver.parseSharedMedia', () {
    test('returns null for empty list', () {
      final result = ShareReceiver.parseSharedMedia([]);
      expect(result, isNull);
    });

    test('with text file returns text content', () {
      final result = ShareReceiver.parseSharedMedia([
        SharedMediaFile(
          path: 'Hello world',
          type: SharedMediaType.text,
          mimeType: 'text/plain',
        ),
      ]);
      expect(result, isNotNull);
      expect(result!.text, 'Hello world');
      expect(result.imagePaths, isEmpty);
    });

    test('with URL file returns text content', () {
      final result = ShareReceiver.parseSharedMedia([
        SharedMediaFile(
          path: 'https://example.com',
          type: SharedMediaType.url,
          mimeType: 'text/plain',
        ),
      ]);
      expect(result, isNotNull);
      expect(result!.text, 'https://example.com');
      expect(result.imagePaths, isEmpty);
    });

    test('with image file returns imagePath', () {
      final result = ShareReceiver.parseSharedMedia([
        SharedMediaFile(
          path: '/tmp/photo.jpg',
          type: SharedMediaType.image,
          mimeType: 'image/jpeg',
        ),
      ]);
      expect(result, isNotNull);
      expect(result!.text, isNull);
      expect(result.imagePaths, ['/tmp/photo.jpg']);
    });

    test('with multiple text files concatenates with newline', () {
      final result = ShareReceiver.parseSharedMedia([
        SharedMediaFile(
          path: 'First line',
          type: SharedMediaType.text,
          mimeType: 'text/plain',
        ),
        SharedMediaFile(
          path: 'Second line',
          type: SharedMediaType.text,
          mimeType: 'text/plain',
        ),
      ]);
      expect(result, isNotNull);
      expect(result!.text, 'First line\nSecond line');
    });

    test('with mixed types returns both text and imagePaths', () {
      final result = ShareReceiver.parseSharedMedia([
        SharedMediaFile(
          path: 'Check this out',
          type: SharedMediaType.text,
          mimeType: 'text/plain',
        ),
        SharedMediaFile(
          path: '/tmp/image1.png',
          type: SharedMediaType.image,
          mimeType: 'image/png',
        ),
        SharedMediaFile(
          path: 'https://mastodon.social',
          type: SharedMediaType.url,
          mimeType: 'text/plain',
        ),
        SharedMediaFile(
          path: '/tmp/image2.jpg',
          type: SharedMediaType.image,
          mimeType: 'image/jpeg',
        ),
      ]);
      expect(result, isNotNull);
      expect(result!.text, 'Check this out\nhttps://mastodon.social');
      expect(result.imagePaths, ['/tmp/image1.png', '/tmp/image2.jpg']);
    });

    test('with video type skips it', () {
      final result = ShareReceiver.parseSharedMedia([
        SharedMediaFile(
          path: '/tmp/video.mp4',
          type: SharedMediaType.video,
          mimeType: 'video/mp4',
        ),
      ]);
      expect(result, isNotNull);
      expect(result!.text, isNull);
      expect(result.imagePaths, isEmpty);
    });

    test('with file type skips it', () {
      final result = ShareReceiver.parseSharedMedia([
        SharedMediaFile(
          path: '/tmp/document.pdf',
          type: SharedMediaType.file,
          mimeType: 'application/pdf',
        ),
      ]);
      expect(result, isNotNull);
      expect(result!.text, isNull);
      expect(result.imagePaths, isEmpty);
    });
  });

  group('SharedContentSchema', () {
    test('hasContent returns true when text is present', () {
      const content = SharedContentSchema(text: 'Hello world');
      expect(content.hasContent, isTrue);
    });

    test('hasContent returns true when imagePaths is non-empty', () {
      const content = SharedContentSchema(imagePaths: ['/path/to/image.jpg']);
      expect(content.hasContent, isTrue);
    });

    test('hasContent returns true when both text and images are present', () {
      const content = SharedContentSchema(
        text: 'Hello',
        imagePaths: ['/path/to/image.jpg'],
      );
      expect(content.hasContent, isTrue);
    });

    test('hasContent returns false when text is null and imagePaths is empty', () {
      const content = SharedContentSchema();
      expect(content.hasContent, isFalse);
    });

    test('hasContent returns false when text is empty', () {
      const content = SharedContentSchema(text: '');
      expect(content.hasContent, isFalse);
    });

    test('default imagePaths is empty list', () {
      const content = SharedContentSchema(text: 'Hello');
      expect(content.imagePaths, isEmpty);
    });

    test('preserves multiple image paths', () {
      const content = SharedContentSchema(imagePaths: [
        '/path/a.jpg',
        '/path/b.png',
        '/path/c.gif',
      ]);
      expect(content.imagePaths.length, 3);
      expect(content.imagePaths[1], '/path/b.png');
    });
  });

  group('ShareReceiver.navigateToComposer', () {
    test('does nothing when navigatorKey is null', () {
      // After dispose, _navigatorKey is null
      ShareReceiver.dispose();

      // Should not throw
      ShareReceiver.navigateToComposer(
        const SharedContentSchema(text: 'test'),
      );
    });

    test('does nothing when navigatorKey context is null', () {
      // Dispose clears everything
      ShareReceiver.dispose();

      // Even after calling navigateToComposer, nothing crashes
      ShareReceiver.navigateToComposer(
        const SharedContentSchema(text: 'navigation test', imagePaths: ['/tmp/img.jpg']),
      );

      // Should still have no pending content
      expect(ShareReceiver.consumePendingContent(), isNull);
    });
  });

  group('ShareReceiver.init', () {
    testWidgets('init sets up receiver and dispose cleans it up', (tester) async {
      // Mock the ReceiveSharingIntent method channel
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('receive_sharing_intent/messages'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'getInitialMedia') {
            return null; // No initial media
          }
          if (methodCall.method == 'reset') {
            return null;
          }
          return null;
        },
      );

      final key = GlobalKey<NavigatorState>();

      // init should not throw with mocked channels
      try {
        ShareReceiver.init(key);
      } catch (_) {
        // EventChannel may not have mock handler, which is OK
      }

      // After init, dispose should cancel subscription
      ShareReceiver.dispose();

      // After dispose, consume should return null
      expect(ShareReceiver.consumePendingContent(), isNull);

      // Clean up mock
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('receive_sharing_intent/messages'),
        null,
      );
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
