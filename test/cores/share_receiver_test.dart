// Unit tests for ShareReceiver.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:receive_sharing_intent/receive_sharing_intent.dart';

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

    testWidgets('init stores pending content from cold launch initial media', (tester) async {
      // Use setMockValues so getInitialMedia returns shared text content.
      final streamController = StreamController<List<SharedMediaFile>>.broadcast();
      ReceiveSharingIntent.setMockValues(
        initialMedia: [
          SharedMediaFile(
            path: 'Cold launch text',
            type: SharedMediaType.text,
            mimeType: 'text/plain',
          ),
        ],
        mediaStream: streamController.stream,
      );

      final key = GlobalKey<NavigatorState>();
      ShareReceiver.init(key);

      // Allow the Future from getInitialMedia to complete.
      await tester.pump();

      // The cold launch content should now be pending (line 37-38).
      final pending = ShareReceiver.consumePendingContent();
      expect(pending, isNotNull);
      expect(pending!.text, 'Cold launch text');
      expect(pending.hasContent, isTrue);

      // Second consume should return null (already consumed).
      expect(ShareReceiver.consumePendingContent(), isNull);

      ShareReceiver.dispose();
      await streamController.close();
    });

    testWidgets('warm launch stream listener invokes navigateToComposer', (tester) async {
      // Use setMockValues with a controllable stream for warm-launch events.
      final streamController = StreamController<List<SharedMediaFile>>.broadcast();
      ReceiveSharingIntent.setMockValues(
        initialMedia: [],
        mediaStream: streamController.stream,
      );

      final navigatorKey = GlobalKey<NavigatorState>();

      // Build a GoRouter widget tree so navigatorKey has a valid context.
      bool routePushed = false;
      final router = GoRouter(
        navigatorKey: navigatorKey,
        initialLocation: '/',
        routes: [
          GoRoute(path: '/', builder: (_, __) => const Scaffold(body: Text('Home'))),
          GoRoute(
            path: RoutePath.postShared.path,
            builder: (_, GoRouterState state) {
              routePushed = true;
              return const Scaffold(body: Text('Compose'));
            },
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      // Init with the navigator key that now has context (lines 18-32).
      ShareReceiver.init(navigatorKey);
      await tester.pump();

      // Emit a warm-launch share event via the stream (lines 23-26).
      streamController.add([
        SharedMediaFile(
          path: 'Warm launch text',
          type: SharedMediaType.text,
          mimeType: 'text/plain',
        ),
      ]);
      await tester.pumpAndSettle();

      // The stream listener should have called navigateToComposer,
      // which pushes the postShared route (lines 87, 90).
      expect(routePushed, isTrue);

      ShareReceiver.dispose();
      await streamController.close();
    });

    testWidgets('stream error is handled gracefully', (tester) async {
      // Use setMockValues with a controllable stream to emit an error.
      final streamController = StreamController<List<SharedMediaFile>>.broadcast();
      ReceiveSharingIntent.setMockValues(
        initialMedia: [],
        mediaStream: streamController.stream,
      );

      final key = GlobalKey<NavigatorState>();
      ShareReceiver.init(key);
      await tester.pump();

      // Emit an error on the stream (lines 29-30).
      streamController.addError('Test stream error');
      await tester.pump();

      // The error should be logged but not crash the app.
      // Verify the receiver is still functional.
      expect(ShareReceiver.consumePendingContent(), isNull);

      ShareReceiver.dispose();
      await streamController.close();
    });
  });

  group('ShareReceiver.navigateToComposer with GoRouter', () {
    testWidgets('pushes postShared route when context is available', (tester) async {
      final streamController = StreamController<List<SharedMediaFile>>.broadcast();
      ReceiveSharingIntent.setMockValues(
        initialMedia: [],
        mediaStream: streamController.stream,
      );

      final navigatorKey = GlobalKey<NavigatorState>();
      SharedContentSchema? receivedContent;

      final router = GoRouter(
        navigatorKey: navigatorKey,
        initialLocation: '/',
        routes: [
          GoRoute(path: '/', builder: (_, __) => const Scaffold(body: Text('Home'))),
          GoRoute(
            path: RoutePath.postShared.path,
            builder: (_, GoRouterState state) {
              receivedContent = state.extra as SharedContentSchema?;
              return const Scaffold(body: Text('Compose'));
            },
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      // Init sets _navigatorKey so navigateToComposer can find context.
      ShareReceiver.init(navigatorKey);
      await tester.pump();

      // Directly call navigateToComposer with content (lines 87, 90).
      const content = SharedContentSchema(
        text: 'Shared via test',
        imagePaths: ['/tmp/test.jpg'],
      );
      ShareReceiver.navigateToComposer(content);
      await tester.pumpAndSettle();

      // Verify the route was pushed with the correct extra data.
      expect(receivedContent, isNotNull);
      expect(receivedContent!.text, 'Shared via test');
      expect(receivedContent!.imagePaths, ['/tmp/test.jpg']);

      ShareReceiver.dispose();
      await streamController.close();
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
