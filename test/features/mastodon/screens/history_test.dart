// Widget tests for history screens: HistoryDrawer.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/features/screens.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  setupTestEnvironment();

  group('HistoryDrawer', () {
    testWidgets('renders Drawer widget', (tester) async {
      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          drawer: const HistoryDrawer(),
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                child: const Text('Open'),
              );
            },
          ),
        ),
      ));
      await tester.pump();

      // Open the drawer
      await tester.tap(find.text('Open'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(Drawer), findsOneWidget);
    });

    testWidgets('shows title text', (tester) async {
      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          drawer: const HistoryDrawer(),
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                child: const Text('Open'),
              );
            },
          ),
        ),
      ));
      await tester.pump();

      await tester.tap(find.text('Open'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Search History'), findsOneWidget);
    });

    testWidgets('shows clear button with cleaning_services icon', (tester) async {
      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          drawer: const HistoryDrawer(),
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                child: const Text('Open'),
              );
            },
          ),
        ),
      ));
      await tester.pump();

      await tester.tap(find.text('Open'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byIcon(Icons.cleaning_services), findsOneWidget);
      expect(find.text('Clear'), findsOneWidget);
    });

    testWidgets('accepts onTap callback', (tester) async {
      String? tappedDomain;

      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          drawer: HistoryDrawer(onTap: (domain) => tappedDomain = domain),
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                child: const Text('Open'),
              );
            },
          ),
        ),
      ));
      await tester.pump();

      await tester.tap(find.text('Open'));
      await tester.pump(const Duration(milliseconds: 300));

      // onTap is not called until a history item is tapped
      expect(tappedDomain, isNull);
      expect(find.byType(HistoryDrawer), findsOneWidget);
    });

    testWidgets('shows empty list when no history', (tester) async {
      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          drawer: const HistoryDrawer(),
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                child: const Text('Open'),
              );
            },
          ),
        ),
      ));
      await tester.pump();

      await tester.tap(find.text('Open'));
      await tester.pump(const Duration(milliseconds: 300));

      // MockAccessStatus doesn't set history, so list is empty
      expect(find.byType(ReorderableListView), findsOneWidget);
      // No MastodonServerInfo items should be present
      expect(find.byType(MastodonServerInfo), findsNothing);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
