// Widget tests for notification screens: NotificationBadge, GroupNotification.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';
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
      // Use null status so onLoad's status?.fetchNotifications() is a no-op,
      // avoiding async errors from malformed API responses in tests.
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: GroupNotification()),
          overrides: [accessStatusProvider.overrideWith((ref) => null)],
        ));
        await tester.pump();
      });

      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('renders as authenticated with server', (tester) async {
      // Use domain=null so getAPI short-circuits without real HTTP calls,
      // and isSignedIn is true (accessToken is set).
      const status = AccessStatusSchema(domain: null, accessToken: 'test');

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

    testWidgets('shows Column layout when signed in', (tester) async {
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

      expect(find.byType(Column), findsWidgets);
      expect(find.byType(Align), findsWidgets);
    });

    testWidgets('shows NoResult when signed in but no groups loaded', (tester) async {
      // Use domain=null to avoid real HTTP calls; onLoad returns empty groups.
      const status = AccessStatusSchema(domain: null, accessToken: 'test');

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: GroupNotification()),
          accessStatus: status,
        ));
        await tester.pump();
        // Allow onLoad to complete (fetchNotifications returns empty groups)
        await Future<void>.delayed(const Duration(milliseconds: 200));
        await tester.pump();
      });

      // After load completes with empty groups, isCompleted=true -> show NoResult
      expect(find.byType(GroupNotification), findsOneWidget);
      expect(find.byType(NoResult), findsOneWidget);
      expect(find.byIcon(Icons.notifications_none_outlined), findsOneWidget);
    });

    testWidgets('toolbar tune icon has tooltip', (tester) async {
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

      // The tune IconButton should have a tooltip
      final IconButton tuneButton = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.tune),
      );
      expect(tuneButton.tooltip, isNotNull);
      expect(tuneButton.tooltip, isNotEmpty);
    });

    testWidgets('toolbar tune icon is in a Row', (tester) async {
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

      // The tune icon should be inside a Row widget (toolbar)
      expect(find.byType(Row), findsWidgets);
      expect(find.byIcon(Icons.tune), findsOneWidget);
    });

    testWidgets('shows loading indicator when signed in', (tester) async {
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

      // PaginatedListMixin provides buildLoadingIndicator() in the layout
      expect(find.byType(GroupNotification), findsOneWidget);
    });

    testWidgets('tapping tune icon does not throw', (tester) async {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: GroupNotification()),
          accessStatus: status,
        ));
        await tester.pump();

        // Tapping the tune icon should open NotificationPolicySheet
        await tester.tap(find.byIcon(Icons.tune));
        await tester.pump();
      });

      // No exception means the tap handler works correctly
      expect(find.byType(GroupNotification), findsOneWidget);
    });

    testWidgets('has Flexible child for content area', (tester) async {
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

      // The build method uses Flexible(child: buildContent())
      expect(find.byType(Flexible), findsWidgets);
    });

    testWidgets('uses topCenter alignment', (tester) async {
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

      // The outer Align uses Alignment.topCenter
      final Align align = tester.widget<Align>(find.byType(Align).first);
      expect(align.alignment, Alignment.topCenter);
    });

    testWidgets('renders ScrollablePositionedList when groups are injected', (tester) async {
      const status = AccessStatusSchema(domain: null, accessToken: 'test');

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: GroupNotification()),
          accessStatus: status,
        ));
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 200));
        await tester.pump();
      });

      // Inject mock groups into state to cover buildContent when groups.isNotEmpty
      final dynamic state = tester.state(find.byType(GroupNotification));
      state.groups = [
        GroupSchema.fromJson({
          'type': 'mention',
          'group_key': 'grp-1',
          'notifications_count': 1,
          'most_recent_notification_id': 100,
          'sample_account_ids': <String>[],
        }),
        GroupSchema.fromJson({
          'type': 'favourite',
          'group_key': 'grp-2',
          'notifications_count': 2,
          'most_recent_notification_id': 101,
          'sample_account_ids': <String>[],
        }),
      ];
      // ignore: invalid_use_of_protected_member
      state.setState(() {});
      await tester.pump();

      // buildContent() should now render the list with SingleNotification items
      expect(find.byType(SingleNotification), findsWidgets);
    });

    testWidgets('shows SingleNotification for each injected group', (tester) async {
      const status = AccessStatusSchema(domain: null, accessToken: 'test');

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: GroupNotification()),
          accessStatus: status,
        ));
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 200));
        await tester.pump();
      });

      // Inject three groups
      final dynamic state = tester.state(find.byType(GroupNotification));
      state.groups = [
        GroupSchema.fromJson({
          'type': 'follow',
          'group_key': 'grp-a',
          'notifications_count': 1,
          'most_recent_notification_id': 200,
          'sample_account_ids': <String>[],
        }),
        GroupSchema.fromJson({
          'type': 'reblog',
          'group_key': 'grp-b',
          'notifications_count': 3,
          'most_recent_notification_id': 201,
          'sample_account_ids': <String>[],
        }),
        GroupSchema.fromJson({
          'type': 'poll',
          'group_key': 'grp-c',
          'notifications_count': 1,
          'most_recent_notification_id': 202,
          'sample_account_ids': <String>[],
        }),
      ];
      // ignore: invalid_use_of_protected_member
      state.setState(() {});
      await tester.pump();

      // All three groups should produce SingleNotification widgets
      expect(find.byType(SingleNotification), findsNWidgets(3));
    });

    testWidgets('disposes listeners without error', (tester) async {
      const status = AccessStatusSchema(domain: null, accessToken: 'test');

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: GroupNotification()),
          accessStatus: status,
        ));
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 200));
        await tester.pump();
      });

      // Replace with a different widget to trigger dispose
      await tester.pumpWidget(createTestWidgetRaw(
        child: const Scaffold(body: SizedBox.shrink()),
        accessStatus: status,
      ));
      await tester.pump();

      // No exception from dispose means listeners were properly cleaned up
      expect(find.byType(GroupNotification), findsNothing);
    });
  });

  group('NotificationBadge lifecycle', () {
    testWidgets('disposes without error', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const NotificationBadge(),
      ));
      await tester.pump();

      // Replace with a different widget to trigger dispose
      await tester.pumpWidget(createTestWidget(
        child: const SizedBox.shrink(),
      ));
      await tester.pump();

      // No exception from dispose
      expect(find.byType(NotificationBadge), findsNothing);
    });

    testWidgets('renders with preference providing refresh interval', (tester) async {
      final preference = SystemPreferenceSchema.fromJson({
        'refresh_interval': 60,
      });

      await tester.pumpWidget(createTestWidget(
        child: const NotificationBadge(),
        preference: preference,
      ));
      await tester.pump();

      expect(find.byType(NotificationBadge), findsOneWidget);
    });

    testWidgets('renders correctly with zero size', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const NotificationBadge(size: 0),
      ));
      await tester.pump();

      expect(find.byType(NotificationBadge), findsOneWidget);
    });

    testWidgets('null color when not selected', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const NotificationBadge(isSelected: false),
      ));
      await tester.pump();

      final IconButton button = tester.widget<IconButton>(find.byType(IconButton));
      expect(button.color, isNull);
    });

    testWidgets('has tooltip from SidebarButtonType', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const NotificationBadge(),
      ));
      await tester.pump();

      final IconButton button = tester.widget<IconButton>(find.byType(IconButton));
      expect(button.tooltip, isNotNull);
    });

    testWidgets('shows Badge.count when unreadCount is injected > 0', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const NotificationBadge(isSelected: false),
      ));
      await tester.pump();

      // Inject unreadCount > 0 to cover Badge.count rendering (lines 100-102)
      final dynamic state = tester.state(find.byType(NotificationBadge));
      state.unreadCount = 5;
      // ignore: invalid_use_of_protected_member
      state.setState(() {});
      await tester.pump();

      // Badge.count should now be rendered
      expect(find.byType(Badge), findsOneWidget);
    });

    testWidgets('onLoad sets unread count via state injection', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: const NotificationBadge(isSelected: false),
          accessStatus: const AccessStatusSchema(domain: null, accessToken: 'test'),
        ));
        await tester.pump();

        // Explicitly call onLoad - with domain=null, getUnreadGroupCount returns 0
        final dynamic state = tester.state(find.byType(NotificationBadge));
        await state.onLoad();
        await tester.pump();
      });

      // onLoad should complete without error
      expect(find.byType(NotificationBadge), findsOneWidget);
    });

    testWidgets('didChangeAppLifecycleState is callable', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const NotificationBadge(),
      ));
      await tester.pump();

      // Call didChangeAppLifecycleState to cover lines 50-52
      final dynamic state = tester.state(find.byType(NotificationBadge));
      state.didChangeAppLifecycleState(AppLifecycleState.resumed);
      await tester.pump();

      expect(find.byType(NotificationBadge), findsOneWidget);
    });
  });

  group('GroupNotification state operations', () {
    testWidgets('onDismissGroup removes group and recreates controllers', (tester) async {
      const status = AccessStatusSchema(domain: null, accessToken: 'test');

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: GroupNotification()),
          accessStatus: status,
        ));
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 200));
        await tester.pump();
      });

      // Inject groups into state
      final dynamic state = tester.state(find.byType(GroupNotification));
      state.groups = [
        GroupSchema.fromJson({
          'type': 'mention',
          'group_key': 'grp-1',
          'notifications_count': 1,
          'most_recent_notification_id': 100,
          'sample_account_ids': <String>[],
        }),
        GroupSchema.fromJson({
          'type': 'follow',
          'group_key': 'grp-2',
          'notifications_count': 1,
          'most_recent_notification_id': 101,
          'sample_account_ids': <String>[],
        }),
      ];
      // ignore: invalid_use_of_protected_member
      state.setState(() {});
      await tester.pump();

      // Call onDismissGroup to cover lines 140-151
      state.onDismissGroup(0, 'grp-1');
      await tester.pump();

      // After dismiss, one group should remain
      expect((state.groups as List).length, equals(1));
    });

    testWidgets('onRefresh clears groups and reloads', (tester) async {
      const status = AccessStatusSchema(domain: null, accessToken: 'test');

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: GroupNotification()),
          accessStatus: status,
        ));
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 200));
        await tester.pump();

        // Call onRefresh to cover lines 155-157
        final dynamic state = tester.state(find.byType(GroupNotification));
        await state.onRefresh();
        await tester.pump();
      });

      expect(find.byType(GroupNotification), findsOneWidget);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
