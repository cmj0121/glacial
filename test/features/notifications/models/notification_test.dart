import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:glacial/features/models.dart';

void main() {
  // JSON helpers
  Map<String, dynamic> accountJson({String id = '1'}) => {
    'id': id,
    'username': 'testuser',
    'acct': 'testuser',
    'url': 'https://example.com/@testuser',
    'display_name': 'Test User',
    'note': '',
    'avatar': 'https://example.com/avatar.png',
    'avatar_static': 'https://example.com/avatar.png',
    'header': 'https://example.com/header.png',
    'locked': false,
    'bot': false,
    'indexable': true,
    'created_at': '2024-01-01T00:00:00.000Z',
    'statuses_count': 10,
    'followers_count': 5,
    'following_count': 3,
  };

  Map<String, dynamic> statusJson({String id = '100'}) => {
    'id': id,
    'content': '<p>Hello</p>',
    'visibility': 'public',
    'sensitive': false,
    'spoiler_text': '',
    'account': accountJson(),
    'uri': 'https://example.com/statuses/$id',
    'reblogs_count': 0,
    'favourites_count': 0,
    'replies_count': 0,
    'created_at': '2024-06-15T12:00:00.000Z',
  };

  group('NotificationType', () {
    test('fromString parses standard types', () {
      expect(NotificationType.fromString('mention'), NotificationType.mention);
      expect(NotificationType.fromString('reblog'), NotificationType.reblog);
      expect(NotificationType.fromString('follow'), NotificationType.follow);
      expect(NotificationType.fromString('favourite'), NotificationType.favourite);
      expect(NotificationType.fromString('poll'), NotificationType.poll);
      expect(NotificationType.fromString('update'), NotificationType.update);
      expect(NotificationType.fromString('status'), NotificationType.status);
    });

    test('fromString parses snake_case types', () {
      expect(NotificationType.fromString('follow_request'), NotificationType.followRequest);
    });

    test('fromString parses admin dot-notation types', () {
      expect(NotificationType.fromString('admin.sign_up'), NotificationType.adminSignUp);
      expect(NotificationType.fromString('admin.report'), NotificationType.adminReport);
    });

    test('fromString falls back to unknown for unrecognized type', () {
      expect(NotificationType.fromString('nonexistent'), NotificationType.unknown);
      expect(NotificationType.fromString(''), NotificationType.unknown);
    });

    test('isAdminOnly returns correct values', () {
      expect(NotificationType.adminSignUp.isAdminOnly, true);
      expect(NotificationType.adminReport.isAdminOnly, true);
      expect(NotificationType.mention.isAdminOnly, false);
      expect(NotificationType.follow.isAdminOnly, false);
    });
  });

  group('GroupSchema', () {
    test('fromJson parses all fields', () {
      final json = {
        'group_key': 'favourite-100',
        'notifications_count': 5,
        'most_recent_notification_id': 42,
        'type': 'favourite',
        'sample_account_ids': ['1', '2', '3'],
        'status_id': '100',
        'page_max_id': '50',
        'page_min_id': '46',
      };
      final group = GroupSchema.fromJson(json);

      expect(group.key, 'favourite-100');
      expect(group.count, 5);
      expect(group.id, 42);
      expect(group.type, NotificationType.favourite);
      expect(group.accounts, ['1', '2', '3']);
      expect(group.statusID, '100');
      expect(group.pageMaxID, '50');
      expect(group.pageMinID, '46');
    });

    test('fromJson handles null optional fields', () {
      final json = {
        'group_key': 'follow-1',
        'notifications_count': 1,
        'most_recent_notification_id': 10,
        'type': 'follow',
        'sample_account_ids': ['5'],
      };
      final group = GroupSchema.fromJson(json);

      expect(group.statusID, isNull);
      expect(group.pageMaxID, isNull);
      expect(group.pageMinID, isNull);
    });

    test('fromJson handles zero count defaults', () {
      final json = {
        'group_key': 'key',
        'type': 'mention',
        'sample_account_ids': <String>[],
      };
      final group = GroupSchema.fromJson(json);

      expect(group.count, 0);
      expect(group.id, 0);
    });
  });

  group('GroupNotificationSchema', () {
    test('fromJson parses nested accounts/statuses/groups', () {
      final json = {
        'accounts': [accountJson(id: '1'), accountJson(id: '2')],
        'statuses': [statusJson(id: '100')],
        'notification_groups': [
          {
            'group_key': 'favourite-100',
            'notifications_count': 2,
            'most_recent_notification_id': 10,
            'type': 'favourite',
            'sample_account_ids': ['1', '2'],
            'status_id': '100',
          },
        ],
      };
      final notif = GroupNotificationSchema.fromJson(json);

      expect(notif.accounts.length, 2);
      expect(notif.statuses.length, 1);
      expect(notif.groups.length, 1);
      expect(notif.isEmpty, false);
    });

    test('fromJson empty lists', () {
      final json = {
        'accounts': <Map<String, dynamic>>[],
        'statuses': <Map<String, dynamic>>[],
        'notification_groups': <Map<String, dynamic>>[],
      };
      final notif = GroupNotificationSchema.fromJson(json);

      expect(notif.isEmpty, true);
    });

    test('fromString round-trip', () {
      final json = {
        'accounts': [accountJson()],
        'statuses': <Map<String, dynamic>>[],
        'notification_groups': <Map<String, dynamic>>[],
      };
      final notif = GroupNotificationSchema.fromString(jsonEncode(json));

      expect(notif.accounts.length, 1);
    });
  });

  group('MarkerSchema', () {
    test('fromJson parses all fields with DateTime', () {
      final json = {
        'last_read_id': '12345',
        'version': 3,
        'updated_at': '2024-06-15T12:00:00.000Z',
      };
      final marker = MarkerSchema.fromJson(json);

      expect(marker.lastReadID, '12345');
      expect(marker.version, 3);
      expect(marker.updatedAt, DateTime.utc(2024, 6, 15, 12));
    });
  });

  group('MarkersSchema', () {
    test('fromJson parses home and notifications markers', () {
      final json = {
        'home': {
          'last_read_id': '100',
          'version': 1,
          'updated_at': '2024-06-15T12:00:00.000Z',
        },
        'notifications': {
          'last_read_id': '200',
          'version': 2,
          'updated_at': '2024-06-16T12:00:00.000Z',
        },
      };
      final markers = MarkersSchema.fromJson(json);

      expect(markers.markers.length, 2);
      expect(markers.markers[TimelineMarkerType.home]!.lastReadID, '100');
      expect(markers.markers[TimelineMarkerType.notifications]!.lastReadID, '200');
    });

    test('fromJson ignores unknown marker types', () {
      final json = {
        'home': {
          'last_read_id': '100',
          'version': 1,
          'updated_at': '2024-06-15T12:00:00.000Z',
        },
        'unknown_timeline': {
          'last_read_id': '999',
          'version': 1,
          'updated_at': '2024-06-15T12:00:00.000Z',
        },
      };
      final markers = MarkersSchema.fromJson(json);

      expect(markers.markers.length, 1);
      expect(markers.markers.containsKey(TimelineMarkerType.home), true);
    });

    test('fromString round-trip', () {
      final json = {
        'home': {
          'last_read_id': '100',
          'version': 1,
          'updated_at': '2024-06-15T12:00:00.000Z',
        },
      };
      final markers = MarkersSchema.fromString(jsonEncode(json));

      expect(markers.markers[TimelineMarkerType.home]!.lastReadID, '100');
    });
  });

  group('NotificationPolicySchema', () {
    test('fromJson parses all fields', () {
      final json = {
        'for_not_following': 'filter',
        'for_not_followers': 'drop',
        'for_new_accounts': 'accept',
        'for_private_mentions': 'filter',
        'for_limited_accounts': 'drop',
        'summary': {
          'pending_requests_count': 5,
          'pending_notifications_count': 12,
        },
      };
      final policy = NotificationPolicySchema.fromJson(json);

      expect(policy.forNotFollowing, NotificationPolicyValue.filter);
      expect(policy.forNotFollowers, NotificationPolicyValue.drop);
      expect(policy.forNewAccounts, NotificationPolicyValue.accept);
      expect(policy.forPrivateMentions, NotificationPolicyValue.filter);
      expect(policy.forLimitedAccounts, NotificationPolicyValue.drop);
      expect(policy.pendingRequestsCount, 5);
      expect(policy.pendingNotificationsCount, 12);
    });

    test('fromJson defaults to accept when fields missing', () {
      final json = <String, dynamic>{};
      final policy = NotificationPolicySchema.fromJson(json);

      expect(policy.forNotFollowing, NotificationPolicyValue.accept);
      expect(policy.forNotFollowers, NotificationPolicyValue.accept);
      expect(policy.forNewAccounts, NotificationPolicyValue.accept);
      expect(policy.forPrivateMentions, NotificationPolicyValue.accept);
      expect(policy.forLimitedAccounts, NotificationPolicyValue.accept);
      expect(policy.pendingRequestsCount, 0);
      expect(policy.pendingNotificationsCount, 0);
    });

    test('copyWith updates specified fields', () {
      final original = NotificationPolicySchema.fromJson({
        'for_not_following': 'accept',
        'for_not_followers': 'accept',
        'for_new_accounts': 'accept',
        'for_private_mentions': 'accept',
        'for_limited_accounts': 'accept',
      });
      final updated = original.copyWith(
        forNotFollowing: NotificationPolicyValue.drop,
        forNewAccounts: NotificationPolicyValue.filter,
      );

      expect(updated.forNotFollowing, NotificationPolicyValue.drop);
      expect(updated.forNewAccounts, NotificationPolicyValue.filter);
      // Unchanged
      expect(updated.forNotFollowers, NotificationPolicyValue.accept);
      expect(updated.forPrivateMentions, NotificationPolicyValue.accept);
    });

    test('toJson produces correct output', () {
      final policy = NotificationPolicySchema.fromJson({
        'for_not_following': 'filter',
        'for_not_followers': 'drop',
        'for_new_accounts': 'accept',
        'for_private_mentions': 'filter',
        'for_limited_accounts': 'accept',
      });
      final json = policy.toJson();

      expect(json['for_not_following'], 'filter');
      expect(json['for_not_followers'], 'drop');
      expect(json['for_new_accounts'], 'accept');
      expect(json['for_private_mentions'], 'filter');
      expect(json['for_limited_accounts'], 'accept');
    });

    test('toJson round-trip preserves values', () {
      final original = NotificationPolicySchema.fromJson({
        'for_not_following': 'drop',
        'for_not_followers': 'filter',
        'for_new_accounts': 'accept',
        'for_private_mentions': 'drop',
        'for_limited_accounts': 'filter',
      });
      final json = original.toJson();

      // Rebuild from toJson output (cast to match fromJson signature)
      final rebuilt = NotificationPolicySchema.fromJson(Map<String, dynamic>.from(json));

      expect(rebuilt.forNotFollowing, original.forNotFollowing);
      expect(rebuilt.forNotFollowers, original.forNotFollowers);
      expect(rebuilt.forNewAccounts, original.forNewAccounts);
      expect(rebuilt.forPrivateMentions, original.forPrivateMentions);
      expect(rebuilt.forLimitedAccounts, original.forLimitedAccounts);
    });
  });

  group('NotificationPolicyValue', () {
    test('fromString parses all values', () {
      expect(NotificationPolicyValue.fromString('accept'), NotificationPolicyValue.accept);
      expect(NotificationPolicyValue.fromString('filter'), NotificationPolicyValue.filter);
      expect(NotificationPolicyValue.fromString('drop'), NotificationPolicyValue.drop);
    });

    test('fromString defaults to accept for unknown', () {
      expect(NotificationPolicyValue.fromString('invalid'), NotificationPolicyValue.accept);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
