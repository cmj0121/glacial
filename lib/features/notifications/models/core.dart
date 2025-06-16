// The Notification related data schema.
import 'dart:convert';

import 'package:glacial/features/models.dart';

enum NotificationType {
  mention,        // Someone mentioned you in their status
  status,         // Someone you enabled notifications for has posted a status
  reblog,         // Someone boosted one of your statuses
  follow,         // Someone followed you
  followRequest,  // Someone requested to follow you
  favourite,      // Someone favourited one of your statuses
  poll,           // A poll you have voted in or created has ended
  update,         // A status you boosted with has been edited
  unknown;        // An unknown notification type

  factory NotificationType.fromString(String type) {
    switch (type) {
      case 'follow_request':
        return NotificationType.followRequest;
      default:
        return NotificationType.values.firstWhere(
          (e) => e.name == type,
          orElse: () => NotificationType.unknown,
        );
    }
  }
}

// The grouped notifications themselves
class GroupSchema {
  final String key;            // Group key identifying the grouped notifications. Should be treated as an opaque value.
  final int count;             // Total number of individual notifications that are part of this notification group.
  final NotificationType type; // The type of event that resulted in the notifications in this group.
  final List<String> accounts; // IDs of some of the accounts who most recently triggered notifications in this group.
  final String? statusID;      // The ID of the status that triggered this group, if applicable. (4.3.0 - added)
  final String? pageMaxID;     // ID of the newest notification from this group represented within the current page.
  final String? pageMinID;     // ID of the newest notification from this group represented within the current page.

  const GroupSchema({
    required this.key,
    required this.count,
    required this.type,
    required this.accounts,
    this.statusID,
    this.pageMaxID,
    this.pageMinID,
  });

  factory GroupSchema.fromJson(Map<String, dynamic> json) {
    return GroupSchema(
      key: json['group_key'] as String,
      count: json['notifications_count'] as int,
      type: NotificationType.fromString(json['type'] as String),
      accounts: (json['sample_account_ids'] as List<dynamic>).map((e) => e as String).toList(),
      statusID: json['status_id'] as String?,
      pageMaxID: json['page_max_id'] as String?,
      pageMinID: json['page_min_id'] as String?,
    );
  }
}

class GroupNotificationSchema {
  final List<AccountSchema> accounts; // Accounts referenced by grouped notifications.
  final List<StatusSchema> statuses;  // Statuses referenced by grouped notifications.
  final List<GroupSchema> groups;     // The grouped notifications themselves.

  const GroupNotificationSchema({
    required this.accounts,
    required this.statuses,
    required this.groups,
  });

  factory GroupNotificationSchema.fromString(String str) {
    final Map<String, dynamic> json = jsonDecode(str);
    return GroupNotificationSchema.fromJson(json);
  }

  factory GroupNotificationSchema.fromJson(Map<String, dynamic> json) {
    return GroupNotificationSchema(
      accounts: (json['accounts'] as List<dynamic>).map((e) {
        return AccountSchema.fromJson(e as Map<String, dynamic>);
      }).toList(),
      statuses: (json['statuses'] as List<dynamic>).map((e) {
        return StatusSchema.fromJson(e as Map<String, dynamic>);
      }).toList(),
      groups: (json['notification_groups'] as List<dynamic>).map((e) {
        return GroupSchema.fromJson(e as Map<String, dynamic>);
      }).toList(),
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
