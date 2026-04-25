// The saved account schema for multi-account support.
import 'package:glacial/features/models.dart';

// Represents a saved account entry for quick switching between accounts.
class SavedAccountSchema {
  final String domain;
  final String accountId;
  final String username;
  final String displayName;
  final String avatar;
  final DateTime lastUsed;
  final List<EmojiSchema> emojis;

  const SavedAccountSchema({
    required this.domain,
    required this.accountId,
    required this.username,
    required this.displayName,
    required this.avatar,
    required this.lastUsed,
    this.emojis = const [],
  });

  // Composite key used for token storage and account identification.
  String get compositeKey => '$domain@$accountId';

  factory SavedAccountSchema.fromJson(Map<String, dynamic> json) {
    return SavedAccountSchema(
      domain: json['domain'] as String,
      accountId: json['account_id'] as String,
      username: json['username'] as String,
      displayName: json['display_name'] as String,
      avatar: json['avatar'] as String,
      lastUsed: DateTime.parse(json['last_used'] as String),
      // Default to [] so older persisted entries without `emojis` parse fine.
      emojis: (json['emojis'] as List<dynamic>?)
          ?.map((e) => EmojiSchema.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'domain': domain,
      'account_id': accountId,
      'username': username,
      'display_name': displayName,
      'avatar': avatar,
      'last_used': lastUsed.toIso8601String(),
      'emojis': emojis.map((e) => e.toJson()).toList(),
    };
  }

  SavedAccountSchema copyWith({
    String? domain,
    String? accountId,
    String? username,
    String? displayName,
    String? avatar,
    DateTime? lastUsed,
    List<EmojiSchema>? emojis,
  }) {
    return SavedAccountSchema(
      domain: domain ?? this.domain,
      accountId: accountId ?? this.accountId,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      avatar: avatar ?? this.avatar,
      lastUsed: lastUsed ?? this.lastUsed,
      emojis: emojis ?? this.emojis,
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
