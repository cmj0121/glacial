// The Media APIs for the mastdon server.
//
// ## Media APIs
//
//   - [-] POST   /api/v1/media        (deprecated in 3.1.3)
//   - [+] GET    /api/v1/media/:id
//   - [+] DELETE /api/v1/media/:id
//   - [+] PUT    /api/v1/media/:id
//   - [+] POST   /api/v2/media
//
// ## Custom Emoji APIs
//
//  - [+] GET    /api/v1/custom_emojis
//
// ref:
//  - https://docs.joinmastodon.org/methods/media/
//  - https://docs.joinmastodon.org/methods/custom_emojis/
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' as http_parser;
import 'package:mime/mime.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';

extension MediaExtensions on AccessStatusSchema {
  // Upload media to the Mastodon server, return the media self
  Future<AttachmentSchema> uploadMedia(String filepath) async {
    checkSignedIn();

    final Uri uri = UriEx.handle(domain!, "/api/v2/media");
    final Map<String, String> headers = {
      "User-Agent": userAgent,
      "Authorization": "Bearer $accessToken",
      "Content-Type": "multipart/form-data",
    };

    final String mime = lookupMimeType(filepath) ?? "application/octet-stream";
    final http.MultipartFile multipartFile = await http.MultipartFile.fromPath(
      'file',
      filepath,
      contentType: http_parser.MediaType.parse(mime),
    );

    final http.MultipartRequest request = http.MultipartRequest('POST', uri)
      ..headers.addAll(headers)
      ..files.add(multipartFile);
    final response = await request.send();
    final body = await response.stream.bytesToString();
    final Map<String, dynamic> json = jsonDecode(body) as Map<String, dynamic>;

    return AttachmentSchema.fromJson(json);
  }

  // Returns custom emojis that are available on the server.
  Future<List<EmojiSchema>> fetchCustomEmojis() async {
    final String endpoint = '/api/v1/custom_emojis';
    final String body = await getAPI(endpoint) ?? '[]';
    final List<dynamic> json = jsonDecode(body) as List<dynamic>;

    return json.map((e) => EmojiSchema.fromJson(e as Map<String, dynamic>)).toList();
  }

  // Get a media attachment by its ID.
  Future<AttachmentSchema?> getMedia({required String id}) async {
    checkSignedIn();

    final String endpoint = '/api/v1/media/$id';
    final String? body = await getAPI(endpoint);
    if (body == null) return null;

    final Map<String, dynamic> json = jsonDecode(body) as Map<String, dynamic>;
    return AttachmentSchema.fromJson(json);
  }

  // Update a media attachment's parameters (description and focus point).
  Future<AttachmentSchema> updateMedia({
    required String id,
    String? description,
    String? focus,
  }) async {
    checkSignedIn();

    final String endpoint = '/api/v1/media/$id';
    final Map<String, dynamic> body = {
      if (description != null) 'description': description,
      if (focus != null) 'focus': focus,
    };

    final String response = await putAPI(endpoint, body: body) ?? '{}';
    final Map<String, dynamic> json = jsonDecode(response) as Map<String, dynamic>;
    return AttachmentSchema.fromJson(json);
  }

  // Delete a media attachment that has not yet been attached to a status.
  Future<void> deleteMedia({required String id}) async {
    checkSignedIn();

    final String endpoint = '/api/v1/media/$id';
    await deleteAPI(endpoint);
  }
}

// vim: set ts=2 sw=2 sts=2 et:
