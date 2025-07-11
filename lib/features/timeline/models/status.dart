// The Timeline Status data schema.
import 'dart:convert';

import 'package:glacial/features/models.dart';

// The timeline status data schema that is the toots from the current
// selected Mastodon server.
class StatusSchema {
  final String id;                          // ID of the status in the database.
  final String content;                     // HTML-encoded status content.
  final VisibilityType visibility;          // The visibility of the status.
  final bool sensitive;                     // Is this status marked as sensitive content?
  final String spoiler;                     // Subject or summary line, below which status content is collapsed.
  final AccountSchema account;              // The account that authored this status.
  final String uri;                         // URI of the status used for federation.
  final String? url;                        // A link to the status's HTML representation.
  final List<AttachmentSchema> attachments; // Media that is attached to this status.
  final List<MentionSchema> mentions;       // Mentions of users within the status content.
  final List<TagSchema> tags;               // Hashtags used within the status content.
  final List<EmojiSchema> emojis;           // Custom emoji to be used when rendering status content.
  final String? inReplyToID;                // The ID of the status this status is replying to.
  final String? inReplyToAccountID;         // The ID of the account this status is replying to.
  final StatusSchema? reblog;               // The status being reblogged.
  final PollSchema? poll;                   // The poll attached to the status.
  final int reblogsCount;                   // How many boosts this status has received.
  final int favouritesCount;                // How many favourites this status has received.
  final int repliesCount;                   // How many replies this status has received.
  final bool? favourited;                   // Have you favourited this status?
  final bool? reblogged;                    // Have you reblogged this status?
  final bool? muted;                        // Have you muted this status?
  final bool? bookmarked;                   // Have you bookmarked this status?
  final bool? pinned;                       // Have you pinned this status?
  final ApplicationSchema? application;     // The application used to post the status.
  final DateTime createdAt;                 // The date when this status was created.
  final DateTime? editedAt;                 // Timestamp of when the status was last edited.
  final DateTime? scheduledAt;              // Timestamp of when the status is scheduled to be posted.

  const StatusSchema({
    required this.id,
    required this.content,
    required this.visibility,
    required this.sensitive,
    required this.spoiler,
    required this.account,
    required this.uri,
    this.url,
    this.attachments = const [],
    this.mentions = const [],
    this.tags = const [],
    this.emojis = const [],
    this.inReplyToID,
    this.inReplyToAccountID,
    this.reblog,
    this.poll,
    required this.reblogsCount,
    required this.favouritesCount,
    required this.repliesCount,
    this.favourited,
    this.reblogged,
    this.muted,
    this.bookmarked,
    this.pinned,
    this.application,
    required this.createdAt,
    this.editedAt,
    this.scheduledAt,
  });

  factory StatusSchema.fromString(String str) {
    final Map<String, dynamic> json = jsonDecode(str);
    return StatusSchema.fromJson(json);
  }

  factory StatusSchema.fromJson(Map<String, dynamic> json) {
    return StatusSchema(
      id: json['id'] as String,
      content: json['content'] as String,
      visibility: VisibilityType.fromString(json['visibility'] as String),
      sensitive: json['sensitive'] as bool,
      spoiler: json['spoiler_text'] as String,
      account: AccountSchema.fromJson(json['account'] as Map<String, dynamic>),
      uri: json['uri'] as String,
      url: json['url'] as String?,
      attachments: (json['media_attachments'] as List<dynamic>)
        .map((e) => AttachmentSchema.fromJson(e as Map<String, dynamic>))
        .toList(),
      mentions: (json['mentions'] as List<dynamic>)
        .map((e) => MentionSchema.fromJson(e as Map<String, dynamic>))
        .toList(),
      tags: (json['tags'] as List<dynamic>)
        .map((e) => TagSchema.fromJson(e as Map<String, dynamic>))
        .toList(),
      emojis: (json['emojis'] as List<dynamic>)
        .map((e) => EmojiSchema.fromJson(e as Map<String, dynamic>))
        .toList(),
      inReplyToID: json['in_reply_to_id'] as String?,
      inReplyToAccountID: json['in_reply_to_account_id'] as String?,
      reblog: json['reblog'] == null ? null : StatusSchema.fromJson(json['reblog'] as Map<String, dynamic>),
      poll: json['poll'] == null ? null : PollSchema.fromJson(json['poll'] as Map<String, dynamic>),
      reblogsCount: json['reblogs_count'] as int,
      favouritesCount: json['favourites_count'] as int,
      repliesCount: json['replies_count'] as int,
      favourited: json['favourited'] as bool?,
      reblogged: json['reblogged'] as bool?,
      muted: json['muted'] as bool?,
      bookmarked: json['bookmarked'] as bool?,
      pinned: json['pinned'] as bool?,
      application: json['application'] == null ? null : ApplicationSchema.fromJson(json['application'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['created_at'] as String),
      editedAt: json['edited_at'] == null ? null : DateTime.parse(json['edited_at'] as String),
    );
  }

  factory StatusSchema.fromScheduleJson(Map<String, dynamic> json, AccountSchema account) {
    final Map<String, dynamic> params = json['params'] as Map<String, dynamic>;

    return StatusSchema(
      id: json['id'] as String,
      content: params['text'] as String,
      visibility: VisibilityType.fromString(params['visibility'] as String),
      sensitive: params['sensitive'] as bool,
      spoiler: params['spoiler_text'] as String? ?? '',
      account: account,
      uri: params['uri'] as String? ?? '',
      url: params['url'] as String?,
      attachments: (json['media_attachments'] as List<dynamic>)
        .map((e) => AttachmentSchema.fromJson(e as Map<String, dynamic>))
        .toList(),
      mentions: (params['mentions'] as List<dynamic>? ?? [])
        .map((e) => MentionSchema.fromJson(e as Map<String, dynamic>))
        .toList(),
      tags: (params['tags'] as List<dynamic>? ?? [])
        .map((e) => TagSchema.fromJson(e as Map<String, dynamic>))
        .toList(),
      emojis: (params['emojis'] as List<dynamic>? ?? [])
        .map((e) => EmojiSchema.fromJson(e as Map<String, dynamic>))
        .toList(),
      inReplyToID: (params['in_reply_to_id'] as int?)?.toString(),
      inReplyToAccountID: params['in_reply_to_account_id'] as String?,
      reblog: params['reblog'] == null ? null : StatusSchema.fromJson(params['reblog'] as Map<String, dynamic>),
      poll: params['poll'] == null ? null : PollSchema.fromJson(params['poll'] as Map<String, dynamic>),
      reblogsCount: params['reblogs_count'] as int? ?? 0,
      favouritesCount: params['favourites_count'] as int? ?? 0,
      repliesCount: params['replies_count'] as int? ?? 0,
      favourited: params['favourited'] as bool?,
      reblogged: params['reblogged'] as bool?,
      muted: params['muted'] as bool?,
      bookmarked: params['bookmarked'] as bool?,
      pinned: params['pinned'] as bool?,
      application: params['application'] == null ? null : ApplicationSchema.fromJson(params['application'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['scheduled_at'] as String),
      scheduledAt: DateTime.parse(json['scheduled_at'] as String),
      editedAt: null,
    );
  }
}

// The new status data schema.
class NewStatusSchema {
  final String? status;            // The text content of the status. If media_ids is provided, this becomes optional.
  final List<String> mediaIDs;     // Attachment IDs to be attached as media. If provided, status becomes optional, and poll cannot be used.
  final NewPollSchema? poll;          // Poll options to be attached to the status. If provided, media_ids cannot be used.
  final bool sensitive;            // Mark status and attached media as sensitive? Defaults to false.
  final String? spoiler;           // Text to show when the status is marked as sensitive.
  final VisibilityType visibility; // The visibility of the status. Defaults to public.
  final String? inReplyToID;       // ID of the status being replied to, if status is a reply.
  final DateTime? scheduledAt;    // The time when the status should be scheduled to be posted.

  const NewStatusSchema({
    required this.status,
    required this.mediaIDs,
    this.poll,
    this.sensitive = false,
    this.spoiler,
    this.visibility = VisibilityType.public,
    this.inReplyToID,
    this.scheduledAt,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'status': status,
      'media_ids': mediaIDs,
      'poll': poll?.toJson(),
      'sensitive': sensitive,
      'spoiler_text': spoiler,
      'visibility': visibility.name,
      'in_reply_to_id': inReplyToID,
      'scheduled_at': scheduledAt?.toIso8601String(),
    };

    // only return the non-null values
    return json
      ..removeWhere((key, value) => value == null)
      ..removeWhere((key, value) => value is String && value.isEmpty);
  }

  NewStatusSchema copyWith({
    String? status,
    List<String>? mediaIDs,
    NewPollSchema? poll,
    bool? sensitive,
    String? spoiler,
    VisibilityType? visibility,
    String? inReplyToID,
  }) {
    return NewStatusSchema(
      status: status ?? this.status,
      mediaIDs: mediaIDs ?? this.mediaIDs,
      poll: poll ?? this.poll,
      sensitive: sensitive ?? this.sensitive,
      spoiler: spoiler ?? this.spoiler,
      visibility: visibility ?? this.visibility,
      inReplyToID: inReplyToID ?? this.inReplyToID,
    );
  }
}

// Represents the tree around a given status. Used for reconstructing threads of statuses.
class StatusContextSchema {
  final List<StatusSchema> ancestors;
  final List<StatusSchema> descendants;

  const StatusContextSchema({
    required this.ancestors,
    required this.descendants,
  });

  factory StatusContextSchema.fromJson(Map<String, dynamic> json) {
    return StatusContextSchema(
      ancestors: (json['ancestors'] as List<dynamic>)
        .map((e) => StatusSchema.fromJson(e as Map<String, dynamic>))
        .toList(),
      descendants: (json['descendants'] as List<dynamic>)
        .map((e) => StatusSchema.fromJson(e as Map<String, dynamic>))
        .toList(),
    );
  }
}

// The hashtags used within the status content.
class TagSchema {
  final String name;
  final String url;

  const TagSchema({
    required this.name,
    required this.url,
  });

  factory TagSchema.fromJson(Map<String, dynamic> json) {
    return TagSchema(
      name: json['name'] as String,
      url: json['url'] as String,
    );
  }
}

// The mentions of users within the status content
class MentionSchema {
  final String id;                  // The ID of the account mentioned.
  final String username;            // The username of the account mentioned.
  final String url;                 // The URL of the account mentioned.
  final String acct;                // The webfinger acct: URI of the mentioned user.

  const MentionSchema({
    required this.id,
    required this.username,
    required this.url,
    required this.acct,
  });

  factory MentionSchema.fromJson(Map<String, dynamic> json) {
    return MentionSchema(
      id: json['id'] as String,
      username: json['username'] as String,
      url: json['url'] as String,
      acct: json['acct'] as String,
    );
  }
}

// The poll data schema.
class PollSchema {
  final String id;                      // The ID of the poll in the database.
  final DateTime? expiresAt;            // When the poll ends.
  final bool expired;                   // Is the poll expired?
  final bool multiple;                  // Does the poll allow multiple-choice answers?
  final int votesCount;                 // How many votes have been received.
  final int? votersCount;               // How many unique users have voted in the poll (null if not available).
  final List<PollOptionSchema> options; // The options available in the poll.
  final List<EmojiSchema> emojis;       // Custom emoji to be used for rendering poll options.
  final bool? voted;                    // When called with a user token, has the authorized user voted?
  final List<int>? ownVotes;            // The list of the user's votes in the poll, if they have voted.

  const PollSchema({
    required this.id,
    this.expiresAt,
    required this.expired,
    required this.multiple,
    required this.votesCount,
    this.votersCount,
    required this.options,
    required this.emojis,
    this.voted,
    this.ownVotes,
  });

  factory PollSchema.fromJson(Map<String, dynamic> json) {
    return PollSchema(
      id: json['id'] as String,
      expiresAt: json['expires_at'] == null ? null : DateTime.parse(json['expires_at'] as String),
      expired: json['expired'] as bool,
      multiple: json['multiple'] as bool,
      votesCount: json['votes_count'] as int,
      votersCount: json['voters_count'] as int?,
      options: (json['options'] as List<dynamic>)
        .map((e) => PollOptionSchema.fromJson(e as Map<String, dynamic>))
        .toList(),
      emojis: (json['emojis'] as List<dynamic>)
        .map((e) => EmojiSchema.fromJson(e as Map<String, dynamic>))
        .toList(),
      voted: json['voted'] as bool?,
      ownVotes: (json['own_votes'] as List<dynamic>?)
        ?.map((e) => e as int)
        .toList(),
    );
  }
}

// The poll option data schema.
class PollOptionSchema {
  final String title;   // The text value of the poll option.
  final int? votesCount; // The total number of received votes for this option.

  const PollOptionSchema({
    required this.title,
    this.votesCount,
  });

  factory PollOptionSchema.fromJson(Map<String, dynamic> json) {
    return PollOptionSchema(
      title: json['title'] as String,
      votesCount: json['votes_count'] as int?,
    );
  }
}

// The options of the Poll in the status for create a new poll.
class NewPollSchema {
  final bool? hideTotals;     // Hide vote counts until the poll ends? Defaults to false.
  final bool? multiple;       // Allow multiple choices? Defaults to false.
  final int expiresIn;        // The duration in seconds until the poll expires. Defaults to 86400 seconds (1 day).
  final List<String> options; // Possible answers to the poll.

  const NewPollSchema({
    this.hideTotals,
    this.multiple,
    this.expiresIn = 86400,
    required this.options,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'hide_totals': hideTotals,
      'multiple': multiple,
      'options': options,
      'expires_in': expiresIn,
    };

    // only return the non-null values
    return json..removeWhere((key, value) => value == null);
  }

  NewPollSchema copyWith({
    bool? hideTotals,
    bool? multiple,
    int? expiresIn,
    List<String>? options,
  }) {
    return NewPollSchema(
      hideTotals: hideTotals ?? this.hideTotals,
      multiple: multiple ?? this.multiple,
      expiresIn: expiresIn ?? this.expiresIn,
      options: options ?? this.options,
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
