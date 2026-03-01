// Tests for notification API extensions.
import 'package:flutter_test/flutter_test.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/mastodon/extensions.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  AccessStatusSchema noDomainAuth() =>
      const AccessStatusSchema(domain: '', accessToken: 'token');

  group('GroupNotificationExtensions checkSignedIn guards', () {
    test('dismissNotificationGroup throws when not signed in', () {
      final status = MockAccessStatus.anonymous();
      expect(() => status.dismissNotificationGroup('gk-1'), throwsException);
    });

    test('getNotificationGroup throws when not signed in', () {
      final status = MockAccessStatus.anonymous();
      expect(() => status.getNotificationGroup('gk-1'), throwsException);
    });

    test('getNotificationGroupAccounts throws when not signed in', () {
      final status = MockAccessStatus.anonymous();
      expect(() => status.getNotificationGroupAccounts('gk-1'), throwsException);
    });

    test('getNotificationPolicy throws when not signed in', () {
      final status = MockAccessStatus.anonymous();
      expect(() => status.getNotificationPolicy(), throwsException);
    });

    test('updateNotificationPolicy throws when not signed in', () {
      final status = MockAccessStatus.anonymous();
      final policy = MockNotificationPolicy.create();
      expect(() => status.updateNotificationPolicy(policy), throwsException);
    });
  });

  group('GroupNotificationExtensions with no domain', () {
    test('getNotificationGroup returns schema when no domain', () async {
      final result = await noDomainAuth().getNotificationGroup('gk-1');
      expect(result, isNotNull);
    });

    test('getNotificationGroupAccounts returns empty list when no domain', () async {
      final result = await noDomainAuth().getNotificationGroupAccounts('gk-1');
      expect(result, isEmpty);
    });

    test('getUnreadGroupCount returns 0 when no domain', () async {
      final result = await noDomainAuth().getUnreadGroupCount();
      expect(result, 0);
    });

    test('getNotificationPolicy returns schema when no domain', () async {
      final result = await noDomainAuth().getNotificationPolicy();
      expect(result, isNotNull);
    });

    test('dismissNotificationGroup completes when no domain', () async {
      await noDomainAuth().dismissNotificationGroup('gk-1');
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
