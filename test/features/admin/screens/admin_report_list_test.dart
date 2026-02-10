// Widget tests for AdminReportList.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  setupTestEnvironment();

  group('AdminReportList', () {
    late AccessStatusSchema status;

    setUp(() {
      status = MockAccessStatus.authenticated(server: MockServer.create());
    });

    test('is a StatefulWidget', () {
      final widget = AdminReportList(status: status);
      expect(widget, isA<StatefulWidget>());
    });

    test('takes required status parameter', () {
      final widget = AdminReportList(status: status);
      expect(widget.status, status);
    });

    testWidgets('renders with status parameter', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: AdminReportList(status: status)),
        ));
        await tester.pump();
      });

      expect(find.byType(AdminReportList), findsOneWidget);
    });

    testWidgets('shows filter chips (Unresolved and Resolved)', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: AdminReportList(status: status)),
        ));
        await tester.pump();
      });

      expect(find.byType(FilterChip), findsNWidgets(2));
      expect(find.text('Unresolved'), findsOneWidget);
      expect(find.text('Resolved'), findsOneWidget);
    });

    testWidgets('Unresolved chip is selected by default', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: AdminReportList(status: status)),
        ));
        await tester.pump();
      });

      final Finder unresolvedChip = find.widgetWithText(FilterChip, 'Unresolved');
      expect(unresolvedChip, findsOneWidget);

      final FilterChip chip = tester.widget<FilterChip>(unresolvedChip);
      expect(chip.selected, isTrue);
    });

    testWidgets('Resolved chip is not selected by default', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: AdminReportList(status: status)),
        ));
        await tester.pump();
      });

      final Finder resolvedChip = find.widgetWithText(FilterChip, 'Resolved');
      expect(resolvedChip, findsOneWidget);

      final FilterChip chip = tester.widget<FilterChip>(resolvedChip);
      expect(chip.selected, isFalse);
    });

    testWidgets('has Column layout with filter chips and content area', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: AdminReportList(status: status)),
        ));
        await tester.pump();
      });

      expect(find.byType(Column), findsWidgets);
      expect(find.byType(Align), findsWidgets);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
