// Tests for conversation API extensions.
import 'package:flutter_test/flutter_test.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/mastodon/extensions.dart';

import '../../../helpers/test_helpers.dart';

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
}

// vim: set ts=2 sw=2 sts=2 et:
