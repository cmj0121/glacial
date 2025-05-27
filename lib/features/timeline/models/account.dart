// The Account data schema that is the user account info.

import 'package:glacial/features/timeline/models/core.dart';

// The Account data schema that is the user account info.
class AccountSchema {
  final String id;                  // The account id.
  final String username;            // The username of the account, not including domain.
  final String acct;                // Equal to username for local users, or username@domain for remote users.
  final String? uri;                // The location of the user’s profile page.
  final String url;                 // The user’s ActivityPub actor identifier.
  final String displayName;         // The profile's display name.
  final String note;                // The profile’s bio or description (HTML).
  final String avatar;              // An image icon that is shown next to statuses and in the profile.
  final String avatarStatic;        // A static version of the avatar. Equal to avatar if its value is a static image.
  final String header;              // An image banner that is shown above the profile and in profile cards.
  final bool locked;                // Whether the account manually approves follow requests.
  final List<EmojiSchema> emojis;   // Custom emoji entities to be used when rendering the profile.
  final bool bot;                   // Indicates that the account may perform automated actions.
  final bool? discoverable;         // Whether the account has opted into discovery features such as the profile directory.
  final bool? noindex;              // Whether the local user has opted out of being indexed by search engines.
  final DateTime createdAt;         // When the account was created.
  final DateTime? lastStatusAt;     // When the most recent status was posted.
  final int statusesCount;          // How many statuses are attached to this account.
  final int followersCount;         // The reported followers of this profile.
  final int followingCount;         // The reported follows of this profile.
  final RoleSchema? role;           // The role of the account, if any.

  const AccountSchema({
    required this.id,
    required this.username,
    required this.acct,
    this.uri,
    required this.url,
    required this.displayName,
    required this.note,
    required this.avatar,
    required this.avatarStatic,
    required this.header,
    required this.locked,
    this.emojis = const [],
    required this.bot,
    this.discoverable,
    this.noindex,
    required this.createdAt,
    this.lastStatusAt,
    required this.statusesCount,
    required this.followersCount,
    required this.followingCount,
    this.role,
  });

  factory AccountSchema.fromJson(Map<String, dynamic> json) {
    return AccountSchema(
      id: json['id'] as String,
      username: json['username'] as String,
      acct: json['acct'] as String,
      uri: json['uri'] as String?,
      url: json['url'] as String,
      displayName: json['display_name'] as String,
      note: json['note'] as String,
      avatar: json['avatar'] as String,
      avatarStatic: json['avatar_static'] as String,
      header: json['header'] as String,
      locked: json['locked'] as bool,
      emojis: (json['emojis'] as List<dynamic>).map((e) => EmojiSchema.fromJson(e as Map<String, dynamic>)).toList(),
      bot: json['bot'] as bool,
      discoverable: json['discoverable'] as bool?,
      noindex: json['noindex'] as bool?,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastStatusAt: json['last_status_at'] == null ? null : DateTime.parse(json['last_status_at'] as String),
      statusesCount: json['statuses_count'] as int,
      followersCount: json['followers_count'] as int,
      followingCount: json['following_count'] as int,
      role: json['role'] == null ? null : RoleSchema.fromJson(json['role'] as Map<String, dynamic>),
    );
  }
}

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

// vim: set ts=2 sw=2 sts=2 et:
