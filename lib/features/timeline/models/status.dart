// The Timeline Status data schema.
import 'dart:convert';

import 'package:glacial/features/models.dart';

// The timeline status data schema that is the toots from the current selected Mastodon server.
class StatusSchema {
  final String id;                          // ID of the status in the database.
  final String content;                     // HTML-encoded status content.
  final String? text;                       // Plain-text source of a status, if available.
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
  final PreviewCardSchema? card;            // Preview card for links included within status content.
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
    this.text,
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
    this.card,
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
      content: json['content'] as String? ?? '',
      text: json['text'] as String?,
      visibility: VisibilityType.values.where((e) => e.name == json["visibility"]).first,
      sensitive: json['sensitive'] as bool,
      spoiler: json['spoiler_text'] as String,
      account: AccountSchema.fromJson(json['account'] as Map<String, dynamic>),
      uri: json['uri'] as String,
      url: json['url'] as String?,
      attachments: (json['media_attachments'] as List<dynamic>?)
        ?.map((e) => AttachmentSchema.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      mentions: (json['mentions'] as List<dynamic>?)
        ?.map((e) => MentionSchema.fromJson(e as Map<String, dynamic>))
        .toList() ?? [],
      tags: (json['tags'] as List<dynamic>?)
        ?.map((e) => TagSchema.fromJson(e as Map<String, dynamic>))
        .toList() ?? [],
      emojis: (json['emojis'] as List<dynamic>?)
        ?.map((e) => EmojiSchema.fromJson(e as Map<String, dynamic>))
        .toList() ?? [],
      inReplyToID: json['in_reply_to_id'] as String?,
      inReplyToAccountID: json['in_reply_to_account_id'] as String?,
      reblog: json['reblog'] == null ? null : StatusSchema.fromJson(json['reblog'] as Map<String, dynamic>),
      poll: json['poll'] == null ? null : PollSchema.fromJson(json['poll'] as Map<String, dynamic>),
      card: json['card'] == null ? null : PreviewCardSchema.fromJson(json['card'] as Map<String, dynamic>),
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
      visibility: VisibilityType.values.where((e) => e.name == params["visibility"]).first,
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

  // Return the plain text content of the status.
  String get plainText {
    if (text != null && text!.isNotEmpty) {
      return text!;
    }

    return content
        .replaceAll(RegExp(r'<[^>]*>'), '') // Remove HTML tags
        .replaceAll(RegExp(r'&[a-z]+;'), ''); // Remove HTML entities
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

  factory StatusContextSchema.fromString(String str) {
    final Map<String, dynamic> json = jsonDecode(str);
    return StatusContextSchema.fromJson(json);
  }

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

// Represents a revision of a status that has been edited.
class StatusEditSchema {
  final String content;                     // The content of the status at this revision.
  final String spoiler;                     // The content of the subject or content warning at this revision.
  final bool sensitive;                     // Whether the status was marked as sensitive at this revision.
  final DateTime createdAt;                 // The date when this revision was created.
  final AccountSchema account;              // The account that created this revision.
  final PollSchema? poll;                   // The poll attached to the status at this revision.
  final List<AttachmentSchema> attachments; // Media that was attached to the status at this revision.
  final List<EmojiSchema> emojis;           // Custom emoji used in the status at this revision.

  const StatusEditSchema({
    required this.content,
    required this.spoiler,
    required this.sensitive,
    required this.createdAt,
    required this.account,
    this.poll,
    this.attachments = const [],
    this.emojis = const [],
  });

  factory StatusEditSchema.fromString(String str) {
    final Map<String, dynamic> json = jsonDecode(str);
    return StatusEditSchema.fromJson(json);
  }

  factory StatusEditSchema.fromJson(Map<String, dynamic> json) {
    return StatusEditSchema(
      content: json['content'] as String? ?? '',
      spoiler: json['spoiler_text'] as String,
      sensitive: json['sensitive'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      account: AccountSchema.fromJson(json['account'] as Map<String, dynamic>),
      poll: json['poll'] == null ? null : PollSchema.fromJson(json['poll'] as Map<String, dynamic>),
      attachments: (json['media_attachments'] as List<dynamic>?)
        ?.map((e) => AttachmentSchema.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      emojis: (json['emojis'] as List<dynamic>?)
        ?.map((e) => EmojiSchema.fromJson(e as Map<String, dynamic>))
        .toList() ?? [],
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

// The type of the preview card.
enum PreviewCardType {
  link,   // Link OEmbed.
  photo,  // Photo OEmbed.
  video,  // Video OEmbed.
  rich;   // iframe OEmbed.
}

// Represents a rich preview card that is generated using OpenGraph tags from a URL.
class PreviewCardSchema {
  final String url;           // Location of linked resource.
  final String title;         // Title of linked resource.
  final String description;   // Description of preview.
  final PreviewCardType type; // The type of the preview card.
  final String html;          // HTML to be used for generating the preview card.
  final int width;            // Width of preview, in pixels.
  final int height;           // Height of preview, in pixels.
  final String? image;        // Preview thumbnail.

  const PreviewCardSchema({
    required this.url,
    required this.title,
    required this.description,
    required this.type,
    required this.html,
    required this.width,
    required this.height,
    this.image,
  });

  factory PreviewCardSchema.fromJson(Map<String, dynamic> json) {
    return PreviewCardSchema(
      url: json['url'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: PreviewCardType.values.where((e) => e.name == json["type"]).first,
      html: json['html'] as String,
      width: json['width'] as int,
      height: json['height'] as int,
      image: json['image'] as String?,
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
