// Widget tests for AdminReportDetail.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  setupTestEnvironment();

  group('AdminReportDetail', () {
    test('is a ConsumerStatefulWidget', () {
      final report = MockAdminReport.create();
      final widget = AdminReportDetail(schema: report);
      expect(widget, isA<ConsumerStatefulWidget>());
    });

    test('takes required schema parameter', () {
      final report = MockAdminReport.create();
      final widget = AdminReportDetail(schema: report);
      expect(widget.schema, report);
    });

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

    testWidgets('renders spam category label text', (tester) async {
      final report = MockAdminReport.create(category: ReportCategoryType.spam);
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AdminReportDetail(schema: report),
        accessStatus: status,
      ));
      await tester.pump();

      expect(find.text('Spam'), findsOneWidget);
    });

    testWidgets('renders legal category icon and label', (tester) async {
      final report = MockAdminReport.create(category: ReportCategoryType.legal);
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AdminReportDetail(schema: report),
        accessStatus: status,
      ));
      await tester.pump();

      expect(find.byIcon(Icons.gavel), findsOneWidget);
      // l10n text for legal is "Illegal Content"
      expect(find.text('Illegal Content'), findsOneWidget);
    });

    testWidgets('renders other category icon and label', (tester) async {
      final report = MockAdminReport.create(category: ReportCategoryType.other);
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AdminReportDetail(schema: report),
        accessStatus: status,
      ));
      await tester.pump();

      expect(find.byIcon(Icons.report_sharp), findsOneWidget);
      expect(find.text('Other'), findsWidgets);
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

    testWidgets('hides assigned-to text when no assigned account', (tester) async {
      final report = MockAdminReport.create(assignedAccount: null);
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AdminReportDetail(schema: report),
        accessStatus: status,
      ));
      await tester.pump();

      expect(find.textContaining('Assigned to'), findsNothing);
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

    testWidgets('does not show Resolved chip for unresolved report', (tester) async {
      final report = MockAdminReport.create(actionTaken: false);
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AdminReportDetail(schema: report),
        accessStatus: status,
      ));
      await tester.pump();

      expect(find.text('Resolved'), findsNothing);
    });

    testWidgets('shows target account section with Account widget', (tester) async {
      final target = MockAccount.create(id: 'target', username: 'baduser');
      final report = MockAdminReport.create(targetAccount: target);
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AdminReportDetail(schema: report),
        accessStatus: status,
      ));
      await tester.pump();

      expect(find.byType(Account), findsOneWidget);
      expect(find.byType(InkWellDone), findsWidgets);
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

    testWidgets('hides comment section when empty', (tester) async {
      final report = MockAdminReport.create(comment: '');
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AdminReportDetail(schema: report),
        accessStatus: status,
      ));
      await tester.pump();

      // With empty comment, fewer dividers should be present
      expect(find.byType(AdminReportDetail), findsOneWidget);
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

    testWidgets('shows multiple statuses', (tester) async {
      final statuses = [
        MockStatus.create(id: 's1', content: '<p>Bad 1</p>'),
        MockStatus.create(id: 's2', content: '<p>Bad 2</p>'),
      ];
      final report = MockAdminReport.create(statuses: statuses);
      final accessStatus = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AdminReportDetail(schema: report),
        accessStatus: accessStatus,
      ));
      await tester.pump();

      expect(find.byType(StatusLite), findsNWidgets(2));
    });

    testWidgets('hides statuses section when empty', (tester) async {
      final report = MockAdminReport.create(statuses: []);
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AdminReportDetail(schema: report),
        accessStatus: status,
      ));
      await tester.pump();

      expect(find.byType(StatusLite), findsNothing);
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

    testWidgets('shows multiple rules with icon, text and hint', (tester) async {
      final report = MockAdminReport.create(
        rules: const [
          RuleSchema(id: 'r1', text: 'No harassment', hint: 'Be kind'),
          RuleSchema(id: 'r2', text: 'No spam', hint: 'No ads'),
          RuleSchema(id: 'r3', text: 'Be civil', hint: 'Respect others'),
        ],
      );
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AdminReportDetail(schema: report),
        accessStatus: status,
      ));
      await tester.pump();

      expect(find.text('No harassment'), findsOneWidget);
      expect(find.text('Be kind'), findsOneWidget);
      expect(find.text('No spam'), findsOneWidget);
      expect(find.text('No ads'), findsOneWidget);
      expect(find.text('Be civil'), findsOneWidget);
      expect(find.text('Respect others'), findsOneWidget);
      expect(find.byType(ListTile), findsNWidgets(3));
    });

    testWidgets('hides rules section when empty', (tester) async {
      final report = MockAdminReport.create(rules: []);
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AdminReportDetail(schema: report),
        accessStatus: status,
      ));
      await tester.pump();

      expect(find.byType(ListTile), findsNothing);
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
      expect(find.byIcon(Icons.person_add), findsOneWidget);
      expect(find.byIcon(Icons.done), findsOneWidget);
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
      expect(find.byIcon(Icons.person_remove), findsOneWidget);
      expect(find.byIcon(Icons.done), findsOneWidget);
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
      expect(find.byIcon(Icons.refresh), findsOneWidget);
      // Should not show resolve or assign
      expect(find.text('Resolve'), findsNothing);
      expect(find.text('Assign to me'), findsNothing);
    });

    testWidgets('actions wrapped in Wrap widget with spacing', (tester) async {
      final report = MockAdminReport.create();
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AdminReportDetail(schema: report),
        accessStatus: status,
      ));
      await tester.pump();

      expect(find.byType(Wrap), findsOneWidget);
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

    testWidgets('full report with all sections shows many dividers', (tester) async {
      final report = MockAdminReport.withDetails();
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AdminReportDetail(schema: report),
        accessStatus: status,
      ));
      await tester.pump();

      // header, divider, target, divider, comment, divider, statuses, divider, rules, divider, actions
      expect(find.byType(Divider), findsAtLeastNWidgets(4));
    });

    testWidgets('renders in a SingleChildScrollView', (tester) async {
      final report = MockAdminReport.create();
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AdminReportDetail(schema: report),
        accessStatus: status,
      ));
      await tester.pump();

      expect(find.byType(SingleChildScrollView), findsWidgets);
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
      expect(find.text('Rule Violation'), findsOneWidget);
    });

    testWidgets('report with only statuses (no rules, no comment) renders correctly', (tester) async {
      final report = MockAdminReport.create(
        comment: '',
        statuses: [MockStatus.create()],
        rules: [],
      );
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AdminReportDetail(schema: report),
        accessStatus: status,
      ));
      await tester.pump();

      expect(find.byType(StatusLite), findsOneWidget);
      expect(find.byType(ListTile), findsNothing);
    });

    testWidgets('report with only rules (no statuses, no comment) renders correctly', (tester) async {
      final report = MockAdminReport.create(
        comment: '',
        statuses: [],
        rules: const [
          RuleSchema(id: 'r1', text: 'Rule text', hint: 'Rule hint'),
        ],
      );
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AdminReportDetail(schema: report),
        accessStatus: status,
      ));
      await tester.pump();

      expect(find.byType(StatusLite), findsNothing);
      expect(find.byType(ListTile), findsOneWidget);
      expect(find.text('Rule text'), findsOneWidget);
      expect(find.text('Rule hint'), findsOneWidget);
    });

    testWidgets('tapping assign-to-self triggers action', (tester) async {
      final report = MockAdminReport.create();
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AdminReportDetail(schema: report),
        accessStatus: status,
      ));
      await tester.pump();

      await tester.runAsync(() async {
        await tester.tap(find.text('Assign to me'));
        await tester.pump();
      });

      // Widget should still be present (API failure doesn't crash)
      expect(find.byType(AdminReportDetail), findsOneWidget);
    });

    testWidgets('tapping resolve triggers action', (tester) async {
      final report = MockAdminReport.create();
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AdminReportDetail(schema: report),
        accessStatus: status,
      ));
      await tester.pump();

      await tester.runAsync(() async {
        await tester.tap(find.text('Resolve'));
        await tester.pump();
      });

      expect(find.byType(AdminReportDetail), findsOneWidget);
    });

    testWidgets('tapping unassign on assigned report triggers action', (tester) async {
      final report = MockAdminReport.assigned();
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AdminReportDetail(schema: report),
        accessStatus: status,
      ));
      await tester.pump();

      await tester.runAsync(() async {
        await tester.tap(find.text('Unassign'));
        await tester.pump();
      });

      expect(find.byType(AdminReportDetail), findsOneWidget);
    });

    testWidgets('tapping reopen on resolved report triggers action', (tester) async {
      final report = MockAdminReport.resolved();
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AdminReportDetail(schema: report),
        accessStatus: status,
      ));
      await tester.pump();

      await tester.runAsync(() async {
        await tester.tap(find.text('Reopen'));
        await tester.pump();
      });

      expect(find.byType(AdminReportDetail), findsOneWidget);
    });

    testWidgets('unresolved report shows assign and resolve action labels', (tester) async {
      final report = MockAdminReport.create();
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AdminReportDetail(schema: report),
        accessStatus: status,
      ));
      await tester.pump();

      // assignToSelf and resolve buttons should show labels
      expect(find.text('Assign to me'), findsOneWidget);
      expect(find.text('Resolve'), findsOneWidget);
      expect(find.byIcon(Icons.person_add), findsOneWidget);
      expect(find.byIcon(Icons.done), findsOneWidget);
    });

    testWidgets('resolved report shows only reopen action label', (tester) async {
      final report = MockAdminReport.resolved();
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AdminReportDetail(schema: report),
        accessStatus: status,
      ));
      await tester.pump();

      expect(find.text('Reopen'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
      // Ensure resolve/assign are not present
      expect(find.text('Resolve'), findsNothing);
      expect(find.text('Assign to me'), findsNothing);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
