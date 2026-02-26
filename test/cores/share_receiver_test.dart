// Unit tests for ShareReceiver.
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/core.dart';

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
  });
}

// vim: set ts=2 sw=2 sts=2 et:
