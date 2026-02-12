// Tests for SidebarButtonType and DrawerButtonType enums.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/glacial/models/core.dart';
import 'package:glacial/features/mastodon/models/config.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  setUpAll(() => setupTestEnvironment());

  group('SidebarButtonType', () {
    test('has 7 values', () {
      expect(SidebarButtonType.values.length, 7);
    });

    test('returns inactive icons by default', () {
      expect(SidebarButtonType.timeline.icon(), Icons.view_timeline_outlined);
      expect(SidebarButtonType.list.icon(), Icons.view_list_outlined);
      expect(SidebarButtonType.trending.icon(), Icons.trending_up_outlined);
      expect(SidebarButtonType.notifications.icon(), Icons.notifications_outlined);
      expect(SidebarButtonType.conversations.icon(), Icons.mail_outline);
      expect(SidebarButtonType.admin.icon(), Icons.admin_panel_settings_outlined);
      expect(SidebarButtonType.post.icon(), Icons.chat_outlined);
    });

    test('returns active icons when active is true', () {
      expect(SidebarButtonType.timeline.icon(active: true), Icons.view_timeline);
      expect(SidebarButtonType.list.icon(active: true), Icons.view_list);
      expect(SidebarButtonType.trending.icon(active: true), Icons.bar_chart);
      expect(SidebarButtonType.notifications.icon(active: true), Icons.notifications);
      expect(SidebarButtonType.conversations.icon(active: true), Icons.mail);
      expect(SidebarButtonType.admin.icon(active: true), Icons.admin_panel_settings);
      expect(SidebarButtonType.post.icon(active: true), Icons.chat);
    });

    test('maps to correct routes', () {
      expect(SidebarButtonType.timeline.route, RoutePath.timeline);
      expect(SidebarButtonType.list.route, RoutePath.list);
      expect(SidebarButtonType.trending.route, RoutePath.trends);
      expect(SidebarButtonType.notifications.route, RoutePath.notifications);
      expect(SidebarButtonType.conversations.route, RoutePath.conversations);
      expect(SidebarButtonType.admin.route, RoutePath.admin);
      expect(SidebarButtonType.post.route, RoutePath.post);
    });

    test('only timeline and trending support anonymous', () {
      expect(SidebarButtonType.timeline.supportAnonymous, true);
      expect(SidebarButtonType.trending.supportAnonymous, true);
      expect(SidebarButtonType.list.supportAnonymous, false);
      expect(SidebarButtonType.notifications.supportAnonymous, false);
      expect(SidebarButtonType.conversations.supportAnonymous, false);
      expect(SidebarButtonType.admin.supportAnonymous, false);
      expect(SidebarButtonType.post.supportAnonymous, false);
    });

    testWidgets('returns localized tooltips', (tester) async {
      late BuildContext capturedContext;

      await tester.pumpWidget(createTestWidget(
        child: Builder(builder: (context) {
          capturedContext = context;
          return const SizedBox.shrink();
        }),
      ));

      // Verify all tooltips return non-empty strings
      for (final type in SidebarButtonType.values) {
        final String tooltip = type.tooltip(capturedContext);
        expect(tooltip.isNotEmpty, true, reason: '${type.name} should have a non-empty tooltip');
      }
    });

    group('isAccessible', () {
      test('timeline is accessible with default config (all public)', () {
        expect(
          SidebarButtonType.timeline.isAccessible(isSignedIn: false),
          isTrue,
        );
      });

      test('timeline is accessible when signed in', () {
        const access = TimelinesAccessSchema(
          home: TimelineAccessLevel.authenticated,
          liveFeeds: LiveFeedsAccessSchema(
            local: TimelineAccessLevel.disabled,
            federated: TimelineAccessLevel.disabled,
          ),
        );
        expect(
          SidebarButtonType.timeline.isAccessible(isSignedIn: true, access: access),
          isTrue,
        );
      });

      test('timeline is inaccessible when all tabs disabled and anonymous', () {
        const access = TimelinesAccessSchema(
          home: TimelineAccessLevel.authenticated,
          liveFeeds: LiveFeedsAccessSchema(
            local: TimelineAccessLevel.disabled,
            federated: TimelineAccessLevel.disabled,
          ),
        );
        expect(
          SidebarButtonType.timeline.isAccessible(isSignedIn: false, access: access),
          isFalse,
        );
      });

      test('timeline is accessible when local is public and anonymous', () {
        const access = TimelinesAccessSchema(
          home: TimelineAccessLevel.authenticated,
          liveFeeds: LiveFeedsAccessSchema(
            local: TimelineAccessLevel.public,
            federated: TimelineAccessLevel.disabled,
          ),
        );
        expect(
          SidebarButtonType.timeline.isAccessible(isSignedIn: false, access: access),
          isTrue,
        );
      });

      test('trending is always accessible', () {
        expect(
          SidebarButtonType.trending.isAccessible(isSignedIn: false),
          isTrue,
        );
        expect(
          SidebarButtonType.trending.isAccessible(isSignedIn: true),
          isTrue,
        );
      });

      test('auth-required buttons need sign-in', () {
        expect(SidebarButtonType.list.isAccessible(isSignedIn: false), isFalse);
        expect(SidebarButtonType.list.isAccessible(isSignedIn: true), isTrue);
        expect(SidebarButtonType.notifications.isAccessible(isSignedIn: false), isFalse);
        expect(SidebarButtonType.conversations.isAccessible(isSignedIn: false), isFalse);
      });
    });
  });

  group('DrawerButtonType', () {
    test('has 6 values', () {
      expect(DrawerButtonType.values.length, 6);
    });

    test('returns correct icons', () {
      expect(DrawerButtonType.switchAccount.icon(), Icons.people);
      expect(DrawerButtonType.switchServer.icon(), Icons.swap_horiz);
      expect(DrawerButtonType.directory.icon(), Icons.groups);
      expect(DrawerButtonType.announcement.icon(), Icons.campaign);
      expect(DrawerButtonType.preference.icon(), Icons.settings);
      expect(DrawerButtonType.logout.icon(), Icons.logout);
    });

    test('maps to correct routes', () {
      expect(DrawerButtonType.switchAccount.route, RoutePath.timeline);
      expect(DrawerButtonType.switchServer.route, RoutePath.explorer);
      expect(DrawerButtonType.directory.route, RoutePath.directory);
      expect(DrawerButtonType.announcement.route, RoutePath.timeline);
      expect(DrawerButtonType.preference.route, RoutePath.preference);
      expect(DrawerButtonType.logout.route, RoutePath.timeline);
    });

    testWidgets('returns localized tooltips', (tester) async {
      late BuildContext capturedContext;

      await tester.pumpWidget(createTestWidget(
        child: Builder(builder: (context) {
          capturedContext = context;
          return const SizedBox.shrink();
        }),
      ));

      for (final type in DrawerButtonType.values) {
        final String tooltip = type.tooltip(capturedContext);
        expect(tooltip.isNotEmpty, true, reason: '${type.name} should have a non-empty tooltip');
      }
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
