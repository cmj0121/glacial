// The extensions implementation for the grouped notnfications
import 'dart:convert';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';

extension GroupNotificationsExtensions on ServerSchema {
  // Get the (capped) number of unread notification groups for the current user.
  Future<int> unreadNotificationsCount({String? accessToken}) async {
    final Map<String, String> query = {};
    final Uri uri = UriEx.handle(domain, "/api/v2/notifications/unread_count").replace(queryParameters: query);
    final Map<String, String> headers = {"Authorization": "Bearer $accessToken"};

    if (accessToken == null) {
      logger.w("Access token is required for fetching unread notifications count.");
      return 0;
    }

    final response = await get(uri, headers: headers);
    final Map<String, dynamic> json = jsonDecode(response.body);
    return json['count'] as int? ?? 0;
  }

  // Return grouped notifications concerning the user.
  Future<GroupNotificationSchema?> listNotifications({String? accessToken, String? maxId}) async {
    if (accessToken == null) {
      logger.w("Access token is required for fetching notifications.");
      return null;
    }

    final Map<String, String> query = {};
    query["max_id"] = maxId ?? "";

    final Uri uri = UriEx.handle(domain, "/api/v2/notifications").replace(queryParameters: query);
    final Map<String, String> headers = {"Authorization": "Bearer $accessToken"};
    final response = await get(uri, headers: headers);
    final GroupNotificationSchema schema = GroupNotificationSchema.fromString(response.body);

    // cache the account and statuses
    final Storage storage = Storage();
    schema.accounts.map((a) => storage.saveAccountIntoCache(this, a)).toList();
    schema.statuses.map((s) => storage.saveStatusIntoCache(s)).toList();

    return schema;
  }
}

// vim: set ts=2 sw=2 sts=2 et:
