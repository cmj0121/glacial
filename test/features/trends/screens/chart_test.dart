// Widget tests for trends chart: HistoryLineChart.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:glacial/features/screens.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  setupTestEnvironment();

  group('HistoryLineChart', () {
    testWidgets('renders with valid data', (tester) async {
      final schemas = MockHistory.createList(count: 7);

      await tester.pumpWidget(createTestWidget(
        child: HistoryLineChart(schemas: schemas),
      ));
      await tester.pump();

      expect(find.byType(HistoryLineChart), findsOneWidget);
      expect(find.byType(LineChart), findsOneWidget);
    });

    testWidgets('renders with empty data', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const HistoryLineChart(schemas: []),
      ));
      await tester.pump();

      expect(find.byType(HistoryLineChart), findsOneWidget);
    });

    testWidgets('renders with single data point', (tester) async {
      final schemas = [MockHistory.create(day: '1', uses: '10')];

      await tester.pumpWidget(createTestWidget(
        child: HistoryLineChart(schemas: schemas),
      ));
      await tester.pump();

      expect(find.byType(LineChart), findsOneWidget);
    });

    testWidgets('applies default constraints', (tester) async {
      final schemas = MockHistory.createList(count: 3);

      await tester.pumpWidget(createTestWidget(
        child: HistoryLineChart(schemas: schemas),
      ));
      await tester.pump();

      final finder = find.descendant(
        of: find.byType(HistoryLineChart),
        matching: find.byType(ConstrainedBox),
      );
      final box = tester.widget<ConstrainedBox>(finder);
      expect(box.constraints.maxHeight, 30);
      expect(box.constraints.maxWidth, 80);
    });

    testWidgets('accepts custom maxHeight and maxWidth', (tester) async {
      final schemas = MockHistory.createList(count: 3);

      await tester.pumpWidget(createTestWidget(
        child: HistoryLineChart(
          schemas: schemas,
          maxHeight: 60,
          maxWidth: 120,
        ),
      ));
      await tester.pump();

      final finder = find.descendant(
        of: find.byType(HistoryLineChart),
        matching: find.byType(ConstrainedBox),
      );
      final box = tester.widget<ConstrainedBox>(finder);
      expect(box.constraints.maxHeight, 60);
      expect(box.constraints.maxWidth, 120);
    });

    testWidgets('wraps chart in ConstrainedBox', (tester) async {
      final schemas = MockHistory.createList(count: 5);

      await tester.pumpWidget(createTestWidget(
        child: HistoryLineChart(schemas: schemas),
      ));
      await tester.pump();

      final finder = find.descendant(
        of: find.byType(HistoryLineChart),
        matching: find.byType(ConstrainedBox),
      );
      expect(finder, findsOneWidget);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
