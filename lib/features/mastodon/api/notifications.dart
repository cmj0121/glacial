// Receive grouped notifications for activity on your account or statuses.
//
// ## Group Notifications APIs
//
//   - [+] GET   /api/v2/notifications
//   - [+] GET   /api/v2/notifications/:group_key
//   - [+] POST  /api/v2/notifications/:group_key/dismiss
//   - [+] GET   /api/v2/notifications/:group_key/accounts
//   - [+] GET   /api/v2/notifications/unread_count
//   - [+] GET   /api/v2/notifications/policy
//   - [+] PATCH /api/v2/notifications/policy
//
// ref:
//   - https://docs.joinmastodon.org/methods/grouped_notifications/
//   - https://docs.joinmastodon.org/methods/notifications/
import 'dart:async';
import 'dart:convert';

import 'package:glacial/features/models.dart';

extension GroupNotificationExtensions on AccessStatusSchema {
  // Return grouped notifications concerning the user.
  Future<GroupNotificationSchema?> fetchNotifications({String? maxId}) async {
    final String endpoint = '/api/v2/notifications';
    final Map<String, String> queryParameters = {"max_id": maxId ?? ''};
    final String body = await getAPI(endpoint, queryParameters: queryParameters) ?? '{}';

    return GroupNotificationSchema.fromString(body);
  }

  // Dismiss a single notification group by its group key.
  Future<void> dismissNotificationGroup(String groupKey) async {
    checkSignedIn();

    final String endpoint = '/api/v2/notifications/$groupKey/dismiss';
    await postAPI(endpoint);
  }

  // Get a single notification group by its group key.
  Future<GroupNotificationSchema?> getNotificationGroup(String groupKey) async {
    checkSignedIn();

    final String endpoint = '/api/v2/notifications/$groupKey';
    final String body = await getAPI(endpoint) ?? '{}';

    return GroupNotificationSchema.fromString(body);
  }

  // Get accounts for a single notification group by its group key.
  Future<List<AccountSchema>> getNotificationGroupAccounts(String groupKey) async {
    checkSignedIn();

    final String endpoint = '/api/v2/notifications/$groupKey/accounts';
    final String body = await getAPI(endpoint) ?? '[]';
    final List<dynamic> json = jsonDecode(body) as List<dynamic>;

    return json.map((e) => AccountSchema.fromJson(e as Map<String, dynamic>)).toList();
  }

  // Get the (capped) number of unread notification groups for the current user
  Future<int> getUnreadGroupCount() async {
    final String endpoint = '/api/v2/notifications/unread_count';
    final String body = await getAPI(endpoint) ?? '{}';
    final Map<String, dynamic> json = jsonDecode(body) as Map<String, dynamic>;

    return json['count'] as int? ?? 0;
  }

  // Get the current notification filtering policy for the authenticated user.
  Future<NotificationPolicySchema?> getNotificationPolicy() async {
    checkSignedIn();

    final String body = await getAPI('/api/v2/notifications/policy') ?? '{}';
    final Map<String, dynamic> json = jsonDecode(body) as Map<String, dynamic>;

    return NotificationPolicySchema.fromJson(json);
  }

  // Update the notification filtering policy for the authenticated user.
  Future<NotificationPolicySchema?> updateNotificationPolicy(NotificationPolicySchema policy) async {
    checkSignedIn();

    final String body = await patchAPI('/api/v2/notifications/policy', body: policy.toJson()) ?? '{}';
    final Map<String, dynamic> json = jsonDecode(body) as Map<String, dynamic>;

    return NotificationPolicySchema.fromJson(json);
  }
}

// vim: set ts=2 sw=2 sts=2 et:
