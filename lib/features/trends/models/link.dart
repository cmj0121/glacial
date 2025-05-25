// The trends records of the links.
import 'package:glacial/features/trends/models/core.dart';

// The trends of the links that have been shared more than others.
class LinkSchema {
  final String url;
  final String title;
  final String desc;
  final String type;
  final String authName;
  final String authUrl;
  final String providerName;
  final String providerUrl;
  final String html;
  final int width;
  final int height;
  final String image;
  final String embedUrl;
  final List<HistorySchema> history;

  const LinkSchema({
    required this.url,
    required this.title,
    required this.desc,
    required this.type,
    required this.authName,
    required this.authUrl,
    required this.providerName,
    required this.providerUrl,
    required this.html,
    required this.width,
    required this.height,
    required this.image,
    required this.embedUrl,
    required this.history,
  });

  factory LinkSchema.fromJson(Map<String, dynamic> json) {
    return LinkSchema(
      url: json['url'] as String,
      title: json['title'] as String,
      desc: json['description'] as String,
      type: json['type'] as String,
      authName: json['author_name'] as String,
      authUrl: json['author_url'] as String,
      providerName: json['provider_name'] as String,
      providerUrl: json['provider_url'] as String,
      html: json['html'] as String,
      width: json['width'] as int,
      height: json['height'] as int,
      image: json['image'] as String,
      embedUrl: json['embed_url'] as String,
      history: (json['history'] as List<dynamic>).map((e) => HistorySchema.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
