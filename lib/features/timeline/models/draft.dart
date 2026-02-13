// The draft data schema for saving work-in-progress posts locally.
import 'dart:convert';

import 'package:glacial/features/models.dart';

// The draft data schema for saving compose state locally.
class DraftSchema {
  final String id;                    // UUID identifier for the draft.
  final String content;               // Text content of the draft.
  final String? spoiler;              // Spoiler text, if any.
  final bool sensitive;               // Whether the content is marked sensitive.
  final VisibilityType visibility;    // Post visibility level.
  final QuotePolicyType quotePolicy;  // Quote approval policy.
  final String? inReplyToId;          // ID of status being replied to.
  final String? quoteToId;            // ID of status being quoted.
  final NewPollSchema? poll;          // Poll data if composing with poll.
  final DateTime updatedAt;           // Last modified timestamp.

  // The storage key prefix for drafts, scoped per account.
  static String storageKey(String compositeKey) => 'drafts_$compositeKey';

  // Maximum number of drafts to keep per account.
  static const int maxDrafts = 20;

  const DraftSchema({
    required this.id,
    required this.content,
    this.spoiler,
    this.sensitive = false,
    this.visibility = VisibilityType.public,
    this.quotePolicy = QuotePolicyType.public,
    this.inReplyToId,
    this.quoteToId,
    this.poll,
    required this.updatedAt,
  });

  factory DraftSchema.fromJson(Map<String, dynamic> json) {
    return DraftSchema(
      id: json['id'] as String,
      content: json['content'] as String? ?? '',
      spoiler: json['spoiler'] as String?,
      sensitive: json['sensitive'] as bool? ?? false,
      visibility: VisibilityType.values.firstWhere(
        (v) => v.name == json['visibility'],
        orElse: () => VisibilityType.public,
      ),
      quotePolicy: json['quote_policy'] == null
          ? QuotePolicyType.public
          : QuotePolicyType.fromString(json['quote_policy'] as String),
      inReplyToId: json['in_reply_to_id'] as String?,
      quoteToId: json['quote_to_id'] as String?,
      poll: json['poll'] == null ? null : NewPollSchema.fromJson(json['poll'] as Map<String, dynamic>),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'content': content,
      'spoiler': spoiler,
      'sensitive': sensitive,
      'visibility': visibility.name,
      'quote_policy': quotePolicy.name,
      'in_reply_to_id': inReplyToId,
      'quote_to_id': quoteToId,
      'poll': poll?.toJson(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  DraftSchema copyWith({
    String? id,
    String? content,
    String? spoiler,
    bool? sensitive,
    VisibilityType? visibility,
    QuotePolicyType? quotePolicy,
    String? inReplyToId,
    String? quoteToId,
    NewPollSchema? poll,
    DateTime? updatedAt,
  }) {
    return DraftSchema(
      id: id ?? this.id,
      content: content ?? this.content,
      spoiler: spoiler ?? this.spoiler,
      sensitive: sensitive ?? this.sensitive,
      visibility: visibility ?? this.visibility,
      quotePolicy: quotePolicy ?? this.quotePolicy,
      inReplyToId: inReplyToId ?? this.inReplyToId,
      quoteToId: quoteToId ?? this.quoteToId,
      poll: poll ?? this.poll,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Convenience: serialize the full list of drafts to JSON string.
  static String encode(List<DraftSchema> drafts) {
    return jsonEncode(drafts.map((d) => d.toJson()).toList());
  }

  // Convenience: deserialize a JSON string to a list of drafts.
  static List<DraftSchema> decode(String json) {
    final List<dynamic> list = jsonDecode(json) as List<dynamic>;
    return list.map((e) => DraftSchema.fromJson(e as Map<String, dynamic>)).toList();
  }
}

// vim: set ts=2 sw=2 sts=2 et:
