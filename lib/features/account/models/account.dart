// The Account data schema that is the user account info.
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';

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
  final List<FieldSchema> fields;   // Additional metadata attached to a profile as name-value pairs.
  final List<EmojiSchema> emojis;   // Custom emoji entities to be used when rendering the profile.
  final bool bot;                   // Indicates that the account may perform automated actions.
  final bool? discoverable;         // Whether the account has opted into discovery features such as the profile directory.
  final bool indexable;             // Whether the account allows indexing by search engines.
  final bool? noindex;              // Whether the local user has opted out of being indexed by search engines.
  final bool? hideCollections;      // Whether the account has opted out of showing collections in the profile.
  final DateTime createdAt;         // When the account was created.
  final DateTime? lastStatusAt;     // When the most recent status was posted.
  final int statusesCount;          // How many statuses are attached to this account.
  final int followersCount;         // The reported followers of this profile.
  final int followingCount;         // The reported follows of this profile.
  // CredentialAccount entity attributes
  final RoleSchema? role;           // The complete role assigned to the currently authorized user

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
    this.fields = const [],
    this.emojis = const [],
    required this.bot,
    this.discoverable,
    required this.indexable,
    this.noindex,
    this.hideCollections,
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
      fields: (json['fields'] as List<dynamic>?)
          ?.map((e) => FieldSchema.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      emojis: (json['emojis'] as List<dynamic>?)
          ?.map((e) => EmojiSchema.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      bot: json['bot'] as bool,
      discoverable: json['discoverable'] as bool?,
      indexable: json['indexable'] as bool,
      noindex: json['noindex'] as bool?,
      hideCollections: json['hide_collections'] as bool?,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastStatusAt: json['last_status_at'] == null ? null : DateTime.parse(json['last_status_at'] as String),
      statusesCount: json['statuses_count'] as int,
      followersCount: json['followers_count'] as int,
      followingCount: json['following_count'] as int,
      role: json['role'] == null ? null : RoleSchema.fromJson(json['role'] as Map<String, dynamic>),
    );
  }

  AccountCredentialSchema toCredentialSchema() {
    return AccountCredentialSchema(
      displayName: displayName,
      note: canonicalizeHtml(note),
      locked: locked,
      bot: bot,
      discoverable: discoverable ?? true,
      hideCollections: hideCollections ?? false,
      indexable: indexable,
      fields: fields.map((field) => FieldSchema(
        name: field.name,
        value: canonicalizeHtml(field.value),
        verifiedAt: field.verifiedAt,
      )).toList(),
    );
  }
}

// The type list for the account profile, based on the Mastodon API.
enum AccountProfileType {
  profile,       // The profile of the specified user.
  post,          // The statuses posted from the given user.
  pin,           // The pinned statuses for the logged in user.
  followers,     // The followers of the logged in user.
  following,     // The accounts followed by the logged in user.
  schedule,      // The scheduled statuses for the logged in user.
  hashtag,       // The hashtag timeline for the current server.
  filter,        // The created and managed filters.
  mute,          // The muted accounts for the logged in user.
  block;         // The blocked accounts for the logged in user.

  // The tooltip text for the profile type, localized if possible.
  String tooltip(BuildContext context) {
    switch (this) {
      case profile:
        return AppLocalizations.of(context)?.btn_profile_core ?? "Profile";
      case post:
        return AppLocalizations.of(context)?.btn_profile_post ?? "Posts";
      case pin:
        return AppLocalizations.of(context)?.btn_profile_pin ?? "Pinned Posts";
      case followers:
        return AppLocalizations.of(context)?.btn_profile_followers ?? "Followers";
      case following:
        return AppLocalizations.of(context)?.btn_profile_following ?? "Following";
      case schedule:
        return AppLocalizations.of(context)?.btn_profile_scheduled ?? "Scheduled Posts";
      case hashtag:
        return AppLocalizations.of(context)?.btn_profile_hashtag ?? "Hashtags";
      case filter:
        return AppLocalizations.of(context)?.btn_profile_filter ?? "Filters";
      case mute:
        return AppLocalizations.of(context)?.btn_profile_mute ?? "Muted Accounts";
      case block:
        return AppLocalizations.of(context)?.btn_profile_block ?? "Blocked Accounts";
    }
  }

  // The icon associated with the profile type, based on the action type.
  IconData icon({bool active = false}) {
    switch (this) {
      case profile:
        return active ? Icons.contact_page : Icons.contact_page_outlined;
      case post:
        return active ? Icons.article : Icons.article_outlined;
      case pin:
        return active ? Icons.push_pin : Icons.push_pin_outlined;
      case followers:
        return active ? Icons.visibility : Icons.visibility_outlined;
      case following:
        return active ? Icons.star : Icons.star_outline_outlined;
      case schedule:
        return active ? Icons.schedule : Icons.schedule_outlined;
      case hashtag:
        return active ? Icons.tag : Icons.tag_outlined;
      case filter:
        return active ? Icons.filter_list : Icons.filter_list_outlined;
      case mute:
        return active ? Icons.volume_off : Icons.volume_off_outlined;
      case block:
        return active ? Icons.block : Icons.block_outlined;
    }
  }

  // The type of the profile button, used to determine the profile type related on self-profile.
  bool get selfProfile {
    switch (this) {
      case AccountProfileType.profile:
      case AccountProfileType.post:
      case AccountProfileType.pin:
      case AccountProfileType.followers:
      case AccountProfileType.following:
      case AccountProfileType.filter:
        return true;
      default:
        return false;
    }
  }

  // Get the related timeline type for the profile type.
  TimelineType get timelineType {
    switch (this) {
      case AccountProfileType.post:
        return TimelineType.user;
      case AccountProfileType.schedule:
        return TimelineType.schedule;
      case AccountProfileType.pin:
        return TimelineType.pin;
      case AccountProfileType.hashtag:
        return TimelineType.hashtag;
      default:
        throw ArgumentError("Invalid profile type for timeline: $this");
    }
  }
}

// Additional metadata attached to a profile as name-value pairs.
class FieldSchema {
  final String name;                // The name of the field.
  final String value;               // The value of the field.
  final String? verifiedAt;         // The date when the field was verified, if applicable

  static List<IconData> icons = [
      Icons.looks_one_rounded,
      Icons.looks_two_rounded,
      Icons.looks_3_rounded,
      Icons.looks_4_rounded,
      Icons.looks_5_rounded,
      Icons.looks_6_rounded,
    ];

  const FieldSchema({
    required this.name,
    required this.value,
    this.verifiedAt,
  });

  factory FieldSchema.fromJson(Map<String, dynamic> json) {
    return FieldSchema(
      name: json['name'] as String,
      value: json['value'] as String,
      verifiedAt: json['verified_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
    };
  }
}

// The updated account credential schema that includes the account info and used for
// changes in the account profile.
class AccountCredentialSchema {
  final String displayName;              // The display name to use for the profile.
  final String note;                     // The account bio.
  final bool locked;                     // Whether manual approval of follow requests is required.
  final bool bot;                        // Whether the account has a bot flag.
  final bool discoverable;               // Whether the account should be shown in the profile directory.
  final bool hideCollections;            // Whether to hide followers and followed accounts.
  final bool indexable;                  // Whether public posts should be searchable to anyone.
  final List<FieldSchema> fields;        // Additional metadata attached to the profile.
  final File? avatar;                    // Avatar image encoded using multipart/form-data.
  final File? header;                    // Header image encoded using multipart/form-data.

  const AccountCredentialSchema({
    required this.displayName,
    required this.note,
    required this.locked,
    required this.bot,
    required this.discoverable,
    required this.hideCollections,
    required this.indexable,
    this.fields = const [],
    this.avatar,
    this.header,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'display_name': displayName,
      'note': note,
      'locked': locked,
      'bot': bot,
      'discoverable': discoverable,
      'hide_collections': hideCollections,
      'indexable': indexable,
      'fields_attributes': fields.asMap().map((index, field) {
        return MapEntry(index.toString(), {
          'name': field.name,
          'value': field.value,
        });
      }),
    };

    return Map.fromEntries(
      json
      .entries
      .where((entry) => entry.value != null && entry.value.toString().isNotEmpty)
      .map((entry) => MapEntry(entry.key, entry.value))
    ).cast<String, dynamic>();
  }

  Map<String, File> toFiles() {
    return {
      if (avatar != null) 'avatar': avatar!,
      if (header != null) 'header': header!,
    };
  }

  AccountCredentialSchema copyWith({
    String? displayName,
    String? note,
    bool? locked,
    bool? bot,
    bool? discoverable,
    bool? hideCollections,
    bool? indexable,
    List<FieldSchema>? fields,
    File? avatar,
    File? header,
  }) {
    return AccountCredentialSchema(
      displayName: displayName ?? this.displayName,
      note: note ?? this.note,
      locked: locked ?? this.locked,
      bot: bot ?? this.bot,
      discoverable: discoverable ?? this.discoverable,
      hideCollections: hideCollections ?? this.hideCollections,
      indexable: indexable ?? this.indexable,
      fields: fields ?? this.fields,
      avatar: avatar ?? this.avatar,
      header: header ?? this.header,
    );
  }
}

// The list of the edit profile categories that can be used to edit the profile.
enum EditProfileCategory {
  general,    // The basic information of the account, including display name, bio and other info.
  privacy;    // The privacy setup of the current account.

  // The tooltip text for the edit profile category, localized if possible.
  String tooltip(BuildContext context) {
    switch (this) {
      case EditProfileCategory.general:
        return AppLocalizations.of(context)?.btn_profile_general_info ?? "General Info";
      case EditProfileCategory.privacy:
        return AppLocalizations.of(context)?.btn_profile_privacy ?? "Privacy Settings";
    }
  }

  // The icon associated with the edit profile category, based on the action type.
  IconData icon({bool active = false}) {
    switch (this) {
      case EditProfileCategory.general:
        return active ? CupertinoIcons.doc_person_fill : CupertinoIcons.doc_person;
      case EditProfileCategory.privacy:
        return active ? Icons.privacy_tip : Icons.privacy_tip_outlined;
    }
  }
}

// vim: set ts=2 sw=2 sts=2 et:
