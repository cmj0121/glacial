// Widget tests for history screens: HistoryDrawer.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';
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

    testWidgets('shows history items when history is present', (tester) async {
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.toString().contains('overflowed')) return;
        originalOnError?.call(details);
      };

      final status = AccessStatusSchema(
        domain: 'mastodon.social',
        history: const [
          ServerInfoSchema(domain: 'one.social', thumbnail: 'https://example.com/1.png'),
          ServerInfoSchema(domain: 'two.social', thumbnail: 'https://example.com/2.png'),
        ],
      );

      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          drawer: const HistoryDrawer(),
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
              child: const Text('Open'),
            ),
          ),
        ),
        accessStatus: status,
      ));
      await tester.pump();

      await tester.tap(find.text('Open'));
      await tester.pump(const Duration(milliseconds: 300));

      // Should show 2 MastodonServerInfo items (line 72)
      expect(find.byType(MastodonServerInfo), findsNWidgets(2));
      // Should show AccessibleDismissible for each item (line 77)
      expect(find.byType(AccessibleDismissible), findsNWidgets(2));

      FlutterError.onError = originalOnError;
    });

    testWidgets('history item ListTile has onTap set', (tester) async {
      // Suppress RenderFlex overflow errors from MastodonServerInfo Row
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.toString().contains('overflowed')) return;
        originalOnError?.call(details);
      };

      final status = AccessStatusSchema(
        domain: 'mastodon.social',
        history: const [
          ServerInfoSchema(domain: 'tapped.social', thumbnail: 'https://example.com/t.png'),
        ],
      );

      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          drawer: HistoryDrawer(onTap: (domain) {}),
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
              child: const Text('Open'),
            ),
          ),
        ),
        accessStatus: status,
      ));
      await tester.pump();

      await tester.tap(find.text('Open'));
      await tester.pump(const Duration(milliseconds: 300));

      // ListTile for history item should have onTap set (line 74)
      final listTiles = tester.widgetList<ListTile>(find.byType(ListTile));
      // Find the one that has MastodonServerInfo as title
      final historyTile = listTiles.where((tile) => tile.title is MastodonServerInfo);
      expect(historyTile.isNotEmpty, isTrue);
      expect(historyTile.first.onTap, isNotNull);

      FlutterError.onError = originalOnError;
    });

    testWidgets('clear button is present and has correct icon', (tester) async {
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.toString().contains('overflowed')) return;
        originalOnError?.call(details);
      };

      final status = AccessStatusSchema(
        domain: 'mastodon.social',
        history: const [
          ServerInfoSchema(domain: 'one.social', thumbnail: 'https://example.com/1.png'),
        ],
      );

      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          drawer: const HistoryDrawer(),
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
              child: const Text('Open'),
            ),
          ),
        ),
        accessStatus: status,
      ));
      await tester.pump();

      await tester.tap(find.text('Open'));
      await tester.pump(const Duration(milliseconds: 300));

      // History item should render (line 69-74)
      expect(find.byType(MastodonServerInfo), findsOneWidget);

      // Clear button should be present (line 54-59)
      expect(find.text('Clear'), findsOneWidget);
      expect(find.byIcon(Icons.cleaning_services), findsOneWidget);

      FlutterError.onError = originalOnError;
    });

    testWidgets('history items are wrapped in ReorderableListView', (tester) async {
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.toString().contains('overflowed')) return;
        originalOnError?.call(details);
      };

      final status = AccessStatusSchema(
        domain: 'mastodon.social',
        history: const [
          ServerInfoSchema(domain: 'a.social', thumbnail: 'https://example.com/a.png'),
          ServerInfoSchema(domain: 'b.social', thumbnail: 'https://example.com/b.png'),
          ServerInfoSchema(domain: 'c.social', thumbnail: 'https://example.com/c.png'),
        ],
      );

      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          drawer: const HistoryDrawer(),
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
              child: const Text('Open'),
            ),
          ),
        ),
        accessStatus: status,
      ));
      await tester.pump();

      await tester.tap(find.text('Open'));
      await tester.pump(const Duration(milliseconds: 300));

      // ReorderableListView renders the history items (line 67-94)
      expect(find.byType(ReorderableListView), findsOneWidget);
      expect(find.byType(MastodonServerInfo), findsNWidgets(3));

      FlutterError.onError = originalOnError;
    });

    testWidgets('history drawer has Divider', (tester) async {
      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          drawer: const HistoryDrawer(),
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
              child: const Text('Open'),
            ),
          ),
        ),
      ));
      await tester.pump();

      await tester.tap(find.text('Open'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(Divider), findsOneWidget);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
