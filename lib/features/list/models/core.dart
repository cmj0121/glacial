// The account List data schema is defined here.
import 'dart:convert';

// Which replies should be shown in the list.
enum ReplyPolicyType {
  followed, // Show replies to any followed user
  list,     // Show replies to members of the list
  none;     //  Do not show any replies
}

// Represents a list of some users that the authenticated user follows.
class ListSchema {
  final String id;                   // The ID of the list.
  final String title;                // The user-defined title of the list.
  final ReplyPolicyType replyPolicy; // Which replies should be shown in the list.
  final bool exclusive;              // Whether members of the list should be removed from the “Home” feed.

  const ListSchema({
    required this.id,
    required this.title,
    required this.replyPolicy,
    required this.exclusive,
  });

  factory ListSchema.fromString(String str) {
    final Map<String, dynamic> json = jsonDecode(str);
    return ListSchema.fromJson(json);
  }

  factory ListSchema.fromJson(Map<String, dynamic> json) {
    return ListSchema(
      id: json['id'] as String,
      title: json['title'] as String,
      replyPolicy: ReplyPolicyType.values.where((e) => e.name == json['replies_policy']).first,
      exclusive: json['exclusive'] as bool,
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
