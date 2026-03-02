// Tests for trends API extensions.
import 'package:flutter_test/flutter_test.dart';
import 'package:glacial/features/mastodon/extensions.dart';
import 'package:glacial/features/models.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  group('TrendsExtensions', () {
    test('fetchFollowedHashtags throws when not signed in', () {
      final status = MockAccessStatus.anonymous();
      expect(() => status.fetchFollowedHashtags(), throwsException);
    });

    test('fetchFollowedHashtags throws on network error when signed in', () {
      // isSignedIn check passes, getAPIEx is called, network fails.
      const status = AccessStatusSchema(
        domain: 'nonexistent-server-12345.invalid',
        accessToken: 'test-token',
      );
      expect(() => status.fetchFollowedHashtags(), throwsA(anything));
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
