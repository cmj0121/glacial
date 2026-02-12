// Tests for TimelineType enum and isAccessible() method.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/features/mastodon/models/config.dart';
import 'package:glacial/features/timeline/models/timeline.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  setUpAll(() => setupTestEnvironment());

  group('TimelineType basic properties', () {
    test('has 11 values', () {
      expect(TimelineType.values.length, 11);
    });

    test('inTimelineTab returns true for main types', () {
      expect(TimelineType.home.inTimelineTab, true);
      expect(TimelineType.local.inTimelineTab, true);
      expect(TimelineType.federal.inTimelineTab, true);
      expect(TimelineType.public.inTimelineTab, true);
      expect(TimelineType.favourites.inTimelineTab, true);
      expect(TimelineType.bookmarks.inTimelineTab, true);
    });

    test('inTimelineTab returns false for extra types', () {
      expect(TimelineType.list.inTimelineTab, false);
      expect(TimelineType.user.inTimelineTab, false);
      expect(TimelineType.pin.inTimelineTab, false);
      expect(TimelineType.schedule.inTimelineTab, false);
      expect(TimelineType.hashtag.inTimelineTab, false);
    });

    test('supportAnonymous returns true for public types', () {
      expect(TimelineType.local.supportAnonymous, true);
      expect(TimelineType.federal.supportAnonymous, true);
      expect(TimelineType.public.supportAnonymous, true);
    });

    test('supportAnonymous returns false for private types', () {
      expect(TimelineType.home.supportAnonymous, false);
      expect(TimelineType.favourites.supportAnonymous, false);
      expect(TimelineType.bookmarks.supportAnonymous, false);
    });

    test('returns inactive icons by default', () {
      expect(TimelineType.home.icon(), Icons.home_outlined);
      expect(TimelineType.local.icon(), Icons.groups_outlined);
      expect(TimelineType.federal.icon(), Icons.account_tree_outlined);
    });

    test('returns active icons when active is true', () {
      expect(TimelineType.home.icon(active: true), Icons.home);
      expect(TimelineType.local.icon(active: true), Icons.groups);
      expect(TimelineType.federal.icon(active: true), Icons.account_tree);
    });

    testWidgets('returns localized tooltips', (tester) async {
      late BuildContext capturedContext;

      await tester.pumpWidget(createTestWidget(
        child: Builder(builder: (context) {
          capturedContext = context;
          return const SizedBox.shrink();
        }),
      ));

      for (final type in TimelineType.values) {
        final String tooltip = type.tooltip(capturedContext);
        expect(tooltip.isNotEmpty, true, reason: '${type.name} should have a non-empty tooltip');
      }
    });
  });

  group('TimelineType.isAccessible with default config', () {
    test('local/federal/public are accessible without sign-in', () {
      expect(TimelineType.local.isAccessible(isSignedIn: false), true);
      expect(TimelineType.federal.isAccessible(isSignedIn: false), true);
      expect(TimelineType.public.isAccessible(isSignedIn: false), true);
    });

    test('home requires sign-in with default config', () {
      expect(TimelineType.home.isAccessible(isSignedIn: false), false);
      expect(TimelineType.home.isAccessible(isSignedIn: true), true);
    });

    test('favourites and bookmarks always require sign-in', () {
      expect(TimelineType.favourites.isAccessible(isSignedIn: false), false);
      expect(TimelineType.favourites.isAccessible(isSignedIn: true), true);
      expect(TimelineType.bookmarks.isAccessible(isSignedIn: false), false);
      expect(TimelineType.bookmarks.isAccessible(isSignedIn: true), true);
    });
  });

  group('TimelineType.isAccessible with disabled local', () {
    final access = TimelinesAccessSchema.fromJson({
      'home': 'authenticated',
      'live_feeds': {
        'local': 'disabled',
        'remote': 'public',
      },
    });

    test('local is not accessible even when signed in', () {
      expect(TimelineType.local.isAccessible(isSignedIn: false, access: access), false);
      expect(TimelineType.local.isAccessible(isSignedIn: true, access: access), false);
    });

    test('federal is still accessible', () {
      expect(TimelineType.federal.isAccessible(isSignedIn: false, access: access), true);
    });
  });

  group('TimelineType.isAccessible with disabled federated', () {
    final access = TimelinesAccessSchema.fromJson({
      'home': 'authenticated',
      'live_feeds': {
        'local': 'public',
        'remote': 'disabled',
      },
    });

    test('federal and public are not accessible', () {
      expect(TimelineType.federal.isAccessible(isSignedIn: true, access: access), false);
      expect(TimelineType.public.isAccessible(isSignedIn: true, access: access), false);
    });

    test('local is still accessible', () {
      expect(TimelineType.local.isAccessible(isSignedIn: false, access: access), true);
    });
  });

  group('TimelineType.isAccessible with authenticated feeds', () {
    final access = TimelinesAccessSchema.fromJson({
      'home': 'authenticated',
      'live_feeds': {
        'local': 'authenticated',
        'remote': 'authenticated',
      },
    });

    test('local requires sign-in when authenticated', () {
      expect(TimelineType.local.isAccessible(isSignedIn: false, access: access), false);
      expect(TimelineType.local.isAccessible(isSignedIn: true, access: access), true);
    });

    test('federal requires sign-in when authenticated', () {
      expect(TimelineType.federal.isAccessible(isSignedIn: false, access: access), false);
      expect(TimelineType.federal.isAccessible(isSignedIn: true, access: access), true);
    });
  });

  group('TimelineType.isAccessible mastodon.social scenario', () {
    // mastodon.social: local disabled, remote disabled
    final access = TimelinesAccessSchema.fromJson({
      'home': 'authenticated',
      'live_feeds': {
        'local': 'disabled',
        'remote': 'disabled',
      },
    });

    test('home accessible when signed in', () {
      expect(TimelineType.home.isAccessible(isSignedIn: true, access: access), true);
    });

    test('local and federal disabled for everyone', () {
      expect(TimelineType.local.isAccessible(isSignedIn: true, access: access), false);
      expect(TimelineType.federal.isAccessible(isSignedIn: true, access: access), false);
      expect(TimelineType.public.isAccessible(isSignedIn: true, access: access), false);
    });

    test('favourites and bookmarks still work when signed in', () {
      expect(TimelineType.favourites.isAccessible(isSignedIn: true, access: access), true);
      expect(TimelineType.bookmarks.isAccessible(isSignedIn: true, access: access), true);
    });
  });

  group('TimelineType.isAccessible with null access (pre-4.5.0)', () {
    test('behaves same as default config', () {
      expect(TimelineType.local.isAccessible(isSignedIn: false, access: null), true);
      expect(TimelineType.federal.isAccessible(isSignedIn: false, access: null), true);
      expect(TimelineType.home.isAccessible(isSignedIn: false, access: null), false);
      expect(TimelineType.home.isAccessible(isSignedIn: true, access: null), true);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
