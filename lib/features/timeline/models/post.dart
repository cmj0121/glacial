// The Post Timeline Status data schema.
import 'package:glacial/features/models.dart';

// The new status data schema to toot new status to the Mastodon server.
class PostStatusSchema {
  final String? status;            // The text content of the status. If media_ids is provided, this becomes optional.
  final List<String> mediaIDs;     // Attachment IDs to be attached as media. If provided, status becomes optional, and poll cannot be used.
  final NewPollSchema? poll;          // Poll options to be attached to the status. If provided, media_ids cannot be used.
  final bool sensitive;            // Mark status and attached media as sensitive? Defaults to false.
  final String? spoiler;           // Text to show when the status is marked as sensitive.
  final VisibilityType visibility; // The visibility of the status. Defaults to public.
  final String? inReplyToID;       // ID of the status being replied to, if status is a reply.
  final DateTime? scheduledAt;    // The time when the status should be scheduled to be posted.

  const PostStatusSchema({
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

  PostStatusSchema copyWith({
    String? status,
    List<String>? mediaIDs,
    NewPollSchema? poll,
    bool? sensitive,
    String? spoiler,
    VisibilityType? visibility,
    String? inReplyToID,
  }) {
    return PostStatusSchema(
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

// vim: set ts=2 sw=2 sts=2 et:
