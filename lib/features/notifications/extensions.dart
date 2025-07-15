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

  // Get the current timeline position for the user.
  Future<MarkersSchema?> getTimelinePosition({String? accessToken, required TimelineMarkerType type}) async {
    if (accessToken == null) {
      logger.w("Access token is required for fetching timeline position.");
      return null;
    }

    final Map<String, String> query = {"timeline": type.name};

    final Uri uri = UriEx.handle(domain, "/api/v1/markers").replace(queryParameters: query);
    final Map<String, String> headers = {"Authorization": "Bearer $accessToken"};
    final response = await get(uri, headers: headers);

    return MarkersSchema.fromString(response.body);
  }

  // Update the current timeline position for the user.
  Future<MarkersSchema?> updateTimelinePosition({String? accessToken, required String? id, required TimelineMarkerType type,
  }) async {
    if (accessToken == null) {
      logger.w("Access token is required for updating timeline position.");
      return null;
    }

    if (id == null) {
      logger.d("ID is required for updating timeline position.");
      return null;
    }

    final Uri uri = UriEx.handle(domain, "/api/v1/markers");
    final Map<String, String> headers = {"Authorization": "Bearer $accessToken"};
    final Map<String, dynamic> body = {type.name: {"last_read_id": id}};

    final response = await post(uri, headers: headers, body: jsonEncode(body));
    return MarkersSchema.fromString(response.body);
  }
}

// vim: set ts=2 sw=2 sts=2 et:
