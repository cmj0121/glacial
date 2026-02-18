// Widget tests for search screens: SearchExplorer, ExplorerTab.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/screens.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  setupTestEnvironment();

  group('SearchExplorer', () {
    testWidgets('renders search icon when not expanded', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const SearchExplorer(),
        accessStatus: MockAccessStatus.authenticated(),
      ));
      await tester.pump();

      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('search icon is disabled when not signed in', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const SearchExplorer(),
        accessStatus: MockAccessStatus.anonymous(),
      ));
      await tester.pump();

      // Find the IconButton wrapping the search icon
      final iconButton = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.search),
      );
      expect(iconButton.onPressed, isNull);
    });

    testWidgets('search icon is enabled when signed in', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const SearchExplorer(),
        accessStatus: MockAccessStatus.authenticated(),
      ));
      await tester.pump();

      final iconButton = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.search),
      );
      expect(iconButton.onPressed, isNotNull);
    });

    testWidgets('expands to text field on tap', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const SearchExplorer(),
        accessStatus: MockAccessStatus.authenticated(),
      ));
      await tester.pump();

      // Tap the search icon to expand
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets('collapses when clear button tapped', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const SearchExplorer(),
        accessStatus: MockAccessStatus.authenticated(),
      ));
      await tester.pump();

      // Expand
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Tap clear to collapse
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('respects custom size parameter', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const SearchExplorer(size: 32),
        accessStatus: MockAccessStatus.authenticated(),
      ));
      await tester.pump();

      final icon = tester.widget<Icon>(find.byIcon(Icons.search));
      expect(icon.size, 32);
    });

    testWidgets('accepts maxWidth parameter', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const SearchExplorer(maxWidth: 200),
        accessStatus: MockAccessStatus.authenticated(),
      ));
      await tester.pump();

      expect(find.byType(SearchExplorer), findsOneWidget);
    });
  });

  group('ExplorerTab', () {
    testWidgets('shows loading indicator initially', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: ExplorerTab(keyword: 'test')),
          accessStatus: MockAccessStatus.authenticated(),
        ));
        await tester.pump();
      });

      expect(find.byType(LoadingOverlay), findsOneWidget);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
