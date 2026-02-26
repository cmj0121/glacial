// Tests for hashtag/featured tag checkSignedIn guards.
import 'package:flutter_test/flutter_test.dart';
import 'package:glacial/features/mastodon/extensions.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  group('Featured tags checkSignedIn guards', () {
    test('fetchFeaturedTags throws when not signed in', () {
      final status = MockAccessStatus.anonymous();
      expect(() => status.fetchFeaturedTags(), throwsException);
    });

    test('featureTag throws when not signed in', () {
      final status = MockAccessStatus.anonymous();
      expect(() => status.featureTag('flutter'), throwsException);
    });

    test('unfeatureTag throws when not signed in', () {
      final status = MockAccessStatus.anonymous();
      expect(() => status.unfeatureTag('ft-1'), throwsException);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
