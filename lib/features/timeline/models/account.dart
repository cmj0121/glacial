// The Account data schema that is the user account info.

import 'package:glacial/features/timeline/models/core.dart';

// The Account data schema that is the user account info.
class AccountSchema {
  final String id;                  // The account id.
  final String username;            // The username of the account, not including domain.
  final String acct;                // Equal to username for local users, or username@domain for remote users.
  final String displayName;         // The profile's display name.
  final String avatar;              // An image icon that is shown next to statuses and in the profile.
  final List<EmojiSchema> emojis;   // Custom emoji entities to be used when rendering the profile.

  const AccountSchema({
    required this.id,
    required this.username,
    required this.acct,
    required this.displayName,
    required this.avatar,
    this.emojis = const [],
  });

  factory AccountSchema.fromJson(Map<String, dynamic> json) {
    return AccountSchema(
      id: json['id'] as String,
      username: json['username'] as String,
      acct: json['acct'] as String,
      displayName: json['display_name'] as String,
      avatar: json['avatar'] as String,
      emojis: (json['emojis'] as List<dynamic>).map((e) => EmojiSchema.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
