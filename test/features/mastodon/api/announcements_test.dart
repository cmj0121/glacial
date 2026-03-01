// Tests for announcements checkSignedIn guards.
import 'package:flutter_test/flutter_test.dart';
import 'package:glacial/features/models.dart';
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

  group('Announcements API with no domain', () {
    // Authenticated (has accessToken) but no domain — API calls return null without HTTP.
    AccessStatusSchema noDomainAuth() =>
        const AccessStatusSchema(domain: '', accessToken: 'token');

    test('dismissAnnouncement completes when no domain', () async {
      await noDomainAuth().dismissAnnouncement('ann-1');
    });

    test('addAnnouncementReaction completes when no domain', () async {
      await noDomainAuth().addAnnouncementReaction('ann-1', '👍');
    });

    test('removeAnnouncementReaction completes when no domain', () async {
      await noDomainAuth().removeAnnouncementReaction('ann-1', '👍');
    });
  });

  group('Announcements API with valid domain exercises HTTP call lines', () {
    // Authenticated with a valid domain — passes checkSignedIn and domain guard,
    // reaching the actual API call lines (29, 36, 43) before failing on network.
    const auth = AccessStatusSchema(
      domain: 'nonexistent-server-12345.invalid',
      accessToken: 'test-token',
    );

    test('dismissAnnouncement throws on network error with valid domain', () {
      expect(
        () => auth.dismissAnnouncement('ann-1'),
        throwsA(anything),
      );
    });

    test('addAnnouncementReaction throws on network error with valid domain', () {
      expect(
        () => auth.addAnnouncementReaction('ann-1', '👍'),
        throwsA(anything),
      );
    });

    test('removeAnnouncementReaction throws on network error with valid domain', () {
      expect(
        () => auth.removeAnnouncementReaction('ann-1', '👍'),
        throwsA(anything),
      );
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
