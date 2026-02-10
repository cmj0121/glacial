// Widget tests for ServerExplorer.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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
  });
}

// vim: set ts=2 sw=2 sts=2 et:
