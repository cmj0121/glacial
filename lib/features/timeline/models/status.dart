// The Timeline Status data schema.
import 'dart:convert';

// The timeline status data schema that is the toots from the current
// selected Mastodon server.
class StatusSchema {
  final String id;                          // ID of the status in the database.
  final String content;                     // HTML-encoded status content.
  final bool sensitive;                     // Is this status marked as sensitive content?
  final String spoiler;                     // Subject or summary line, below which status content is collapsed.
  final String uri;                         // URI of the status used for federation.
  final String? url;                        // A link to the status's HTML representation.
  final String? inReplyToID;                // The ID of the status this status is replying to.
  final String? inReplyToAccountID;         // The ID of the account this status is replying to.
  final StatusSchema? reblog;               // The status being reblogged.
  final int reblogsCount;                   // How many boosts this status has received.
  final int favouritesCount;                // How many favourites this status has received.
  final int repliesCount;                   // How many replies this status has received.
  final bool? favourited;                   // Have you favourited this status?
  final bool? reblogged;                    // Have you reblogged this status?
  final bool? muted;                        // Have you muted this status?
  final bool? bookmarked;                   // Have you bookmarked this status?
  final bool? pinned;                       // Have you pinned this status?
  final DateTime createdAt;                 // The date when this status was created.
  final DateTime? editedAt;                 // Timestamp of when the status was last edited.

  const StatusSchema({
    required this.id,
    required this.content,
    required this.sensitive,
    required this.spoiler,
    required this.uri,
    this.url,
    this.inReplyToID,
    this.inReplyToAccountID,
    this.reblog,
    required this.reblogsCount,
    required this.favouritesCount,
    required this.repliesCount,
    this.favourited,
    this.reblogged,
    this.muted,
    this.bookmarked,
    this.pinned,
    required this.createdAt,
    this.editedAt,
  });

  factory StatusSchema.fromString(String str) {
    final Map<String, dynamic> json = jsonDecode(str);
    return StatusSchema.fromJson(json);
  }

  factory StatusSchema.fromJson(Map<String, dynamic> json) {
    return StatusSchema(
      id: json['id'] as String,
      content: json['content'] as String,
      sensitive: json['sensitive'] as bool,
      spoiler: json['spoiler_text'] as String,
      uri: json['uri'] as String,
      url: json['url'] as String?,
      inReplyToID: json['in_reply_to_id'] as String?,
      inReplyToAccountID: json['in_reply_to_account_id'] as String?,
      reblog: json['reblog'] == null ? null : StatusSchema.fromJson(json['reblog'] as Map<String, dynamic>),
      reblogsCount: json['reblogs_count'] as int,
      favouritesCount: json['favourites_count'] as int,
      repliesCount: json['replies_count'] as int,
      favourited: json['favourited'] as bool?,
      reblogged: json['reblogged'] as bool?,
      muted: json['muted'] as bool?,
      bookmarked: json['bookmarked'] as bool?,
      pinned: json['pinned'] as bool?,
      createdAt: DateTime.parse(json['created_at'] as String),
      editedAt: json['edited_at'] == null ? null : DateTime.parse(json['edited_at'] as String),
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
