// Tests for hashtag/featured tag API extensions.
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

  group('Featured tags checkSignedIn guards', () {
    test('fetchFeaturedTags throws when not signed in', () {
      final status = MockAccessStatus.anonymous();
      expect(() => status.fetchFeaturedTags(), throwsException);
    });

    test('featureTag throws when not signed in', () {
      final status = MockAccessStatus.anonymous();
      expect(() => status.featureTag('flutter'), throwsException);
    });

    test('unfeatureTag throws when not signed in', () {
      final status = MockAccessStatus.anonymous();
      expect(() => status.unfeatureTag('ft-1'), throwsException);
    });
  });

  group('HashtagsExtensions with no domain', () {
    // getHashtag uses getAPI → returns '{}' → fromJson fails on required fields
    test('getHashtag throws when no domain (model parse error)', () {
      expect(() => noDomainAuth().getHashtag('flutter'), throwsA(anything));
    });

    // followHashtag uses postAPI → returns null → '{}' → parse may fail
    test('followHashtag throws when no domain (model parse error)', () {
      expect(() => noDomainAuth().followHashtag('flutter'), throwsA(anything));
    });

    test('unfollowHashtag throws when no domain (model parse error)', () {
      expect(() => noDomainAuth().unfollowHashtag('flutter'), throwsA(anything));
    });

    // Featured tags with no domain
    test('fetchFeaturedTags completes when no domain', () async {
      final result = await noDomainAuth().fetchFeaturedTags();
      expect(result, isEmpty);
    });

    test('unfeatureTag completes when no domain', () async {
      await noDomainAuth().unfeatureTag('ft-1');
    });
  });

  group('HashtagsExtensions with valid domain exercises HTTP call lines', () {
    // getHashtag uses getAPI which catches errors → returns null → '{}' → fromJson fails
    test('getHashtag throws on network error (model parse error)', () {
      expect(() => auth.getHashtag('flutter'), throwsA(anything));
    });

    test('fetchFeaturedTags completes with empty list on network error', () async {
      final result = await auth.fetchFeaturedTags();
      expect(result, isEmpty);
    });

    // POST/DELETE methods throw on network error
    test('followHashtag throws on network error', () {
      expect(() => auth.followHashtag('flutter'), throwsA(anything));
    });

    test('unfollowHashtag throws on network error', () {
      expect(() => auth.unfollowHashtag('flutter'), throwsA(anything));
    });

    test('featureTag throws on network error', () {
      expect(() => auth.featureTag('flutter'), throwsA(anything));
    });

    test('unfeatureTag throws on network error', () {
      expect(() => auth.unfeatureTag('ft-1'), throwsA(anything));
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
