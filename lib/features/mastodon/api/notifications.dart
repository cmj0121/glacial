// Receive grouped notifications for activity on your account or statuses.
//
// ## Group Notifications APIs
//
//   - [+] GET  /api/v2/notifications
//   - [ ] GET  /api/v2/notifications/:group_key
//   - [ ] POST /api/v2/notifications/:group_key/dismiss
//   - [ ] GET  /api/v2/notifications/:group_key/accounts
//   - [ ] GET  /api/v2/notifications/unread_count
//
// ref:
//   - https://docs.joinmastodon.org/methods/grouped_notifications/
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

  // Get the (capped) number of unread notification groups for the current user
  Future<int> getUnreadGroupCount() async {
    final String endpoint = '/api/v2/notifications/unread_count';
    final String body = await getAPI(endpoint) ?? '{}';
    final Map<String, dynamic> json = jsonDecode(body) as Map<String, dynamic>;

    return json['count'] as int? ?? 0;
  }
}

// vim: set ts=2 sw=2 sts=2 et:
