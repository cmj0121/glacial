// The Conversation related data schema.
import 'dart:convert';

import 'package:glacial/features/models.dart';

// Represents a conversation with a direct message thread.
class ConversationSchema {
  final String id;                    // The ID of the conversation in the database.
  final List<AccountSchema> accounts; // Participants in this conversation.
  final StatusSchema? lastStatus;     // The last status in this conversation.
  final bool unread;                  // Whether the conversation has unread messages.

  const ConversationSchema({
    required this.id,
    required this.accounts,
    this.lastStatus,
    required this.unread,
  });

  factory ConversationSchema.fromJson(Map<String, dynamic> json) {
    return ConversationSchema(
      id: json['id'] as String,
      accounts: (json['accounts'] as List<dynamic>)
          .map((e) => AccountSchema.fromJson(e as Map<String, dynamic>))
          .toList(),
      lastStatus: json['last_status'] == null
          ? null
          : StatusSchema.fromJson(json['last_status'] as Map<String, dynamic>),
      unread: json['unread'] as bool? ?? false,
    );
  }

  factory ConversationSchema.fromString(String str) {
    final Map<String, dynamic> json = jsonDecode(str);
    return ConversationSchema.fromJson(json);
  }
}

// vim: set ts=2 sw=2 sts=2 et:
