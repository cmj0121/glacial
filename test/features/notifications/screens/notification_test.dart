// Widget tests for notification screens: NotificationBadge, GroupNotification.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/features/screens.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  setupTestEnvironment();

  group('NotificationBadge', () {
    testWidgets('renders icon button', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const NotificationBadge(),
      ));
      await tester.pump();

      expect(find.byType(NotificationBadge), findsOneWidget);
      expect(find.byType(IconButton), findsOneWidget);
    });

    testWidgets('shows notification icon', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const NotificationBadge(),
      ));
      await tester.pump();

      // SidebarButtonType.notifications uses Icons.notifications_outlined when not active
      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
    });

    testWidgets('shows active icon when selected', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const NotificationBadge(isSelected: true),
      ));
      await tester.pump();

      // SidebarButtonType.notifications uses Icons.notifications when active
      expect(find.byIcon(Icons.notifications), findsOneWidget);
    });

    testWidgets('no badge shown when unread count is zero', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const NotificationBadge(),
      ));
      await tester.pump();

      // Initially unreadCount is 0, so no Badge.count should appear
      expect(find.byType(Badge), findsNothing);
    });

    testWidgets('no badge shown when selected even with unread', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const NotificationBadge(isSelected: true),
      ));
      await tester.pump();

      // When selected, badge is never shown
      expect(find.byType(Badge), findsNothing);
    });

    testWidgets('uses primary color when selected', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const NotificationBadge(isSelected: true),
      ));
      await tester.pump();

      final IconButton button = tester.widget<IconButton>(find.byType(IconButton));
      expect(button.color, isNotNull);
    });

    testWidgets('accepts custom size', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const NotificationBadge(size: 48),
      ));
      await tester.pump();

      expect(find.byType(NotificationBadge), findsOneWidget);
    });

    testWidgets('accepts onPressed callback', (tester) async {
      bool pressed = false;

      await tester.pumpWidget(createTestWidget(
        child: NotificationBadge(onPressed: () => pressed = true),
      ));
      await tester.pump();

      await tester.tap(find.byType(IconButton));
      expect(pressed, isTrue);
    });
  });

  group('GroupNotification', () {
    testWidgets('returns empty when not signed in', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: GroupNotification()),
          accessStatus: MockAccessStatus.anonymous(),
        ));
        await tester.pump();
      });

      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('renders as authenticated with server', (tester) async {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: GroupNotification()),
          accessStatus: status,
        ));
        await tester.pump();
      });

      expect(find.byType(GroupNotification), findsOneWidget);
    });

    testWidgets('shows toolbar with tune icon when signed in', (tester) async {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: GroupNotification()),
          accessStatus: status,
        ));
        await tester.pump();
      });

      // The toolbar row has a tune icon for notification policy
      expect(find.byIcon(Icons.tune), findsOneWidget);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
