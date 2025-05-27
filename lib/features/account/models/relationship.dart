// The Account data schema that is the user account info.
import 'dart:convert';

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
}

// vim: set ts=2 sw=2 sts=2 et:
