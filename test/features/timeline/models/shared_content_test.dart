// Unit tests for SharedContentSchema.
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/features/models.dart';

void main() {
  group('SharedContentSchema', () {
    test('hasContent is true when text is non-empty', () {
      const schema = SharedContentSchema(text: 'Hello');
      expect(schema.hasContent, isTrue);
    });

    test('hasContent is true when imagePaths is non-empty', () {
      const schema = SharedContentSchema(imagePaths: ['/path/to/image.jpg']);
      expect(schema.hasContent, isTrue);
    });

    test('hasContent is true when both text and imagePaths are set', () {
      const schema = SharedContentSchema(text: 'Hello', imagePaths: ['/path/to/image.jpg']);
      expect(schema.hasContent, isTrue);
    });

    test('hasContent is false when text is null and imagePaths is empty', () {
      const schema = SharedContentSchema();
      expect(schema.hasContent, isFalse);
    });

    test('hasContent is false when text is empty string', () {
      const schema = SharedContentSchema(text: '');
      expect(schema.hasContent, isFalse);
    });

    test('constructor defaults', () {
      const schema = SharedContentSchema();
      expect(schema.text, isNull);
      expect(schema.imagePaths, isEmpty);
    });

    test('imagePaths preserves order', () {
      const paths = ['/a.jpg', '/b.png', '/c.gif'];
      const schema = SharedContentSchema(imagePaths: paths);
      expect(schema.imagePaths, orderedEquals(paths));
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
