// Tests for status cache and guard behaviors in status.dart API.
import 'package:flutter_test/flutter_test.dart';
import 'package:glacial/features/mastodon/extensions.dart';
import 'package:glacial/features/models.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  group('Status cache', () {
    test('saveStatusToCache and getStatusFromCache round-trip', () {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(domain: 'statuscache.test'),
      );
      final s = MockStatus.create(id: 'st1');
      status.saveStatusToCache(s);
      expect(status.getStatusFromCache('st1')?.id, 'st1');
    });

    test('getStatusFromCache returns null for unknown id', () {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(domain: 'statuscache2.test'),
      );
      expect(status.getStatusFromCache('unknown'), isNull);
    });
  });

  group('getStatus guards', () {
    test('returns null for null statusID', () async {
      final status = MockAccessStatus.anonymous();
      final result = await status.getStatus(null);
      expect(result, isNull);
    });

    test('returns null for empty statusID', () async {
      final status = MockAccessStatus.anonymous();
      final result = await status.getStatus('');
      expect(result, isNull);
    });
  });

  group('getPoll guards', () {
    test('returns null for empty pollID', () async {
      final status = MockAccessStatus.anonymous();
      final result = await status.getPoll(pollID: '');
      expect(result, isNull);
    });
  });

  group('fetchStatuses guards', () {
    test('returns empty list for empty ids', () async {
      final status = MockAccessStatus.anonymous();
      final result = await status.fetchStatuses(ids: []);
      expect(result, isEmpty);
    });
  });

  group('interactWithStatus checkSignedIn guards', () {
    test('interactWithStatus throws when not signed in', () {
      final status = MockAccessStatus.anonymous();
      final s = MockStatus.create();
      expect(() => status.interactWithStatus(s, StatusInteraction.favourite), throwsException);
    });

    test('votePoll throws when not signed in', () {
      final status = MockAccessStatus.anonymous();
      expect(() => status.votePoll(pollID: 'p1', choices: [0]), throwsException);
    });

    test('editStatusInteractionPolicy throws when not signed in', () {
      final status = MockAccessStatus.anonymous();
      final s = MockStatus.create();
      expect(() => status.editStatusInteractionPolicy(schema: s, policy: QuotePolicyType.public), throwsException);
    });

    test('translateStatus throws when not signed in', () {
      final status = MockAccessStatus.anonymous();
      final s = MockStatus.create();
      expect(() => status.translateStatus(schema: s), throwsException);
    });

    test('getStatusSource throws when not signed in', () {
      final status = MockAccessStatus.anonymous();
      expect(() => status.getStatusSource(statusId: 'st1'), throwsException);
    });

    test('getScheduledStatus throws when not signed in', () {
      final status = MockAccessStatus.anonymous();
      expect(() => status.getScheduledStatus(id: 'st1', account: MockAccount.create()), throwsException);
    });
  });

  group('fetchScheduledStatuses guards', () {
    test('throws when not signed in', () {
      final status = MockAccessStatus.anonymous();
      expect(() => status.fetchScheduledStatuses(account: MockAccount.create()), throwsException);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
