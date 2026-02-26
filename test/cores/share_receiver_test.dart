// Unit tests for ShareReceiver.
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
}

// vim: set ts=2 sw=2 sts=2 et:
