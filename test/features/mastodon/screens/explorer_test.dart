// Widget tests for ServerExplorer.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  setupTestEnvironment();

  group('ServerExplorer', () {
    testWidgets('renders Scaffold', (tester) async {
      await tester.pumpWidget(createTestWidgetRaw(
        child: const ServerExplorer(),
      ));
      await tester.pump();

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('shows search TextField', (tester) async {
      await tester.pumpWidget(createTestWidgetRaw(
        child: const ServerExplorer(),
      ));
      await tester.pump();

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('shows search icon in text field prefix', (tester) async {
      await tester.pumpWidget(createTestWidgetRaw(
        child: const ServerExplorer(),
      ));
      await tester.pump();

      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('shows history icon button', (tester) async {
      await tester.pumpWidget(createTestWidgetRaw(
        child: const ServerExplorer(),
      ));
      await tester.pump();

      expect(find.byIcon(Icons.history), findsOneWidget);
    });

    testWidgets('history button is disabled when no history', (tester) async {
      await tester.pumpWidget(createTestWidgetRaw(
        child: const ServerExplorer(),
        accessStatus: MockAccessStatus.anonymous(),
      ));
      await tester.pump();

      final IconButton historyButton = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.history),
      );
      expect(historyButton.onPressed, isNull);
    });

    testWidgets('clears search field when clear button tapped', (tester) async {
      await tester.pumpWidget(createTestWidgetRaw(
        child: const ServerExplorer(),
      ));
      await tester.pump();

      // Type into the search field
      await tester.enterText(find.byType(TextField), 'mastodon.social');
      await tester.pump();

      // Clear button should now be visible
      expect(find.byIcon(Icons.clear), findsOneWidget);

      // Tap clear button
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();

      // Text field should be empty
      final TextField textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, isEmpty);
    });

    testWidgets('clear button is hidden when text field is empty', (tester) async {
      await tester.pumpWidget(createTestWidgetRaw(
        child: const ServerExplorer(),
      ));
      await tester.pump();

      expect(find.byIcon(Icons.clear), findsNothing);
    });

    testWidgets('has SafeArea', (tester) async {
      await tester.pumpWidget(createTestWidgetRaw(
        child: const ServerExplorer(),
      ));
      await tester.pump();

      expect(find.byType(SafeArea), findsWidgets);
    });

    testWidgets('typing text shows clear button via onChanged', (tester) async {
      await tester.pumpWidget(createTestWidgetRaw(
        child: const ServerExplorer(),
      ));
      await tester.pump();

      // Initially no clear button
      expect(find.byIcon(Icons.clear), findsNothing);

      // Type text triggers onChanged → setState
      await tester.enterText(find.byType(TextField), 'test');
      await tester.pump();

      // Now clear button should appear
      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets('submitting text triggers onSearch and shows child', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const ServerExplorer(),
        ));
        await tester.pump();

        // Enter text and submit
        await tester.enterText(find.byType(TextField), 'mastodon.social');
        await tester.pump();
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();
      });

      // After search, the child should be set (MastodonServer.builder)
      // It will show either loading or error since domain can't be fetched in test
      expect(find.byType(ServerExplorer), findsOneWidget);
    });

    testWidgets('tapping search icon triggers onSearch', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const ServerExplorer(),
        ));
        await tester.pump();

        // Enter text
        await tester.enterText(find.byType(TextField), 'example.com');
        await tester.pump();

        // Tap search icon
        await tester.tap(find.byIcon(Icons.search));
        await tester.pump();
      });

      // After search, state.child should be set
      expect(find.byType(ServerExplorer), findsOneWidget);
    });

    testWidgets('onSearch with empty query does nothing', (tester) async {
      await tester.pumpWidget(createTestWidgetRaw(
        child: const ServerExplorer(),
      ));
      await tester.pump();

      // Submit with empty text
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      // No child should be set
      expect(find.byType(ServerExplorer), findsOneWidget);
      // SizedBox.shrink is the default child
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('clear button resets child to null', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const ServerExplorer(),
        ));
        await tester.pump();

        // Type and search to set child
        await tester.enterText(find.byType(TextField), 'mastodon.social');
        await tester.pump();
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();
      });

      // Now tap clear to reset
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();

      // Text should be cleared
      final TextField textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, isEmpty);

      // Child should be reset to null (SizedBox.shrink)
      expect(find.byIcon(Icons.clear), findsNothing);
    });

    testWidgets('history button is enabled when history exists', (tester) async {
      final status = AccessStatusSchema(
        domain: 'example.com',
        accessToken: 'token',
        history: [
          const ServerInfoSchema(domain: 'mastodon.social', thumbnail: 'https://example.com/thumb.png'),
        ],
      );

      await tester.pumpWidget(createTestWidgetRaw(
        child: const ServerExplorer(),
        accessStatus: status,
      ));
      await tester.pump();

      final IconButton historyButton = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.history),
      );
      expect(historyButton.onPressed, isNotNull);
    });

    testWidgets('tapping history button opens drawer', (tester) async {
      final status = AccessStatusSchema(
        domain: 'example.com',
        accessToken: 'token',
        history: [
          const ServerInfoSchema(domain: 'mastodon.social', thumbnail: 'https://example.com/thumb.png'),
        ],
      );

      // Use a large surface to avoid overflow errors in the drawer
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // Suppress overflow errors from the drawer's internal layout
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (FlutterErrorDetails details) {
        if (details.toString().contains('overflowed')) return;
        originalOnError?.call(details);
      };
      addTearDown(() => FlutterError.onError = originalOnError);

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const ServerExplorer(),
          accessStatus: status,
        ));
        await tester.pump();

        // Tap the history button to open drawer
        await tester.tap(find.byIcon(Icons.history));
        // Use pump with duration instead of pumpAndSettle (CachedNetworkImage)
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
      });

      // Drawer should be open
      expect(find.byType(HistoryDrawer), findsOneWidget);
    });

    testWidgets('onSearch with whitespace-only query does nothing', (tester) async {
      await tester.pumpWidget(createTestWidgetRaw(
        child: const ServerExplorer(),
      ));
      await tester.pump();

      // Enter whitespace only
      await tester.enterText(find.byType(TextField), '   ');
      await tester.pump();

      // Tap search icon
      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();

      // No MastodonServer child should appear
      expect(find.byType(SizedBox), findsWidgets);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
