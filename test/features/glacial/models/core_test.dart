// Tests for SidebarButtonType and DrawerButtonType enums.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/glacial/models/core.dart';

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
  });

  group('DrawerButtonType', () {
    test('has 7 values', () {
      expect(DrawerButtonType.values.length, 7);
    });

    test('returns correct icons', () {
      expect(DrawerButtonType.switchServer.icon(), Icons.swap_horiz);
      expect(DrawerButtonType.directory.icon(), Icons.groups);
      expect(DrawerButtonType.announcement.icon(), Icons.campaign);
      expect(DrawerButtonType.mutedAccounts.icon(), Icons.volume_off);
      expect(DrawerButtonType.blockedAccounts.icon(), Icons.block);
      expect(DrawerButtonType.preference.icon(), Icons.settings);
      expect(DrawerButtonType.logout.icon(), Icons.logout);
    });

    test('maps to correct routes', () {
      expect(DrawerButtonType.switchServer.route, RoutePath.explorer);
      expect(DrawerButtonType.directory.route, RoutePath.directory);
      expect(DrawerButtonType.announcement.route, RoutePath.timeline);
      expect(DrawerButtonType.mutedAccounts.route, RoutePath.mutedAccounts);
      expect(DrawerButtonType.blockedAccounts.route, RoutePath.blockedAccounts);
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

    testWidgets('mutedAccounts tooltip uses mute label', (tester) async {
      late BuildContext capturedContext;

      await tester.pumpWidget(createTestWidget(
        child: Builder(builder: (context) {
          capturedContext = context;
          return const SizedBox.shrink();
        }),
      ));

      final String tooltip = DrawerButtonType.mutedAccounts.tooltip(capturedContext);
      expect(tooltip, contains('Mute'));
    });

    testWidgets('blockedAccounts tooltip uses block label', (tester) async {
      late BuildContext capturedContext;

      await tester.pumpWidget(createTestWidget(
        child: Builder(builder: (context) {
          capturedContext = context;
          return const SizedBox.shrink();
        }),
      ));

      final String tooltip = DrawerButtonType.blockedAccounts.tooltip(capturedContext);
      expect(tooltip, contains('Block'));
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
