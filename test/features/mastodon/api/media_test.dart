// Tests for media checkSignedIn guards.
import 'package:flutter_test/flutter_test.dart';
import 'package:glacial/features/mastodon/extensions.dart';

import '../../../helpers/test_helpers.dart';

void main() {
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
}

// vim: set ts=2 sw=2 sts=2 et:
