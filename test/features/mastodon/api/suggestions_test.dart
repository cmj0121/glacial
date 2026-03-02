// Tests for suggestions API extensions.
import 'package:flutter_test/flutter_test.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/mastodon/extensions.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  AccessStatusSchema noDomainAuth() =>
      const AccessStatusSchema(domain: '', accessToken: 'token');

  const auth = AccessStatusSchema(
    domain: 'nonexistent-server-12345.invalid',
    accessToken: 'test-token',
  );

  group('SuggestionsExtensions checkSignedIn guards', () {
    test('fetchSuggestion throws when not signed in', () {
      final status = MockAccessStatus.anonymous();
      expect(() => status.fetchSuggestion(), throwsException);
    });

    test('removeSuggestion throws when not signed in', () {
      final status = MockAccessStatus.anonymous();
      expect(() => status.removeSuggestion('acc-1'), throwsException);
    });
  });

  group('SuggestionsExtensions with no domain', () {
    test('fetchSuggestion completes when no domain', () async {
      final result = await noDomainAuth().fetchSuggestion();
      expect(result, isEmpty);
    });

    test('removeSuggestion completes when no domain', () async {
      await noDomainAuth().removeSuggestion('acc-1');
    });
  });

  group('SuggestionsExtensions with valid domain exercises HTTP call lines', () {
    test('fetchSuggestion returns empty on network error', () async {
      final result = await auth.fetchSuggestion(limit: 10);
      expect(result, isEmpty);
    });

    test('removeSuggestion throws on network error', () {
      expect(() => auth.removeSuggestion('acc-1'), throwsA(anything));
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
