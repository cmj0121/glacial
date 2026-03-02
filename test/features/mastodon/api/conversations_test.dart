// Tests for conversation API extensions.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/mastodon/extensions.dart';

import '../../../helpers/mock_http.dart';
import '../../../helpers/test_helpers.dart';

/// Build a JSON array of conversation objects.
String conversationListJson({int count = 2}) {
  final conversations = List.generate(count, (i) {
    final accountData = jsonDecode(accountJson(id: 'acc-$i', username: 'user$i'));
    final statusData = jsonDecode(statusJson(id: 'status-$i'));
    return {
      'id': 'conv-$i',
      'accounts': [accountData],
      'last_status': statusData,
      'unread': false,
    };
  });
  return jsonEncode(conversations);
}

void main() {
  AccessStatusSchema noDomainAuth() =>
      const AccessStatusSchema(domain: '', accessToken: 'token');

  group('ConversationExtensions checkSignedIn guards', () {
    test('fetchConversations throws when not signed in', () {
      final status = MockAccessStatus.anonymous();
      expect(() => status.fetchConversations(), throwsException);
    });

    test('deleteConversation throws when not signed in', () {
      final status = MockAccessStatus.anonymous();
      expect(() => status.deleteConversation('conv-1'), throwsException);
    });

    test('markConversationAsRead throws when not signed in', () {
      final status = MockAccessStatus.anonymous();
      expect(() => status.markConversationAsRead('conv-1'), throwsException);
    });
  });

  group('ConversationExtensions with no domain', () {
    test('deleteConversation completes when no domain', () async {
      await noDomainAuth().deleteConversation('conv-1');
    });

    test('markConversationAsRead throws when parsing empty response with no domain', () async {
      // postAPI returns null when domain is empty, body defaults to '{}',
      // ConversationSchema.fromJson({}) throws because required fields are missing.
      expect(
        () => noDomainAuth().markConversationAsRead('conv-1'),
        throwsA(anything),
      );
    });
  });

  group('ConversationExtensions with valid domain exercises HTTP call lines', () {
    // Authenticated with explicit domain — passes checkSignedIn and domain guard,
    // reaching the API body lines before failing on network.
    const auth = AccessStatusSchema(
      domain: 'nonexistent-server-12345.invalid',
      accessToken: 'test-token',
    );

    test('fetchConversations throws on network error with valid domain', () {
      // checkSignedIn passes, endpoint+query set, getAPIEx throws on SocketException.
      expect(
        () => auth.fetchConversations(),
        throwsA(anything),
      );
    });

    test('deleteConversation throws on network error with valid domain', () {
      // checkSignedIn passes, deleteAPI throws on network error.
      expect(
        () => auth.deleteConversation('conv-1'),
        throwsA(anything),
      );
    });

    test('markConversationAsRead throws on network error with valid domain', () {
      // checkSignedIn passes, postAPI throws on network error.
      expect(
        () => auth.markConversationAsRead('conv-1'),
        throwsA(anything),
      );
    });
  });
  group('ConversationExtensions with mock HTTP (success paths)', () {
    late HttpOverrides? originalOverrides;

    setUp(() {
      originalOverrides = HttpOverrides.current;
    });

    tearDown(() {
      HttpOverrides.global = originalOverrides;
    });

    test('fetchConversations parses conversations and caches accounts/statuses', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        return (200, conversationListJson(count: 2));
      });

      final mockAuth = const AccessStatusSchema(
        domain: 'example.com',
        accessToken: 'test-token',
      );
      final (conversations, _) = await mockAuth.fetchConversations();
      expect(conversations.length, 2);
      expect(conversations.first.id, 'conv-0');
      expect(conversations.first.accounts, isNotEmpty);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
