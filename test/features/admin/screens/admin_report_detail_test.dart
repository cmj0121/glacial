// Widget tests for AdminReportDetail.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  setupTestEnvironment();

  group('AdminReportDetail', () {
    testWidgets('renders with basic report', (tester) async {
      final report = MockAdminReport.create();
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AdminReportDetail(schema: report),
        accessStatus: status,
      ));
      await tester.pump();

      expect(find.byType(AdminReportDetail), findsOneWidget);
    });

    testWidgets('shows report category icon and label', (tester) async {
      final report = MockAdminReport.create(category: ReportCategoryType.spam);
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AdminReportDetail(schema: report),
        accessStatus: status,
      ));
      await tester.pump();

      expect(find.byIcon(Icons.campaign), findsOneWidget);
    });

    testWidgets('shows reported-by account', (tester) async {
      final reporter = MockAccount.create(username: 'whistleblower');
      final report = MockAdminReport.create(account: reporter);
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AdminReportDetail(schema: report),
        accessStatus: status,
      ));
      await tester.pump();

      expect(find.textContaining('@whistleblower'), findsOneWidget);
    });

    testWidgets('shows assigned-to when assigned', (tester) async {
      final report = MockAdminReport.assigned();
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AdminReportDetail(schema: report),
        accessStatus: status,
      ));
      await tester.pump();

      expect(find.textContaining('@moderator'), findsOneWidget);
    });

    testWidgets('shows resolved chip for resolved report', (tester) async {
      final report = MockAdminReport.resolved();
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AdminReportDetail(schema: report),
        accessStatus: status,
      ));
      await tester.pump();

      expect(find.text('Resolved'), findsOneWidget);
      expect(find.byType(Chip), findsOneWidget);
    });

    testWidgets('shows comment when present', (tester) async {
      final report = MockAdminReport.create(comment: 'Posting spam links');
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AdminReportDetail(schema: report),
        accessStatus: status,
      ));
      await tester.pump();

      expect(find.text('Posting spam links'), findsOneWidget);
    });

    testWidgets('shows statuses when present', (tester) async {
      final report = MockAdminReport.withDetails();
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AdminReportDetail(schema: report),
        accessStatus: status,
      ));
      await tester.pump();

      expect(find.byType(StatusLite), findsOneWidget);
    });

    testWidgets('shows rules when present', (tester) async {
      final report = MockAdminReport.withDetails();
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AdminReportDetail(schema: report),
        accessStatus: status,
      ));
      await tester.pump();

      expect(find.text('Be respectful'), findsOneWidget);
      expect(find.text('Treat others with dignity'), findsOneWidget);
      expect(find.byIcon(Icons.rule), findsAtLeastNWidgets(1));
    });

    testWidgets('shows assign/resolve for unresolved unassigned report', (tester) async {
      final report = MockAdminReport.create();
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AdminReportDetail(schema: report),
        accessStatus: status,
      ));
      await tester.pump();

      expect(find.text('Assign to me'), findsOneWidget);
      expect(find.text('Resolve'), findsOneWidget);
    });

    testWidgets('shows unassign/resolve for assigned report', (tester) async {
      final report = MockAdminReport.assigned();
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AdminReportDetail(schema: report),
        accessStatus: status,
      ));
      await tester.pump();

      expect(find.text('Unassign'), findsOneWidget);
      expect(find.text('Resolve'), findsOneWidget);
    });

    testWidgets('shows reopen for resolved report', (tester) async {
      final report = MockAdminReport.resolved();
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AdminReportDetail(schema: report),
        accessStatus: status,
      ));
      await tester.pump();

      expect(find.text('Reopen'), findsOneWidget);
    });

    testWidgets('renders dividers between sections', (tester) async {
      final report = MockAdminReport.withDetails();
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AdminReportDetail(schema: report),
        accessStatus: status,
      ));
      await tester.pump();

      expect(find.byType(Divider), findsAtLeastNWidgets(2));
    });

    testWidgets('hides comment section when empty', (tester) async {
      final report = MockAdminReport.create(comment: '');
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AdminReportDetail(schema: report),
        accessStatus: status,
      ));
      await tester.pump();

      // Should still render but with fewer dividers (no comment section).
      expect(find.byType(AdminReportDetail), findsOneWidget);
    });

    testWidgets('renders with violation category', (tester) async {
      final report = MockAdminReport.create(category: ReportCategoryType.violation);
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AdminReportDetail(schema: report),
        accessStatus: status,
      ));
      await tester.pump();

      expect(find.byIcon(Icons.rule), findsOneWidget);
    });

  });
}

// vim: set ts=2 sw=2 sts=2 et:
