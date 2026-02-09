// The conversation APIs for the Mastodon server.
//
// ## Conversations APIs
//
//   - [+] GET    /api/v1/conversations
//   - [+] DELETE /api/v1/conversations/:id
//   - [+] POST   /api/v1/conversations/:id/read
//
// ref:
//   - https://docs.joinmastodon.org/methods/conversations/
import 'dart:convert';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';

extension ConversationExtensions on AccessStatusSchema {
  // Fetch the list of conversations for the authenticated user.
  Future<(List<ConversationSchema>, String?)> fetchConversations({String? maxId}) async {
    checkSignedIn();

    final String endpoint = '/api/v1/conversations';
    final Map<String, String> query = {'max_id': maxId ?? ''};

    final (body, nextId) = await getAPIEx(endpoint, queryParameters: query);
    final List<dynamic> json = jsonDecode(body) as List<dynamic>;
    final List<ConversationSchema> conversations = json
        .map((e) => ConversationSchema.fromJson(e as Map<String, dynamic>))
        .toList();

    for (final c in conversations) {
      for (final a in c.accounts) {
        cacheAccount(a);
      }

      if (c.lastStatus != null) {
        saveStatusToCache(c.lastStatus!);
      }
    }

    logger.d("complete load conversations, count: ${conversations.length}");
    return (conversations, nextId);
  }

  // Delete a conversation by its ID.
  Future<void> deleteConversation(String id) async {
    checkSignedIn();

    final String endpoint = '/api/v1/conversations/$id';
    await deleteAPI(endpoint);
  }

  // Mark a conversation as read by its ID.
  Future<ConversationSchema?> markConversationAsRead(String id) async {
    checkSignedIn();

    final String endpoint = '/api/v1/conversations/$id/read';
    final String body = await postAPI(endpoint) ?? '{}';
    final Map<String, dynamic> json = jsonDecode(body) as Map<String, dynamic>;

    return ConversationSchema.fromJson(json);
  }
}

// vim: set ts=2 sw=2 sts=2 et:
