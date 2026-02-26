// Tests for announcements checkSignedIn guards.
import 'package:flutter_test/flutter_test.dart';
import 'package:glacial/features/mastodon/extensions.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  group('Announcements checkSignedIn guards', () {
    test('dismissAnnouncement throws when not signed in', () {
      final status = MockAccessStatus.anonymous();
      expect(() => status.dismissAnnouncement('ann-1'), throwsException);
    });

    test('addAnnouncementReaction throws when not signed in', () {
      final status = MockAccessStatus.anonymous();
      expect(() => status.addAnnouncementReaction('ann-1', '👍'), throwsException);
    });

    test('removeAnnouncementReaction throws when not signed in', () {
      final status = MockAccessStatus.anonymous();
      expect(() => status.removeAnnouncementReaction('ann-1', '👍'), throwsException);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
