// View and interact with server announcements.
//
// ## Announcements APIs
//
//   - [+] GET    /api/v1/announcements
//   - [+] POST   /api/v1/announcements/:id/dismiss
//   - [+] PUT    /api/v1/announcements/:id/reactions/:name
//   - [+] DELETE /api/v1/announcements/:id/reactions/:name
//
// ref:
//   - https://docs.joinmastodon.org/methods/announcements/
import 'dart:convert';

import 'package:glacial/features/models.dart';

extension AnnouncementsExtensions on AccessStatusSchema {
  // Fetch all current announcements.
  Future<List<AnnouncementSchema>> fetchAnnouncements() async {
    final String body = await getAPI('/api/v1/announcements') ?? '[]';
    final List<dynamic> json = jsonDecode(body) as List<dynamic>;

    return json.map((e) => AnnouncementSchema.fromJson(e as Map<String, dynamic>)).toList();
  }

  // Dismiss an announcement (mark as read).
  Future<void> dismissAnnouncement(String id) async {
    checkSignedIn();

    await postAPI('/api/v1/announcements/$id/dismiss');
  }

  // Add a reaction to an announcement.
  Future<void> addAnnouncementReaction(String id, String name) async {
    checkSignedIn();

    await putAPI('/api/v1/announcements/$id/reactions/$name');
  }

  // Remove a reaction from an announcement.
  Future<void> removeAnnouncementReaction(String id, String name) async {
    checkSignedIn();

    await deleteAPI('/api/v1/announcements/$id/reactions/$name');
  }
}

// vim: set ts=2 sw=2 sts=2 et:
