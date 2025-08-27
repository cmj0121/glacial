// The relationship data schema for account, including permissions and roles.
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';

// To determine the permissions available to a certain role
enum PermissionBitmap {
  administrator(0x0001),   // Users with this permission bypass all permissions.
  devops(0x0002),          // Allows users to access Sidekiq and PgHero dashboards.
  audit(0x0004),           // Allows users to see history of admin actions.
  dashboard(0x0008),       // Allows users to access the dashboard and various metrics.
  reports(0x0010),         // Allows users to review reports and perform moderation actions against them.
  federation(0x0020),      // Allows users to block or allow federation with other domains, and control deliverability.
  settings(0x0040),        // Allows users to change site settings.
  blocks(0x0080),          // Allows users to block e-mail providers and IP addresses.
  taxonomies(0x0100),      // Allows users to review trending content and update hashtag settings
  appeals(0x0200),         // Allows users to review appeals against moderation actions.
  users(0x0400),           // Allows users to view other users’ details and perform moderation actions against them.
  invites(0x0800),         // Allows users to browse and deactivate invite links.
  rules(0x1000),           // Allows users to change server rules.
  announcements(0x2000),   // Allows users to manage announcements on the server.
  emojis(0x4000),          // Allows users to manage custom emojis on the server.
  webhooks(0x8000),        // Allows users to set up webhooks for administrative events.
  inviteUsers(0x10000),    // Allows users to invite new people to the server.
  roles(0x20000),          // Allows users to manage and assign roles below theirs.
  access(0x40000),         // Allows users to disable other users’ access to the server.
  deleteUserData(0x80000); // Allows users to delete other users’ data without delay.

  final int bit;
  const PermissionBitmap(this.bit);

  factory PermissionBitmap.fromInt(int bits) {
    return PermissionBitmap.values.firstWhere((e) => e.bit == bits, orElse: () => throw ArgumentError("Invalid permission bit: $bits"));
  }

  factory PermissionBitmap.fromString(String str) {
    return PermissionBitmap.fromInt(int.parse(str));
  }
}

// The relationship type between two accounts, used to determine the relationship status.
enum RelationshipType {
  // The basic relationship types.
  following,          // You are following this user.
  followedBy,         // This user is following you.
  followEachOther,    // You and this user are following each other.
  followRequest,      // You have sent a follow request to this user and wait for their approval.
  stranger,           // You are not following this user, and they are not following you.
  blockedBy,          // This user is blocking you.
  // The more actions relationship types.
  mute,               // You are muting this user.
  unmute,             // You are unmuting this user.
  block,              // You are blocking this user.
  unblock,            // You are unblocking this user.
  report;             // You have reported this user.

  // The icon associated with the relationship type.
  IconData icon() {
    switch (this) {
      case following:
        return Icons.star;
      case followedBy:
        return Icons.visibility;
      case followEachOther:
        return Icons.handshake_sharp;
      case followRequest:
        return Icons.pending_actions_rounded;
      case stranger:
        return Icons.person_add;
      case blockedBy:
        return Icons.do_not_disturb_on;
      case mute:
        return Icons.volume_off;
      case unmute:
        return Icons.volume_up;
      case block:
        return Icons.block;
      case unblock:
        return Icons.block_outlined;
      case report:
        return Icons.report;
    }
  }

  // The tooltip text for the relationship type, localized if possible.
  String tooltip(BuildContext context, {AccountSchema? account}) {
    final String acct = account == null ? "" : " @${account.acct}";
    switch (this) {
      case following:
        return AppLocalizations.of(context)?.btn_relationship_following ?? "Following";
      case followedBy:
        return AppLocalizations.of(context)?.btn_relationship_followed_by ?? "Followed by";
      case followEachOther:
        return AppLocalizations.of(context)?.btn_relationship_follow_each_other ?? "Follow each other";
      case followRequest:
        return AppLocalizations.of(context)?.btn_relationship_follow_request ?? "Follow Request";
      case stranger:
        return AppLocalizations.of(context)?.btn_relationship_stranger ?? "Stranger";
      case blockedBy:
        return AppLocalizations.of(context)?.btn_relationship_blocked_by ?? "Blocked By";
      case mute:
        return AppLocalizations.of(context)?.btn_relationship_mute(acct) ?? "Muted";
      case unmute:
        return AppLocalizations.of(context)?.btn_relationship_unmute(acct) ?? "Unmuted";
      case block:
        return AppLocalizations.of(context)?.btn_relationship_block(acct) ?? "Blocked";
      case unblock:
        return AppLocalizations.of(context)?.btn_relationship_unblock(acct) ?? "Unblocked";
      case report:
        return AppLocalizations.of(context)?.btn_relationship_report(acct) ?? "Reported";
    }
  }

  // Check if the relationship type is belonging to the more actions category.
  bool get isMoreActions {
    switch (this) {
      case following:
      case followedBy:
      case followEachOther:
      case followRequest:
      case stranger:
      case blockedBy:
      case unblock:
        return false;
      default:
        return true;
    }
  }

  // Check the actions is dangerous, such as block or report.
  bool get isDangerous {
    switch (this) {
      case mute:
      case block:
      case report:
        return true;
      default:
        return false;
    }
  }
}

// Represents a custom user role that grants permissions.
class RoleSchema {
  final String id;                // The ID of the Role in the database.
  final String name;              // The name of the role.
  final String color;             // The hex code assigned to this role. If no hex code is assigned, the string will be empty.
  final String permissions;       // A bitmask that represents the sum of all permissions granted to the role.
  final bool highlighted;         // Whether the role is publicly visible as a badge on user profiles.

  const RoleSchema({
    required this.id,
    required this.name,
    required this.color,
    required this.permissions,
    required this.highlighted,
  });

  factory RoleSchema.fromJson(Map<String, dynamic> json) {
    return RoleSchema(
      id: json['id'] as String,
      name: json['name'] as String,
      color: json['color'] as String,
      permissions: json['permissions'] as String,
      highlighted: json['highlighted'] as bool,
    );
  }

  // Check the user has the admin-related permission.
  int get bits => int.parse(permissions);
  bool get hasPrivilege => bits > 0;
}

// The relationship between accounts, such as following / blocking / muting / etc
class RelationshipSchema {
  final String id;                // The account id of the user this relationship is about.
  final bool following;           // Are you following this user?
  final bool followedBy;          // Are you followed by this user?
  final bool blocking;            // Are you blocking this user?
  final bool blockedBy;           // Is this user blocking you?
  final bool muting;              // Are you muting this user?
  final bool mutingNotifications; // Are you muting notifications from this user?
  final bool requested;           // Are you following this user, but your follow request is pending?
  final bool requestedBy;         // Has this user requested to follow you?
  final bool domainBlocking;      // Are you blocking this user’s domain?
  final bool endorsed;            // Are you featuring this user on your profile?
  final String note;              // This user’s profile bio
  final bool showingReblogs;      // Are you receiving this user’s boosts in your home timeline?
  final bool notifying;           // Have you enabled notifications for this user?
  final List<String> languages;   // Which languages are you following from this user?

  const RelationshipSchema({
    required this.id,
    required this.following,
    required this.followedBy,
    required this.blocking,
    required this.blockedBy,
    required this.muting,
    required this.mutingNotifications,
    required this.requested,
    required this.requestedBy,
    required this.domainBlocking,
    required this.endorsed,
    required this.note,
    required this.showingReblogs,
    required this.notifying,
    this.languages = const [],
  });

  factory RelationshipSchema.fromString(String str) {
    final Map<String, dynamic> json = jsonDecode(str) as Map<String, dynamic>;
    return RelationshipSchema.fromJson(json);
  }

  factory RelationshipSchema.fromJson(Map<String, dynamic> json) {
    return RelationshipSchema(
      id: json['id'] as String,
      following: json['following'] as bool,
      followedBy: json['followed_by'] as bool,
      blocking: json['blocking'] as bool,
      blockedBy: json['blocked_by'] as bool,
      muting: json['muting'] as bool,
      mutingNotifications: json['muting_notifications'] as bool,
      requested: json['requested'] as bool,
      requestedBy: json['requested_by'] as bool,
      domainBlocking: json['domain_blocking'] as bool,
      endorsed: json['endorsed'] as bool,
      note: json['note'] as String,
      showingReblogs: json['showing_reblogs'] as bool,
      notifying: json['notifying'] as bool,
      languages: (json['languages'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList() ?? const [],
    );
  }

  // Convert the relationship schema to RelationshipType
  RelationshipType get type {
    if (blockedBy) {
      return RelationshipType.blockedBy;
    } else if (blocking) {
      return RelationshipType.unblock;
    } else if (requested) {
      return RelationshipType.followRequest;
    } else if (following && followedBy) {
      return RelationshipType.followEachOther;
    } else if (following) {
      return RelationshipType.following;
    } else if (followedBy) {
      return RelationshipType.followedBy;
    } else {
      return RelationshipType.stranger;
    }
  }
}

// vim: set ts=2 sw=2 sts=2 et:
