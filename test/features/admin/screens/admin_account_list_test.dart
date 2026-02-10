// Widget tests for AdminAccountList and AdminAccountStatus.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  setupTestEnvironment();

  group('AdminAccountList', () {
    late AccessStatusSchema status;

    setUp(() {
      status = MockAccessStatus.authenticated(server: MockServer.create());
    });

    test('is a StatefulWidget', () {
      final widget = AdminAccountList(status: status);
      expect(widget, isA<StatefulWidget>());
    });

    test('takes required status parameter', () {
      final widget = AdminAccountList(status: status);
      expect(widget.status, status);
    });

    testWidgets('renders with status parameter', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: AdminAccountList(status: status)),
        ));
        await tester.pump();
      });

      expect(find.byType(AdminAccountList), findsOneWidget);
    });

    testWidgets('shows "All" filter chip selected by default', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: AdminAccountList(status: status)),
        ));
        await tester.pump();
      });

      final Finder allChip = find.widgetWithText(FilterChip, 'Search');
      expect(allChip, findsOneWidget);

      final FilterChip chip = tester.widget<FilterChip>(allChip);
      expect(chip.selected, isTrue);
    });

    testWidgets('shows filter chips for each AdminAccountStatus', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: AdminAccountList(status: status)),
        ));
        await tester.pump();
      });

      // "All" + 5 status chips = 6 total
      expect(find.byType(FilterChip), findsNWidgets(6));

      expect(find.text('Active'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('Disabled'), findsOneWidget);
      expect(find.text('Silenced'), findsOneWidget);
      expect(find.text('Suspended'), findsOneWidget);
    });

    testWidgets('has Column layout with filter chips and content area', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: AdminAccountList(status: status)),
        ));
        await tester.pump();
      });

      expect(find.byType(Column), findsWidgets);
      expect(find.byType(Align), findsWidgets);
    });

    testWidgets('status chips besides All are not selected by default', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: AdminAccountList(status: status)),
        ));
        await tester.pump();
      });

      for (final label in ['Active', 'Pending', 'Disabled', 'Silenced', 'Suspended']) {
        final Finder chipFinder = find.widgetWithText(FilterChip, label);
        expect(chipFinder, findsOneWidget);

        final FilterChip chip = tester.widget<FilterChip>(chipFinder);
        expect(chip.selected, isFalse, reason: '$label should not be selected by default');
      }
    });
  });

  group('AdminAccountStatus', () {
    test('has 5 values', () {
      expect(AdminAccountStatus.values.length, 5);
    });

    test('contains active, pending, disabled, silenced, suspended', () {
      expect(AdminAccountStatus.values, contains(AdminAccountStatus.active));
      expect(AdminAccountStatus.values, contains(AdminAccountStatus.pending));
      expect(AdminAccountStatus.values, contains(AdminAccountStatus.disabled));
      expect(AdminAccountStatus.values, contains(AdminAccountStatus.silenced));
      expect(AdminAccountStatus.values, contains(AdminAccountStatus.suspended));
    });

    test('values are in expected order', () {
      expect(AdminAccountStatus.values[0], AdminAccountStatus.active);
      expect(AdminAccountStatus.values[1], AdminAccountStatus.pending);
      expect(AdminAccountStatus.values[2], AdminAccountStatus.disabled);
      expect(AdminAccountStatus.values[3], AdminAccountStatus.silenced);
      expect(AdminAccountStatus.values[4], AdminAccountStatus.suspended);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
