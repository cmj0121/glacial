// The media attachmen data schema

// The type of the media attachment
enum MediaType {
  image,
  video,
  audio,
  gifv,
  unknown,
}

// The media attachement of the status in Mastodon server
class AttachmentSchema {
  final String id;
  final MediaType type;
  final String url;
  final String? previewUrl;
  final String? remoteUrl;
  final String? description;
  final String? blurhash;

  AttachmentSchema({
    required this.id,
    required this.type,
    required this.url,
    this.previewUrl,
    this.remoteUrl,
    this.description,
    this.blurhash,
  });

  factory AttachmentSchema.fromJson(Map<String, dynamic> json) {
    return AttachmentSchema(
      id: json["id"] as String,
      type: MediaType.values.firstWhere((e) => e.name == json["type"]),
      url: json["url"] as String? ?? '',
      previewUrl: json["preview_url"] as String?,
      remoteUrl: json["remote_url"] as String?,
      description: json["description"] as String?,
      blurhash: json["blurhash"] as String?,
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
