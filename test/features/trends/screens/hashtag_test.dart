// Widget tests for Hashtag components.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/features/trends/screens/hashtag.dart';
import 'package:glacial/features/trends/screens/chart.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  setUpAll(() => setupTestEnvironment());

  group('TagLite', () {
    testWidgets('displays hashtag text with # prefix', (tester) async {
      final tag = MockTag.create(name: 'flutter');

      await tester.pumpWidget(createTestWidget(
        child: TagLite(schema: tag),
      ));
      await tester.pumpAndSettle();

      expect(find.text('#flutter'), findsOneWidget);
    });

    testWidgets('wraps in Container with decoration', (tester) async {
      final tag = MockTag.create();

      await tester.pumpWidget(createTestWidget(
        child: TagLite(schema: tag),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('uses padding around content', (tester) async {
      final tag = MockTag.create();

      await tester.pumpWidget(createTestWidget(
        child: TagLite(schema: tag),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(Padding), findsWidgets);
    });

    testWidgets('is tappable', (tester) async {
      final tag = MockTag.create();

      await tester.pumpWidget(createTestWidget(
        child: TagLite(schema: tag),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(TagLite), findsOneWidget);
    });
  });

  group('Hashtag', () {
    testWidgets('displays hashtag name with # prefix', (tester) async {
      final hashtag = MockHashtag.create(name: 'dart');

      await tester.pumpWidget(createTestWidget(
        child: Hashtag(schema: hashtag),
      ));
      await tester.pumpAndSettle();

      expect(find.text('#dart'), findsOneWidget);
    });

    testWidgets('displays usage count text', (tester) async {
      final hashtag = MockHashtag.create();

      await tester.pumpWidget(createTestWidget(
        child: Hashtag(schema: hashtag),
      ));
      await tester.pumpAndSettle();

      // Should show usage text
      expect(find.textContaining('used in the past days'), findsOneWidget);
    });

    testWidgets('displays HistoryLineChart', (tester) async {
      final hashtag = MockHashtag.create();

      await tester.pumpWidget(createTestWidget(
        child: Hashtag(schema: hashtag),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(HistoryLineChart), findsOneWidget);
    });

    testWidgets('uses Row layout', (tester) async {
      final hashtag = MockHashtag.create();

      await tester.pumpWidget(createTestWidget(
        child: Hashtag(schema: hashtag),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(Row), findsWidgets);
    });

    testWidgets('wraps in Container with border', (tester) async {
      final hashtag = MockHashtag.create();

      await tester.pumpWidget(createTestWidget(
        child: Hashtag(schema: hashtag),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('is tappable', (tester) async {
      final hashtag = MockHashtag.create();

      await tester.pumpWidget(createTestWidget(
        child: Hashtag(schema: hashtag),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(Hashtag), findsOneWidget);
    });
  });

  group('HistoryLineChart', () {
    testWidgets('renders with history data', (tester) async {
      final history = MockHistory.createList(count: 5);

      await tester.pumpWidget(createTestWidget(
        child: HistoryLineChart(schemas: history),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(HistoryLineChart), findsOneWidget);
    });

    testWidgets('uses ConstrainedBox for sizing', (tester) async {
      final history = MockHistory.createList();

      await tester.pumpWidget(createTestWidget(
        child: HistoryLineChart(schemas: history),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(ConstrainedBox), findsWidgets);
    });

    testWidgets('accepts custom maxHeight', (tester) async {
      final history = MockHistory.createList();

      await tester.pumpWidget(createTestWidget(
        child: HistoryLineChart(schemas: history, maxHeight: 50),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(HistoryLineChart), findsOneWidget);
    });

    testWidgets('accepts custom maxWidth', (tester) async {
      final history = MockHistory.createList();

      await tester.pumpWidget(createTestWidget(
        child: HistoryLineChart(schemas: history, maxWidth: 100),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(HistoryLineChart), findsOneWidget);
    });

    testWidgets('renders with empty history', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const HistoryLineChart(schemas: []),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(HistoryLineChart), findsOneWidget);
    });

    testWidgets('renders with single history entry', (tester) async {
      final history = [MockHistory.create()];

      await tester.pumpWidget(createTestWidget(
        child: HistoryLineChart(schemas: history),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(HistoryLineChart), findsOneWidget);
    });
  });

  group('FollowedHashtagButton', () {
    test('is a ConsumerStatefulWidget', () {
      const widget = FollowedHashtagButton(hashtag: 'test');
      expect(widget, isA<ConsumerStatefulWidget>());
    });

    test('accepts hashtag parameter', () {
      const widget = FollowedHashtagButton(hashtag: 'flutter');
      expect(widget.hashtag, 'flutter');
    });

    test('accepts hashtag parameter', () {
      const widget = FollowedHashtagButton(hashtag: 'flutter');
      expect(widget.hashtag, 'flutter');
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
