// The Account data schema that is the user account info.
import 'package:flutter/material.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';

// The type list for the account profile, based on the Mastodon API.
enum AccountProfileType {
  profile,       // The profile of the specified user.
  user,          // The statuses posted from the given user.
  pin,           // The pinned statuses for the logged in user.
  schedule,      // The scheduled statuses for the logged in user.
  hashtag,       // The hashtag timeline for the current server.
  mute,          // The muted accounts for the logged in user.
  block;         // The blocked accounts for the logged in user.

  String tooltip(BuildContext context) {
    switch (this) {
      case profile:
        return AppLocalizations.of(context)?.btn_profile ?? 'Profile';
      case user:
        return AppLocalizations.of(context)?.btn_user ?? 'User';
      case pin:
        return AppLocalizations.of(context)?.btn_pin ?? 'Pinned';
      case schedule:
        return AppLocalizations.of(context)?.btn_schedule ?? 'Schedule';
      case hashtag:
        return AppLocalizations.of(context)?.btn_trends_tags ?? 'Hashtag';
      case mute:
        return AppLocalizations.of(context)?.btn_mute ?? 'Muted Accounts';
      case block:
        return AppLocalizations.of(context)?.btn_block ?? 'Blocked Accounts';
    }
  }

  IconData icon({bool active = false}) {
    switch (this) {
      case profile:
        return active ? Icons.contact_page : Icons.contact_page_outlined;
      case user:
        return active ? Icons.article : Icons.article_outlined;
      case pin:
        return active ? Icons.push_pin : Icons.push_pin_outlined;
      case schedule:
        return active ? Icons.schedule : Icons.schedule_outlined;
      case hashtag:
        return active ? Icons.tag : Icons.tag_outlined;
      case mute:
        return active ? Icons.volume_off : Icons.volume_off_outlined;
      case block:
        return active ? Icons.block : Icons.block_outlined;
    }
  }

  bool get supportAnonymous {
    switch (this) {
      case AccountProfileType.profile:
      case AccountProfileType.user:
      case AccountProfileType.pin:
        return true;
      case AccountProfileType.schedule:
      case AccountProfileType.hashtag:
      case AccountProfileType.mute:
      case AccountProfileType.block:
        return false;
    }
  }

  TimelineType get toTimelineType {
    switch (this) {
      case AccountProfileType.user:
        return TimelineType.user;
      case AccountProfileType.pin:
        return TimelineType.pin;
      case AccountProfileType.schedule:
        return TimelineType.schedule;
      case AccountProfileType.hashtag:
        return TimelineType.hashtag;
      default:
        throw ArgumentError('invalid AccountProfileType to TimelineType: $this');
    }
  }
}

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

// vim: set ts=2 sw=2 sts=2 et:
