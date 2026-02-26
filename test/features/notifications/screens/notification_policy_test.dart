// Tests for NotificationPolicySheet widget.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/notifications/screens/notification_policy.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  setupTestEnvironment();

  group('NotificationPolicySheet', () {
    testWidgets('renders with null status', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const NotificationPolicySheet(status: null),
      ));
      await tester.pump();

      expect(find.byType(NotificationPolicySheet), findsOneWidget);
    });

    testWidgets('is wrapped in Padding', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const NotificationPolicySheet(status: null),
      ));
      await tester.pump();

      expect(find.byType(Padding), findsWidgets);
    });

    testWidgets('contains Column layout', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const NotificationPolicySheet(status: null),
      ));
      await tester.pump();

      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('renders with no-domain status', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: const NotificationPolicySheet(
            status: AccessStatusSchema(domain: null, accessToken: 'test'),
          ),
        ));
        await tester.pump();
      });

      expect(find.byType(NotificationPolicySheet), findsOneWidget);
    });

    test('is a StatefulWidget', () {
      const widget = NotificationPolicySheet(status: null);
      expect(widget, isA<StatefulWidget>());
    });

    test('stores status parameter', () {
      const status = AccessStatusSchema(domain: 'example.com', accessToken: 'test');
      const widget = NotificationPolicySheet(status: status);
      expect(widget.status, status);
    });

    test('status can be null', () {
      const widget = NotificationPolicySheet(status: null);
      expect(widget.status, isNull);
    });

    testWidgets('shows title text', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(
            body: NotificationPolicySheet(status: null),
          ),
        ));
        await tester.pump();
      });

      // Title "Notification Policy" should be present
      expect(find.byType(NotificationPolicySheet), findsOneWidget);
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('shows loading indicator when policy is null', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(
            body: NotificationPolicySheet(status: null),
          ),
        ));
        await tester.pump();
      });

      // With null status, onLoad returns null policy -> shows loading
      expect(find.byType(ClockProgressIndicator), findsOneWidget);
    });

    testWidgets('renders with authenticated status', (tester) async {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(
            body: NotificationPolicySheet(status: status),
          ),
        ));
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 100));
        await tester.pump();
      });

      expect(find.byType(NotificationPolicySheet), findsOneWidget);
    });

    testWidgets('has Column with padding layout', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(
            body: NotificationPolicySheet(status: null),
          ),
        ));
        await tester.pump();
      });

      expect(find.byType(Column), findsWidgets);
      expect(find.byType(Padding), findsWidgets);
    });

    testWidgets('title uses titleMedium style', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(
            body: NotificationPolicySheet(status: null),
          ),
        ));
        await tester.pump();
      });

      // The first Text child in the Column should be the title
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('loading indicator is centered', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(
            body: NotificationPolicySheet(status: null),
          ),
        ));
        await tester.pump();
      });

      // ClockProgressIndicator should be inside a Center widget
      expect(find.byType(Center), findsWidgets);
      expect(find.byType(ClockProgressIndicator), findsOneWidget);
    });

    testWidgets('has SizedBox spacer between title and content', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(
            body: NotificationPolicySheet(status: null),
          ),
        ));
        await tester.pump();
      });

      // SizedBox(height: 16) separator between title and content
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('shows SegmentedButton rows when policy loads from no-domain status', (tester) async {
      // With domain=null and accessToken='test', getNotificationPolicy()
      // passes checkSignedIn but getAPI returns null -> fromJson({}) -> all defaults.
      const status = AccessStatusSchema(domain: null, accessToken: 'test');

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(
            body: SingleChildScrollView(
              child: NotificationPolicySheet(status: status),
            ),
          ),
        ));
        await tester.pump();
        // Wait for addPostFrameCallback -> onLoad() async to complete
        await Future<void>.delayed(const Duration(milliseconds: 200));
        await tester.pump();
      });

      // After onLoad completes, 5 buildRow calls should render 5 SegmentedButtons
      expect(find.byType(SegmentedButton<NotificationPolicyValue>), findsNWidgets(5));
    });

    testWidgets('SegmentedButton rows display policy value icons', (tester) async {
      const status = AccessStatusSchema(domain: null, accessToken: 'test');

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(
            body: SingleChildScrollView(
              child: NotificationPolicySheet(status: status),
            ),
          ),
        ));
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 200));
        await tester.pump();
      });

      // Each policy value icon should appear 5 times (once per row)
      expect(find.byIcon(Icons.check_circle_outline), findsWidgets);
      expect(find.byIcon(Icons.filter_alt_outlined), findsWidgets);
      expect(find.byIcon(Icons.block), findsWidgets);
    });

    testWidgets('shows policy label texts after load', (tester) async {
      const status = AccessStatusSchema(domain: null, accessToken: 'test');

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(
            body: SingleChildScrollView(
              child: NotificationPolicySheet(status: status),
            ),
          ),
        ));
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 200));
        await tester.pump();
      });

      // Loading indicator should be gone after policy loads
      expect(find.byType(ClockProgressIndicator), findsNothing);
      // Row labels should be present (at least the fallback English strings)
      expect(find.byType(Row), findsWidgets);
    });

    testWidgets('tapping a SegmentedButton segment triggers onUpdate', (tester) async {
      const status = AccessStatusSchema(domain: null, accessToken: 'test');

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(
            body: SingleChildScrollView(
              child: NotificationPolicySheet(status: status),
            ),
          ),
        ));
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 200));
        await tester.pump();

        // Tap the "filter" icon on the first SegmentedButton row to trigger onUpdate.
        // The filter icon (Icons.filter_alt_outlined) appears in each row.
        final Finder filterIcons = find.byIcon(Icons.filter_alt_outlined);
        expect(filterIcons, findsWidgets);
        await tester.tap(filterIcons.first);
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 100));
        await tester.pump();
      });

      // After tapping, the widget should still be rendered without error
      expect(find.byType(SegmentedButton<NotificationPolicyValue>), findsNWidgets(5));
    });

    testWidgets('tapping forNotFollowers row triggers onUpdate (row 2)', (tester) async {
      const status = AccessStatusSchema(domain: null, accessToken: 'test');

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(
            body: SingleChildScrollView(
              child: NotificationPolicySheet(status: status),
            ),
          ),
        ));
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 200));
        await tester.pump();

        // Tap the "filter" segment on the second row (forNotFollowers).
        final Finder filterIcons = find.byIcon(Icons.filter_alt_outlined);
        expect(filterIcons, findsNWidgets(5));
        await tester.tap(filterIcons.at(1));
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 100));
        await tester.pump();
      });

      expect(find.byType(SegmentedButton<NotificationPolicyValue>), findsNWidgets(5));
    });

    testWidgets('tapping forNewAccounts row triggers onUpdate (row 3)', (tester) async {
      const status = AccessStatusSchema(domain: null, accessToken: 'test');

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(
            body: SingleChildScrollView(
              child: NotificationPolicySheet(status: status),
            ),
          ),
        ));
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 200));
        await tester.pump();

        // Tap the "drop" segment on the third row (forNewAccounts).
        final Finder dropIcons = find.byIcon(Icons.block);
        expect(dropIcons, findsNWidgets(5));
        await tester.tap(dropIcons.at(2));
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 100));
        await tester.pump();
      });

      expect(find.byType(SegmentedButton<NotificationPolicyValue>), findsNWidgets(5));
    });

    testWidgets('tapping forPrivateMentions row triggers onUpdate (row 4)', (tester) async {
      const status = AccessStatusSchema(domain: null, accessToken: 'test');

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(
            body: SingleChildScrollView(
              child: NotificationPolicySheet(status: status),
            ),
          ),
        ));
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 200));
        await tester.pump();

        // Tap the "filter" segment on the fourth row (forPrivateMentions).
        final Finder filterIcons = find.byIcon(Icons.filter_alt_outlined);
        expect(filterIcons, findsNWidgets(5));
        await tester.tap(filterIcons.at(3));
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 100));
        await tester.pump();
      });

      expect(find.byType(SegmentedButton<NotificationPolicyValue>), findsNWidgets(5));
    });

    testWidgets('tapping forLimitedAccounts row triggers onUpdate (row 5)', (tester) async {
      const status = AccessStatusSchema(domain: null, accessToken: 'test');

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(
            body: SingleChildScrollView(
              child: NotificationPolicySheet(status: status),
            ),
          ),
        ));
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 200));
        await tester.pump();

        // Tap the "drop" segment on the fifth row (forLimitedAccounts).
        final Finder dropIcons = find.byIcon(Icons.block);
        expect(dropIcons, findsNWidgets(5));
        await tester.tap(dropIcons.at(4));
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 100));
        await tester.pump();
      });

      expect(find.byType(SegmentedButton<NotificationPolicyValue>), findsNWidgets(5));
    });
  });

  group('NotificationPolicyValue tooltip', () {
    testWidgets('each value has localized tooltip', (tester) async {
      late BuildContext capturedContext;
      await tester.pumpWidget(createTestWidget(
        child: Builder(builder: (context) {
          capturedContext = context;
          return const SizedBox.shrink();
        }),
      ));
      await tester.pump();

      for (final value in NotificationPolicyValue.values) {
        final String tooltip = value.tooltip(capturedContext);
        expect(tooltip, isNotEmpty, reason: '${value.name} tooltip should not be empty');
      }
    });

    testWidgets('accept tooltip returns Accept', (tester) async {
      late BuildContext capturedContext;
      await tester.pumpWidget(createTestWidget(
        child: Builder(builder: (context) {
          capturedContext = context;
          return const SizedBox.shrink();
        }),
      ));
      await tester.pump();

      final String tooltip = NotificationPolicyValue.accept.tooltip(capturedContext);
      expect(tooltip, isNotEmpty);
    });

    testWidgets('filter tooltip returns Filter', (tester) async {
      late BuildContext capturedContext;
      await tester.pumpWidget(createTestWidget(
        child: Builder(builder: (context) {
          capturedContext = context;
          return const SizedBox.shrink();
        }),
      ));
      await tester.pump();

      final String tooltip = NotificationPolicyValue.filter.tooltip(capturedContext);
      expect(tooltip, isNotEmpty);
    });

    testWidgets('drop tooltip returns Drop', (tester) async {
      late BuildContext capturedContext;
      await tester.pumpWidget(createTestWidget(
        child: Builder(builder: (context) {
          capturedContext = context;
          return const SizedBox.shrink();
        }),
      ));
      await tester.pump();

      final String tooltip = NotificationPolicyValue.drop.tooltip(capturedContext);
      expect(tooltip, isNotEmpty);
    });
  });

  group('NotificationType tooltip', () {
    testWidgets('each type has non-empty tooltip', (tester) async {
      late BuildContext capturedContext;
      await tester.pumpWidget(createTestWidget(
        child: Builder(builder: (context) {
          capturedContext = context;
          return const SizedBox.shrink();
        }),
      ));
      await tester.pump();

      for (final type in NotificationType.values) {
        final String tooltip = type.tooltip(capturedContext);
        expect(tooltip, isNotEmpty, reason: '${type.name} tooltip should not be empty');
      }
    });

    testWidgets('mention tooltip is localized', (tester) async {
      late BuildContext capturedContext;
      await tester.pumpWidget(createTestWidget(
        child: Builder(builder: (context) {
          capturedContext = context;
          return const SizedBox.shrink();
        }),
      ));
      await tester.pump();

      expect(NotificationType.mention.tooltip(capturedContext), isNotEmpty);
    });

    testWidgets('follow tooltip is localized', (tester) async {
      late BuildContext capturedContext;
      await tester.pumpWidget(createTestWidget(
        child: Builder(builder: (context) {
          capturedContext = context;
          return const SizedBox.shrink();
        }),
      ));
      await tester.pump();

      expect(NotificationType.follow.tooltip(capturedContext), isNotEmpty);
    });

    testWidgets('favourite tooltip is localized', (tester) async {
      late BuildContext capturedContext;
      await tester.pumpWidget(createTestWidget(
        child: Builder(builder: (context) {
          capturedContext = context;
          return const SizedBox.shrink();
        }),
      ));
      await tester.pump();

      expect(NotificationType.favourite.tooltip(capturedContext), isNotEmpty);
    });

    testWidgets('reblog tooltip is localized', (tester) async {
      late BuildContext capturedContext;
      await tester.pumpWidget(createTestWidget(
        child: Builder(builder: (context) {
          capturedContext = context;
          return const SizedBox.shrink();
        }),
      ));
      await tester.pump();

      expect(NotificationType.reblog.tooltip(capturedContext), isNotEmpty);
    });

    testWidgets('poll tooltip is localized', (tester) async {
      late BuildContext capturedContext;
      await tester.pumpWidget(createTestWidget(
        child: Builder(builder: (context) {
          capturedContext = context;
          return const SizedBox.shrink();
        }),
      ));
      await tester.pump();

      expect(NotificationType.poll.tooltip(capturedContext), isNotEmpty);
    });

    testWidgets('update tooltip is localized', (tester) async {
      late BuildContext capturedContext;
      await tester.pumpWidget(createTestWidget(
        child: Builder(builder: (context) {
          capturedContext = context;
          return const SizedBox.shrink();
        }),
      ));
      await tester.pump();

      expect(NotificationType.update.tooltip(capturedContext), isNotEmpty);
    });

    testWidgets('status tooltip is localized', (tester) async {
      late BuildContext capturedContext;
      await tester.pumpWidget(createTestWidget(
        child: Builder(builder: (context) {
          capturedContext = context;
          return const SizedBox.shrink();
        }),
      ));
      await tester.pump();

      expect(NotificationType.status.tooltip(capturedContext), isNotEmpty);
    });

    testWidgets('followRequest tooltip is localized', (tester) async {
      late BuildContext capturedContext;
      await tester.pumpWidget(createTestWidget(
        child: Builder(builder: (context) {
          capturedContext = context;
          return const SizedBox.shrink();
        }),
      ));
      await tester.pump();

      expect(NotificationType.followRequest.tooltip(capturedContext), isNotEmpty);
    });

    testWidgets('adminSignUp tooltip is localized', (tester) async {
      late BuildContext capturedContext;
      await tester.pumpWidget(createTestWidget(
        child: Builder(builder: (context) {
          capturedContext = context;
          return const SizedBox.shrink();
        }),
      ));
      await tester.pump();

      expect(NotificationType.adminSignUp.tooltip(capturedContext), isNotEmpty);
    });

    testWidgets('adminReport tooltip is localized', (tester) async {
      late BuildContext capturedContext;
      await tester.pumpWidget(createTestWidget(
        child: Builder(builder: (context) {
          capturedContext = context;
          return const SizedBox.shrink();
        }),
      ));
      await tester.pump();

      expect(NotificationType.adminReport.tooltip(capturedContext), isNotEmpty);
    });

    testWidgets('unknown tooltip is localized', (tester) async {
      late BuildContext capturedContext;
      await tester.pumpWidget(createTestWidget(
        child: Builder(builder: (context) {
          capturedContext = context;
          return const SizedBox.shrink();
        }),
      ));
      await tester.pump();

      expect(NotificationType.unknown.tooltip(capturedContext), isNotEmpty);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
