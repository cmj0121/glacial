// Tests for notification models: NotificationType, GroupSchema, NotificationPolicySchema.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glacial/features/models.dart';

void main() {
  group('NotificationType', () {
    test('fromString parses standard types', () {
      expect(NotificationType.fromString('mention'), NotificationType.mention);
      expect(NotificationType.fromString('status'), NotificationType.status);
      expect(NotificationType.fromString('reblog'), NotificationType.reblog);
      expect(NotificationType.fromString('follow'), NotificationType.follow);
      expect(NotificationType.fromString('favourite'), NotificationType.favourite);
      expect(NotificationType.fromString('poll'), NotificationType.poll);
      expect(NotificationType.fromString('update'), NotificationType.update);
    });

    test('fromString parses special string types', () {
      expect(NotificationType.fromString('follow_request'), NotificationType.followRequest);
      expect(NotificationType.fromString('admin.sign_up'), NotificationType.adminSignUp);
      expect(NotificationType.fromString('admin.report'), NotificationType.adminReport);
    });

    test('fromString returns unknown for unrecognized type', () {
      expect(NotificationType.fromString('nonexistent'), NotificationType.unknown);
    });

    test('icon returns correct icons for each type', () {
      expect(NotificationType.mention.icon, Icons.alternate_email);
      expect(NotificationType.status.icon, Icons.chat_bubble);
      expect(NotificationType.reblog.icon, Icons.repeat);
      expect(NotificationType.follow.icon, Icons.person_add);
      expect(NotificationType.followRequest.icon, Icons.person_add_alt);
      expect(NotificationType.favourite.icon, Icons.star);
      expect(NotificationType.poll.icon, Icons.poll);
      expect(NotificationType.update.icon, Icons.edit);
      expect(NotificationType.adminSignUp.icon, Icons.person_add_alt_rounded);
      expect(NotificationType.adminReport.icon, Icons.feedback_rounded);
      expect(NotificationType.unknown.icon, Icons.sentiment_dissatisfied_outlined);
    });

    test('isAdminOnly is true only for admin types', () {
      expect(NotificationType.adminSignUp.isAdminOnly, true);
      expect(NotificationType.adminReport.isAdminOnly, true);
      expect(NotificationType.mention.isAdminOnly, false);
      expect(NotificationType.follow.isAdminOnly, false);
      expect(NotificationType.unknown.isAdminOnly, false);
    });
  });

  group('GroupSchema', () {
    test('fromJson parses all fields', () {
      final json = {
        'group_key': 'favourite-123',
        'notifications_count': 5,
        'most_recent_notification_id': 42,
        'type': 'favourite',
        'sample_account_ids': ['1', '2', '3'],
        'status_id': 'status-456',
        'page_max_id': '100',
        'page_min_id': '90',
      };
      final group = GroupSchema.fromJson(json);
      expect(group.key, 'favourite-123');
      expect(group.count, 5);
      expect(group.id, 42);
      expect(group.type, NotificationType.favourite);
      expect(group.accounts, ['1', '2', '3']);
      expect(group.statusID, 'status-456');
      expect(group.pageMaxID, '100');
      expect(group.pageMinID, '90');
    });

    test('fromJson defaults for missing optional fields', () {
      final json = {
        'group_key': 'follow-1',
        'type': 'follow',
        'sample_account_ids': ['1'],
      };
      final group = GroupSchema.fromJson(json);
      expect(group.count, 0);
      expect(group.id, 0);
      expect(group.statusID, isNull);
      expect(group.pageMaxID, isNull);
      expect(group.pageMinID, isNull);
    });
  });

  group('NotificationPolicyValue', () {
    test('fromString parses all values', () {
      expect(NotificationPolicyValue.fromString('accept'), NotificationPolicyValue.accept);
      expect(NotificationPolicyValue.fromString('filter'), NotificationPolicyValue.filter);
      expect(NotificationPolicyValue.fromString('drop'), NotificationPolicyValue.drop);
    });

    test('fromString defaults to accept for unknown', () {
      expect(NotificationPolicyValue.fromString('unknown'), NotificationPolicyValue.accept);
    });

    test('icon returns correct icons', () {
      expect(NotificationPolicyValue.accept.icon, Icons.check_circle_outline);
      expect(NotificationPolicyValue.filter.icon, Icons.filter_alt_outlined);
      expect(NotificationPolicyValue.drop.icon, Icons.block);
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
          'pending_requests_count': 3,
          'pending_notifications_count': 7,
        },
      };
      final policy = NotificationPolicySchema.fromJson(json);
      expect(policy.forNotFollowing, NotificationPolicyValue.filter);
      expect(policy.forNotFollowers, NotificationPolicyValue.drop);
      expect(policy.forNewAccounts, NotificationPolicyValue.accept);
      expect(policy.forPrivateMentions, NotificationPolicyValue.filter);
      expect(policy.forLimitedAccounts, NotificationPolicyValue.drop);
      expect(policy.pendingRequestsCount, 3);
      expect(policy.pendingNotificationsCount, 7);
    });

    test('fromJson uses defaults for missing fields', () {
      final policy = NotificationPolicySchema.fromJson({});
      expect(policy.forNotFollowing, NotificationPolicyValue.accept);
      expect(policy.pendingRequestsCount, 0);
    });

    test('copyWith updates specific field', () {
      final policy = NotificationPolicySchema.fromJson({
        'for_not_following': 'accept',
        'for_not_followers': 'accept',
        'for_new_accounts': 'accept',
        'for_private_mentions': 'accept',
        'for_limited_accounts': 'accept',
      });
      final updated = policy.copyWith(forNotFollowing: NotificationPolicyValue.drop);
      expect(updated.forNotFollowing, NotificationPolicyValue.drop);
      expect(updated.forNotFollowers, NotificationPolicyValue.accept);
    });

    test('toJson produces correct map', () {
      const policy = NotificationPolicySchema(
        forNotFollowing: NotificationPolicyValue.accept,
        forNotFollowers: NotificationPolicyValue.filter,
        forNewAccounts: NotificationPolicyValue.drop,
        forPrivateMentions: NotificationPolicyValue.accept,
        forLimitedAccounts: NotificationPolicyValue.filter,
      );
      final json = policy.toJson();
      expect(json['for_not_following'], 'accept');
      expect(json['for_not_followers'], 'filter');
      expect(json['for_new_accounts'], 'drop');
    });
  });

  group('MarkerSchema', () {
    test('fromJson parses all fields', () {
      final json = {
        'last_read_id': '12345',
        'version': 3,
        'updated_at': '2024-01-15T10:00:00.000Z',
      };
      final marker = MarkerSchema.fromJson(json);
      expect(marker.lastReadID, '12345');
      expect(marker.version, 3);
      expect(marker.updatedAt, isA<DateTime>());
    });
  });

  group('GroupNotificationSchema', () {
    test('isEmpty returns true for empty schema', () {
      const schema = GroupNotificationSchema(
        accounts: [],
        statuses: [],
        groups: [],
      );
      expect(schema.isEmpty, true);
    });
  });

  group('TimelineMarkerType', () {
    test('all values exist', () {
      expect(TimelineMarkerType.values, hasLength(2));
      expect(TimelineMarkerType.values, contains(TimelineMarkerType.home));
      expect(TimelineMarkerType.values, contains(TimelineMarkerType.notifications));
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
