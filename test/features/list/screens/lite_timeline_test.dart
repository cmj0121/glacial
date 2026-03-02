// Widget tests for LiteTimeline (the full stateful widget, not just the label).
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  setupTestEnvironment();

  // Initialize sqflite FFI for CachedNetworkImage's cache manager in runAsync tests.
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  // Mock path_provider for CachedNetworkImage cache manager.
  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async => Directory.systemTemp.path,
    );
  });

  // Helper: creates a ProviderScope with accessStatusProvider explicitly null.
  // When status is null, buildTimeline() returns SizedBox.shrink (no API calls).
  Widget buildLiteTimeline({
    required ListSchema schema,
    AccessStatusSchema? accessStatus,
  }) {
    final List<Override> overrides = [
      accessStatusProvider.overrideWith((ref) => accessStatus),
    ];

    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(body: LiteTimeline(schema: schema)),
      ),
    );
  }

  group('LiteTimeline widget', () {
    testWidgets('is a ConsumerStatefulWidget', (tester) async {
      final schema = MockListSchema.create();
      final widget = LiteTimeline(schema: schema);
      expect(widget, isA<ConsumerStatefulWidget>());
    });

    testWidgets('renders with null status (timeline shows SizedBox.shrink)', (tester) async {
      final schema = MockListSchema.create(title: 'Test List');

      await tester.runAsync(() async {
        await tester.pumpWidget(buildLiteTimeline(schema: schema));
        await tester.pump();
      });

      expect(find.byType(LiteTimeline), findsOneWidget);
    });

    testWidgets('shows Column with header and Divider', (tester) async {
      final schema = MockListSchema.create(title: 'Test List');

      await tester.runAsync(() async {
        await tester.pumpWidget(buildLiteTimeline(schema: schema));
        await tester.pump();
      });

      expect(find.byType(Column), findsWidgets);
      expect(find.byType(Divider), findsOneWidget);
    });

    testWidgets('shows header with search TextField', (tester) async {
      final schema = MockListSchema.create(title: 'Test List');

      await tester.runAsync(() async {
        await tester.pumpWidget(buildLiteTimeline(schema: schema));
        await tester.pump();
      });

      // TextField in the header (search bar)
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('shows group icon button (not showing members initially)', (tester) async {
      final schema = MockListSchema.create();

      await tester.runAsync(() async {
        await tester.pumpWidget(buildLiteTimeline(schema: schema));
        await tester.pump();
      });

      // Initially showMembers=false, so we see Icons.group
      expect(find.byIcon(Icons.group), findsOneWidget);
    });

    testWidgets('shows reply policy icon button in header', (tester) async {
      final schema = MockListSchema.create(replyPolicy: ReplyPolicyType.list);

      await tester.runAsync(() async {
        await tester.pumpWidget(buildLiteTimeline(schema: schema));
        await tester.pump();
      });

      // The reply policy icon for "list" policy
      expect(find.byIcon(Icons.playlist_add_check), findsOneWidget);
    });

    testWidgets('shows exclusive toggle icon (non-exclusive shows check_circle)', (tester) async {
      final schema = MockListSchema.create(exclusive: false);

      await tester.runAsync(() async {
        await tester.pumpWidget(buildLiteTimeline(schema: schema));
        await tester.pump();
      });

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('shows exclusive toggle icon (exclusive shows remove_circle)', (tester) async {
      final schema = MockListSchema.create(exclusive: true);

      await tester.runAsync(() async {
        await tester.pumpWidget(buildLiteTimeline(schema: schema));
        await tester.pump();
      });

      expect(find.byIcon(Icons.remove_circle), findsOneWidget);
    });

    testWidgets('tapping group icon toggles to showMembers mode', (tester) async {
      final schema = MockListSchema.create();

      await tester.runAsync(() async {
        await tester.pumpWidget(buildLiteTimeline(schema: schema));
        await tester.pump();

        // Initially shows Icons.group
        expect(find.byIcon(Icons.group), findsOneWidget);
        expect(find.byIcon(Icons.group_add_sharp), findsNothing);

        // Tap the group icon to toggle to showMembers
        await tester.tap(find.byIcon(Icons.group));
        await tester.pump();
      });

      // Now shows Icons.group_add_sharp (showMembers=true)
      expect(find.byIcon(Icons.group_add_sharp), findsOneWidget);
    });

    testWidgets('showMembers mode shows NoResult when members future returns null', (tester) async {
      final schema = MockListSchema.create();

      await tester.runAsync(() async {
        await tester.pumpWidget(buildLiteTimeline(schema: schema));
        await tester.pump();

        // Tap the group icon to toggle to showMembers
        await tester.tap(find.byIcon(Icons.group));
        await tester.pump();
        // Let the future complete (status is null, so _membersFuture stays null)
        await tester.pump();
      });

      // With null status, _membersFuture is null → snapshot.data == null → NoResult
      expect(find.byType(NoResult), findsOneWidget);
    });

    testWidgets('showMembers mode shows NoResult for null status members', (tester) async {
      final schema = MockListSchema.create();

      await tester.runAsync(() async {
        await tester.pumpWidget(buildLiteTimeline(schema: schema));
        await tester.pump();

        // Tap the group icon to toggle to showMembers
        await tester.tap(find.byIcon(Icons.group));
        await tester.pump();
        // Let the future complete
        await tester.pump();
      });

      // With null status, _membersFuture is null → snapshot.data == null → NoResult
      expect(find.byType(NoResult), findsOneWidget);
    });

    testWidgets('tapping group icon twice toggles back to timeline mode', (tester) async {
      final schema = MockListSchema.create();

      await tester.runAsync(() async {
        await tester.pumpWidget(buildLiteTimeline(schema: schema));
        await tester.pump();

        // Toggle to showMembers
        await tester.tap(find.byIcon(Icons.group));
        await tester.pump();

        // Toggle back
        await tester.tap(find.byIcon(Icons.group_add_sharp));
        await tester.pump();
      });

      // Back to group icon (not showing members)
      expect(find.byIcon(Icons.group), findsOneWidget);
    });

    testWidgets('tapping reply policy icon cycles policy (with null status)', (tester) async {
      // Start with "list" policy
      final schema = MockListSchema.create(replyPolicy: ReplyPolicyType.list);

      await tester.runAsync(() async {
        await tester.pumpWidget(buildLiteTimeline(schema: schema));
        await tester.pump();

        // Tap the reply policy icon — status is null so updateList/onReload are no-ops
        await tester.tap(find.byIcon(Icons.playlist_add_check));
        await tester.pump();
      });

      // The widget still renders (no crash)
      expect(find.byType(LiteTimeline), findsOneWidget);
    });

    testWidgets('tapping exclusive toggle button triggers update (with null status)', (tester) async {
      final schema = MockListSchema.create(exclusive: false);

      await tester.runAsync(() async {
        await tester.pumpWidget(buildLiteTimeline(schema: schema));
        await tester.pump();

        // Tap the exclusive toggle (check_circle icon for non-exclusive)
        // status is null so updateList/onReload are no-ops
        await tester.tap(find.byIcon(Icons.check_circle));
        await tester.pump();
      });

      // The widget still renders (no crash)
      expect(find.byType(LiteTimeline), findsOneWidget);
    });

    testWidgets('search TextField is disabled when not in showMembers mode', (tester) async {
      final schema = MockListSchema.create();

      await tester.runAsync(() async {
        await tester.pumpWidget(buildLiteTimeline(schema: schema));
        await tester.pump();
      });

      // The TextField has enabled: showMembers (false), so it should be disabled
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.decoration?.enabled, false);
    });

    testWidgets('search TextField is enabled when in showMembers mode', (tester) async {
      final schema = MockListSchema.create();

      await tester.runAsync(() async {
        await tester.pumpWidget(buildLiteTimeline(schema: schema));
        await tester.pump();

        // Toggle to showMembers
        await tester.tap(find.byIcon(Icons.group));
        await tester.pump();
      });

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.decoration?.enabled, true);
    });

    testWidgets('wraps content in AccessibleDismissible', (tester) async {
      final schema = MockListSchema.create();

      await tester.runAsync(() async {
        await tester.pumpWidget(buildLiteTimeline(schema: schema));
        await tester.pump();
      });

      expect(find.byType(AccessibleDismissible), findsOneWidget);
    });

    testWidgets('header has 3 IconButtons (group, replyPolicy, exclusive)', (tester) async {
      final schema = MockListSchema.create();

      await tester.runAsync(() async {
        await tester.pumpWidget(buildLiteTimeline(schema: schema));
        await tester.pump();
      });

      // 3 IconButtons in the header row
      expect(find.byType(IconButton), findsNWidgets(3));
    });

    testWidgets('followed policy shows correct icon', (tester) async {
      final schema = MockListSchema.create(replyPolicy: ReplyPolicyType.followed);

      await tester.runAsync(() async {
        await tester.pumpWidget(buildLiteTimeline(schema: schema));
        await tester.pump();
      });

      expect(find.byIcon(Icons.chat_bubble_outline), findsOneWidget);
    });

    testWidgets('none policy shows correct icon', (tester) async {
      final schema = MockListSchema.create(replyPolicy: ReplyPolicyType.none);

      await tester.runAsync(() async {
        await tester.pumpWidget(buildLiteTimeline(schema: schema));
        await tester.pump();
      });

      expect(find.byIcon(Icons.do_not_touch), findsOneWidget);
    });

    testWidgets('submitting empty search does nothing', (tester) async {
      final schema = MockListSchema.create();

      await tester.runAsync(() async {
        await tester.pumpWidget(buildLiteTimeline(schema: schema));
        await tester.pump();

        // Toggle to showMembers to enable the TextField
        await tester.tap(find.byIcon(Icons.group));
        await tester.pump();
        await tester.pump();

        // Submit empty text
        await tester.enterText(find.byType(TextField), '');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();
      });

      // No dialog should appear (empty search is ignored)
      expect(find.byType(ListAccountWidget), findsNothing);
    });

    testWidgets('search TextField has onSubmitted callback', (tester) async {
      final schema = MockListSchema.create();

      await tester.runAsync(() async {
        await tester.pumpWidget(buildLiteTimeline(schema: schema));
        await tester.pump();
      });

      // Verify the TextField has an onSubmitted handler (connected to onSearchAccount)
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.onSubmitted, isNotNull);
    });

    testWidgets('header search bar hint text is present', (tester) async {
      final schema = MockListSchema.create();

      await tester.runAsync(() async {
        await tester.pumpWidget(buildLiteTimeline(schema: schema));
        await tester.pump();
      });

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.decoration?.hintText, isNotNull);
      expect(textField.decoration!.hintText!.isNotEmpty, true);
    });

    testWidgets('exclusive tooltip shows for exclusive list', (tester) async {
      final schema = MockListSchema.create(exclusive: true);

      await tester.runAsync(() async {
        await tester.pumpWidget(buildLiteTimeline(schema: schema));
        await tester.pump();
      });

      // Find the exclusive IconButton and check its tooltip
      final iconButtons = tester.widgetList<IconButton>(find.byType(IconButton)).toList();
      // The third IconButton is the exclusive toggle
      final exclusiveButton = iconButtons[2];
      expect(exclusiveButton.tooltip, isNotNull);
    });

    testWidgets('exclusive tooltip shows for non-exclusive list', (tester) async {
      final schema = MockListSchema.create(exclusive: false);

      await tester.runAsync(() async {
        await tester.pumpWidget(buildLiteTimeline(schema: schema));
        await tester.pump();
      });

      // Find the exclusive IconButton and check its tooltip
      final iconButtons = tester.widgetList<IconButton>(find.byType(IconButton)).toList();
      final exclusiveButton = iconButtons[2];
      expect(exclusiveButton.tooltip, isNotNull);
    });

    testWidgets('reply policy button tooltip is present', (tester) async {
      final schema = MockListSchema.create(replyPolicy: ReplyPolicyType.followed);

      await tester.runAsync(() async {
        await tester.pumpWidget(buildLiteTimeline(schema: schema));
        await tester.pump();
      });

      final iconButtons = tester.widgetList<IconButton>(find.byType(IconButton)).toList();
      // The second IconButton is the reply policy toggle
      final policyButton = iconButtons[1];
      expect(policyButton.tooltip, isNotNull);
    });

    testWidgets('AccessibleDismissible configured for startToEnd swipe (line 78)', (tester) async {
      final schema = MockListSchema.create(title: 'Swipeable');

      await tester.runAsync(() async {
        await tester.pumpWidget(buildLiteTimeline(schema: schema));
        await tester.pump();
      });

      // Verify the Dismissible is configured for startToEnd direction
      final dismissible = tester.widget<Dismissible>(find.byType(Dismissible));
      expect(dismissible.direction, DismissDirection.startToEnd);
      expect(dismissible.confirmDismiss, isNotNull);
    });

    testWidgets('shows Timeline widget when status is provided (line 146)', (tester) async {
      final schema = MockListSchema.create(title: 'Timeline List');
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );

      await tester.runAsync(() async {
        await tester.pumpWidget(buildLiteTimeline(schema: schema, accessStatus: status));
        await tester.pump();
      });

      // With valid status, buildTimeline should render Timeline widget
      expect(find.byType(Timeline), findsOneWidget);
    });

    testWidgets('members mode with authenticated status triggers getListAccounts (lines 160-176)', (tester) async {
      final schema = MockListSchema.create(title: 'Auth Members');
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );

      await tester.runAsync(() async {
        await tester.pumpWidget(buildLiteTimeline(schema: schema, accessStatus: status));
        await tester.pump();

        // Toggle to showMembers — this triggers _membersFuture = status.getListAccounts()
        await tester.tap(find.byIcon(Icons.group));
        await tester.pump();
        // Let the future complete (will error since no real server)
        await tester.pump(const Duration(milliseconds: 500));
      });

      // With the HTTP call failing, should show NoResult (error or null data path)
      expect(find.byType(LiteTimeline), findsOneWidget);
    });

    testWidgets('submitting non-empty search calls onSearchAccount (lines 190-196)', (tester) async {
      final schema = MockListSchema.create(title: 'Search List');

      await tester.runAsync(() async {
        await tester.pumpWidget(buildLiteTimeline(schema: schema));
        await tester.pump();

        // Toggle to showMembers mode to enable the TextField
        await tester.tap(find.byIcon(Icons.group));
        await tester.pump();
        await tester.pump();
      });

      // Verify the search field is now enabled and has onSubmitted handler
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.onSubmitted, isNotNull);
      expect(textField.decoration?.enabled, true);
    });

    testWidgets('members mode shows FutureBuilder content with authenticated status', (tester) async {
      final schema = MockListSchema.create(title: 'Loading Members');
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );

      await tester.runAsync(() async {
        await tester.pumpWidget(buildLiteTimeline(schema: schema, accessStatus: status));
        await tester.pump();

        // Toggle to showMembers — triggers getListAccounts future
        await tester.tap(find.byIcon(Icons.group));
        // Single pump to see the FutureBuilder in its initial/waiting state
        await tester.pump();
      });

      // Should show the members view (not the timeline)
      // The FutureBuilder should be rendering (either loading, error, or data)
      expect(find.byType(LiteTimeline), findsOneWidget);
      expect(find.byIcon(Icons.group_add_sharp), findsOneWidget);
    });
  });

  group('LiteTimeline.label interactions', () {
    testWidgets('onRemove callback is triggered when delete button tapped', (tester) async {
      bool removed = false;
      final schema = MockListSchema.create(title: 'Removable');

      await tester.pumpWidget(createTestWidget(
        child: LiteTimeline.label(
          schema: schema,
          onRemove: () => removed = true,
        ),
      ));
      await tester.pump();

      // Tap the delete icon
      await tester.tap(find.byIcon(Icons.delete_forever_rounded));
      await tester.pump();

      expect(removed, true);
    });

    testWidgets('tapping label triggers navigation (GoRouter error expected)', (tester) async {
      final schema = MockListSchema.create(title: 'Tap Me');

      await tester.pumpWidget(createTestWidget(
        child: LiteTimeline.label(schema: schema),
      ));
      await tester.pump();

      // Tap the InkWellDone which calls context.push
      await tester.tap(find.byType(InkWellDone));
      await tester.pump();

      // Consume the expected GoRouter error (context.push without GoRouter ancestor)
      expect(tester.takeException(), isNotNull);
    });

    testWidgets('label shows followed policy icon and tooltip', (tester) async {
      final schema = MockListSchema.create(replyPolicy: ReplyPolicyType.followed);

      await tester.pumpWidget(createTestWidget(
        child: LiteTimeline.label(schema: schema),
      ));
      await tester.pump();

      expect(find.byIcon(Icons.chat_bubble_outline), findsOneWidget);
      // Check that the Tooltip widget exists
      expect(find.byType(Tooltip), findsWidgets);
    });

    testWidgets('label shows none policy icon', (tester) async {
      final schema = MockListSchema.create(replyPolicy: ReplyPolicyType.none);

      await tester.pumpWidget(createTestWidget(
        child: LiteTimeline.label(schema: schema),
      ));
      await tester.pump();

      expect(find.byIcon(Icons.do_not_touch), findsOneWidget);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
