// Tests for SidebarButtonType and DrawerButtonType enums.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  setupTestEnvironment();

  group('SidebarButtonType', () {
    test('icon returns different icons for active and inactive', () {
      for (final type in SidebarButtonType.values) {
        final activeIcon = type.icon(active: true);
        final inactiveIcon = type.icon(active: false);
        expect(activeIcon, isNot(equals(inactiveIcon)),
            reason: '${type.name} should have different active/inactive icons');
      }
    });

    test('route maps to correct RoutePath', () {
      expect(SidebarButtonType.timeline.route, RoutePath.timeline);
      expect(SidebarButtonType.list.route, RoutePath.list);
      expect(SidebarButtonType.trending.route, RoutePath.trends);
      expect(SidebarButtonType.notifications.route, RoutePath.notifications);
      expect(SidebarButtonType.conversations.route, RoutePath.conversations);
      expect(SidebarButtonType.admin.route, RoutePath.admin);
      expect(SidebarButtonType.post.route, RoutePath.post);
    });

    test('supportAnonymous is true only for timeline and trending', () {
      expect(SidebarButtonType.timeline.supportAnonymous, true);
      expect(SidebarButtonType.trending.supportAnonymous, true);
      expect(SidebarButtonType.list.supportAnonymous, false);
      expect(SidebarButtonType.notifications.supportAnonymous, false);
      expect(SidebarButtonType.conversations.supportAnonymous, false);
      expect(SidebarButtonType.admin.supportAnonymous, false);
      expect(SidebarButtonType.post.supportAnonymous, false);
    });

    test('isAccessible for trending is always true', () {
      expect(SidebarButtonType.trending.isAccessible(isSignedIn: false), true);
      expect(SidebarButtonType.trending.isAccessible(isSignedIn: true), true);
    });

    test('isAccessible for non-anonymous types requires sign in', () {
      expect(SidebarButtonType.list.isAccessible(isSignedIn: false), false);
      expect(SidebarButtonType.list.isAccessible(isSignedIn: true), true);
      expect(SidebarButtonType.notifications.isAccessible(isSignedIn: false), false);
      expect(SidebarButtonType.notifications.isAccessible(isSignedIn: true), true);
    });

    testWidgets('tooltip returns localized text', (tester) async {
      late BuildContext capturedContext;
      await tester.pumpWidget(createTestWidget(
        child: Builder(builder: (context) {
          capturedContext = context;
          return const SizedBox();
        }),
      ));
      await tester.pump();

      for (final type in SidebarButtonType.values) {
        final tooltip = type.tooltip(capturedContext);
        expect(tooltip, isNotEmpty, reason: '${type.name} tooltip should not be empty');
      }
    });
  });

  group('DrawerButtonType', () {
    test('icon returns correct icons', () {
      expect(DrawerButtonType.switchAccount.icon(), Icons.people);
      expect(DrawerButtonType.drafts.icon(), Icons.edit_note);
      expect(DrawerButtonType.switchServer.icon(), Icons.swap_horiz);
      expect(DrawerButtonType.directory.icon(), Icons.groups);
      expect(DrawerButtonType.announcement.icon(), Icons.campaign);
      expect(DrawerButtonType.preference.icon(), Icons.settings);
      expect(DrawerButtonType.logout.icon(), Icons.logout);
    });

    testWidgets('tooltip returns localized text', (tester) async {
      late BuildContext capturedContext;
      await tester.pumpWidget(createTestWidget(
        child: Builder(builder: (context) {
          capturedContext = context;
          return const SizedBox();
        }),
      ));
      await tester.pump();

      for (final type in DrawerButtonType.values) {
        final tooltip = type.tooltip(capturedContext);
        expect(tooltip, isNotEmpty, reason: '${type.name} tooltip should not be empty');
      }
    });

    test('route returns valid RoutePath', () {
      for (final type in DrawerButtonType.values) {
        expect(type.route, isA<RoutePath>());
      }
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
