// Widget tests for ReportStep, ReportCategoryType, and ReportDialog components.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  setupTestEnvironment();

  group('ReportStep', () {
    test('has 3 values', () {
      expect(ReportStep.values.length, 3);
    });

    test('values are status, rules, comment', () {
      expect(ReportStep.values, contains(ReportStep.status));
      expect(ReportStep.values, contains(ReportStep.rules));
      expect(ReportStep.values, contains(ReportStep.comment));
    });
  });

  group('ReportCategoryType', () {
    test('has 4 values', () {
      expect(ReportCategoryType.values.length, 4);
    });

    test('values are spam, legal, violation, other', () {
      expect(ReportCategoryType.values, contains(ReportCategoryType.spam));
      expect(ReportCategoryType.values, contains(ReportCategoryType.legal));
      expect(ReportCategoryType.values, contains(ReportCategoryType.violation));
      expect(ReportCategoryType.values, contains(ReportCategoryType.other));
    });

    test('each type has an icon', () {
      expect(ReportCategoryType.spam.icon, Icons.campaign);
      expect(ReportCategoryType.legal.icon, Icons.gavel);
      expect(ReportCategoryType.violation.icon, Icons.rule);
      expect(ReportCategoryType.other.icon, Icons.report_sharp);
    });

    testWidgets('each type has label()', (tester) async {
      late BuildContext capturedContext;
      await tester.pumpWidget(createTestWidget(
        child: Builder(builder: (context) {
          capturedContext = context;
          return const SizedBox.shrink();
        }),
      ));
      await tester.pump();

      for (final type in ReportCategoryType.values) {
        expect(type.label(capturedContext), isNotEmpty);
      }
    });

    testWidgets('each type has tooltip()', (tester) async {
      late BuildContext capturedContext;
      await tester.pumpWidget(createTestWidget(
        child: Builder(builder: (context) {
          capturedContext = context;
          return const SizedBox.shrink();
        }),
      ));
      await tester.pump();

      for (final type in ReportCategoryType.values) {
        expect(type.tooltip(capturedContext), isNotEmpty);
      }
    });
  });

  group('ReportDialog', () {
    testWidgets('renders with authenticated user', (tester) async {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );
      final account = MockAccount.create();
      final mockStatus = MockStatus.create();

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(
            body: Builder(builder: (context) {
              return ReportDialog(
                account: account,
                status: mockStatus,
              );
            }),
          ),
          accessStatus: status,
        ));
        await tester.pump();
      });

      expect(find.byType(ReportDialog), findsOneWidget);
    });

    testWidgets('returns empty when not signed in', (tester) async {
      final account = MockAccount.create();
      final mockStatus = MockStatus.create();

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(
            body: ReportDialog(
              account: account,
              status: mockStatus,
            ),
          ),
          accessStatus: MockAccessStatus.anonymous(),
        ));
        await tester.pump();
      });

      // When status is null (anonymous), returns SizedBox.shrink
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('shows category selection initially', (tester) async {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );
      final account = MockAccount.create();
      final mockStatus = MockStatus.create();

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(
            body: ReportDialog(
              account: account,
              status: mockStatus,
            ),
          ),
          accessStatus: status,
        ));
        await tester.pump();
      });

      // Category selection shows ListTile for each category type
      expect(find.byType(ListTile), findsWidgets);
      // Category icons should be visible
      expect(find.byIcon(Icons.campaign), findsOneWidget);
      expect(find.byIcon(Icons.gavel), findsOneWidget);
      expect(find.byIcon(Icons.report_sharp), findsOneWidget);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
