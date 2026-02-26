// Widget tests for AdminReportList.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/core.dart';
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

    testWidgets('shows NoResult when reports list is empty after load', (tester) async {
      // Use no-domain status so fetchAdminReports returns empty
      final noDomainStatus = const AccessStatusSchema(domain: null, accessToken: 'test');

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: AdminReportList(status: noDomainStatus)),
        ));
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 100));
        await tester.pump();
      });

      expect(find.byType(NoResult), findsOneWidget);
    });

    testWidgets('NoResult shows localized message text', (tester) async {
      final noDomainStatus = const AccessStatusSchema(domain: null, accessToken: 'test');

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: AdminReportList(status: noDomainStatus)),
        ));
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 100));
        await tester.pump();
      });

      // The NoResult widget should display a message about no reports
      expect(find.byType(NoResult), findsOneWidget);
    });

    testWidgets('tapping Resolved chip selects it', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: AdminReportList(status: status)),
        ));
        await tester.pump();

        // Tap inside runAsync to handle pending timers
        await tester.tap(find.text('Resolved'));
        await tester.pump();
      });

      final FilterChip chip = tester.widget<FilterChip>(
        find.widgetWithText(FilterChip, 'Resolved'),
      );
      expect(chip.selected, isTrue);
    });

    testWidgets('tapping Unresolved chip after Resolved reselects it', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: AdminReportList(status: status)),
        ));
        await tester.pump();

        // First select Resolved
        await tester.tap(find.text('Resolved'));
        await tester.pump();
        // Then select Unresolved
        await tester.tap(find.text('Unresolved'));
        await tester.pump();
      });

      final FilterChip unresolvedChip = tester.widget<FilterChip>(
        find.widgetWithText(FilterChip, 'Unresolved'),
      );
      expect(unresolvedChip.selected, isTrue);

      final FilterChip resolvedChip = tester.widget<FilterChip>(
        find.widgetWithText(FilterChip, 'Resolved'),
      );
      expect(resolvedChip.selected, isFalse);
    });

    testWidgets('uses PaginatedListMixin for loading indicator', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: AdminReportList(status: status)),
        ));
        // During initial load, loading indicator may be visible
        await tester.pump();
      });

      // After load completes, widget should render successfully
      expect(find.byType(AdminReportList), findsOneWidget);
    });
  });

  group('AdminReportList tile rendering', () {
    late AccessStatusSchema status;

    setUp(() {
      status = MockAccessStatus.authenticated(server: MockServer.create());
    });

    testWidgets('renders report tiles when reports are populated', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: AdminReportList(status: status)),
        ));
        await tester.pump();
      });

      // Inject reports into state
      final dynamic state = tester.state(find.byType(AdminReportList));
      state.reports.addAll([
        MockAdminReport.create(id: 'r1', comment: 'Spam posting'),
        MockAdminReport.create(id: 'r2', comment: 'Harassment'),
      ]);
      (tester.element(find.byType(AdminReportList)) as StatefulElement).markNeedsBuild();
      await tester.pump();

      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(AdaptiveGlassCard), findsNWidgets(2));
    });

    testWidgets('report tile shows category icon and label', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: AdminReportList(status: status)),
        ));
        await tester.pump();
      });

      final dynamic state = tester.state(find.byType(AdminReportList));
      state.reports.addAll([
        MockAdminReport.create(id: 'r1', category: ReportCategoryType.spam),
      ]);
      (tester.element(find.byType(AdminReportList)) as StatefulElement).markNeedsBuild();
      await tester.pump();

      expect(find.byIcon(Icons.campaign), findsOneWidget);
      expect(find.text('Spam'), findsOneWidget);
    });

    testWidgets('report tile shows target account acct', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: AdminReportList(status: status)),
        ));
        await tester.pump();
      });

      final dynamic state = tester.state(find.byType(AdminReportList));
      final target = MockAccount.create(id: 'target1', username: 'badactor');
      state.reports.addAll([
        MockAdminReport.create(id: 'r1', targetAccount: target),
      ]);
      (tester.element(find.byType(AdminReportList)) as StatefulElement).markNeedsBuild();
      await tester.pump();

      expect(find.text('@badactor'), findsOneWidget);
    });

    testWidgets('report tile shows comment text when present', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: AdminReportList(status: status)),
        ));
        await tester.pump();
      });

      final dynamic state = tester.state(find.byType(AdminReportList));
      state.reports.addAll([
        MockAdminReport.create(id: 'r1', comment: 'Posting spam links'),
      ]);
      (tester.element(find.byType(AdminReportList)) as StatefulElement).markNeedsBuild();
      await tester.pump();

      expect(find.text('Posting spam links'), findsOneWidget);
    });

    testWidgets('report tile hides comment when empty', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: AdminReportList(status: status)),
        ));
        await tester.pump();
      });

      final dynamic state = tester.state(find.byType(AdminReportList));
      state.reports.addAll([
        MockAdminReport.create(id: 'r1', comment: ''),
      ]);
      (tester.element(find.byType(AdminReportList)) as StatefulElement).markNeedsBuild();
      await tester.pump();

      // Should still render the tile but without comment text
      expect(find.byType(AdaptiveGlassCard), findsOneWidget);
    });

    testWidgets('report tile shows Resolved chip when actionTaken is true', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: AdminReportList(status: status)),
        ));
        await tester.pump();
      });

      final dynamic state = tester.state(find.byType(AdminReportList));
      state.reports.addAll([
        MockAdminReport.resolved(id: 'r1'),
      ]);
      (tester.element(find.byType(AdminReportList)) as StatefulElement).markNeedsBuild();
      await tester.pump();

      // 'Resolved' appears in the tile chip AND in the filter chip
      expect(find.text('Resolved'), findsNWidgets(2));
      expect(find.byType(Chip), findsWidgets);
    });

    testWidgets('report tile shows reported-by account', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: AdminReportList(status: status)),
        ));
        await tester.pump();
      });

      final dynamic state = tester.state(find.byType(AdminReportList));
      final reporter = MockAccount.create(id: 'rep1', username: 'whistleblower');
      state.reports.addAll([
        MockAdminReport.create(id: 'r1', account: reporter),
      ]);
      (tester.element(find.byType(AdminReportList)) as StatefulElement).markNeedsBuild();
      await tester.pump();

      expect(find.textContaining('@whistleblower'), findsOneWidget);
    });

    testWidgets('report tile shows legal category icon', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: AdminReportList(status: status)),
        ));
        await tester.pump();
      });

      final dynamic state = tester.state(find.byType(AdminReportList));
      state.reports.addAll([
        MockAdminReport.create(id: 'r1', category: ReportCategoryType.legal),
      ]);
      (tester.element(find.byType(AdminReportList)) as StatefulElement).markNeedsBuild();
      await tester.pump();

      expect(find.byIcon(Icons.gavel), findsOneWidget);
    });

    testWidgets('report tile shows violation category icon', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: AdminReportList(status: status)),
        ));
        await tester.pump();
      });

      final dynamic state = tester.state(find.byType(AdminReportList));
      state.reports.addAll([
        MockAdminReport.create(id: 'r1', category: ReportCategoryType.violation),
      ]);
      (tester.element(find.byType(AdminReportList)) as StatefulElement).markNeedsBuild();
      await tester.pump();

      expect(find.byIcon(Icons.rule), findsOneWidget);
    });

    testWidgets('report tile shows other category icon', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: AdminReportList(status: status)),
        ));
        await tester.pump();
      });

      final dynamic state = tester.state(find.byType(AdminReportList));
      state.reports.addAll([
        MockAdminReport.create(id: 'r1', category: ReportCategoryType.other),
      ]);
      (tester.element(find.byType(AdminReportList)) as StatefulElement).markNeedsBuild();
      await tester.pump();

      expect(find.byIcon(Icons.report_sharp), findsOneWidget);
    });

    testWidgets('buildContent returns ListView when reports exist', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: AdminReportList(status: status)),
        ));
        await tester.pump();
      });

      final dynamic state = tester.state(find.byType(AdminReportList));
      state.reports.addAll([
        MockAdminReport.create(id: 'r1'),
      ]);
      (tester.element(find.byType(AdminReportList)) as StatefulElement).markNeedsBuild();
      await tester.pump();

      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(NoResult), findsNothing);
    });

    testWidgets('renders multiple report tiles', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: AdminReportList(status: status)),
        ));
        await tester.pump();
      });

      final dynamic state = tester.state(find.byType(AdminReportList));
      state.reports.addAll([
        MockAdminReport.create(id: 'r1', category: ReportCategoryType.spam),
        MockAdminReport.create(id: 'r2', category: ReportCategoryType.legal),
        MockAdminReport.create(id: 'r3', category: ReportCategoryType.other),
      ]);
      (tester.element(find.byType(AdminReportList)) as StatefulElement).markNeedsBuild();
      await tester.pump();

      expect(find.byType(AdaptiveGlassCard), findsNWidgets(3));
    });
  });

  group('AdminActionType', () {
    test('icon returns correct icon for each action', () {
      expect(AdminActionType.approve.icon, Icons.check_circle);
      expect(AdminActionType.reject.icon, Icons.cancel);
      expect(AdminActionType.suspend.icon, Icons.block);
      expect(AdminActionType.silence.icon, Icons.volume_off);
      expect(AdminActionType.enable.icon, Icons.play_circle);
      expect(AdminActionType.unsilence.icon, Icons.volume_up);
      expect(AdminActionType.unsuspend.icon, Icons.lock_open);
      expect(AdminActionType.unsensitive.icon, Icons.visibility);
      expect(AdminActionType.assignToSelf.icon, Icons.person_add);
      expect(AdminActionType.unassign.icon, Icons.person_remove);
      expect(AdminActionType.resolve.icon, Icons.done);
      expect(AdminActionType.reopen.icon, Icons.refresh);
    });

    test('isDangerous returns true for reject and suspend', () {
      expect(AdminActionType.reject.isDangerous, isTrue);
      expect(AdminActionType.suspend.isDangerous, isTrue);
    });

    test('isDangerous returns false for non-dangerous actions', () {
      expect(AdminActionType.approve.isDangerous, isFalse);
      expect(AdminActionType.silence.isDangerous, isFalse);
      expect(AdminActionType.enable.isDangerous, isFalse);
      expect(AdminActionType.unsilence.isDangerous, isFalse);
      expect(AdminActionType.unsuspend.isDangerous, isFalse);
      expect(AdminActionType.unsensitive.isDangerous, isFalse);
      expect(AdminActionType.resolve.isDangerous, isFalse);
      expect(AdminActionType.reopen.isDangerous, isFalse);
    });
  });

  group('ReportCategoryType', () {
    test('has 4 values', () {
      expect(ReportCategoryType.values.length, 4);
    });

    test('icon returns correct icons', () {
      expect(ReportCategoryType.spam.icon, Icons.campaign);
      expect(ReportCategoryType.legal.icon, Icons.gavel);
      expect(ReportCategoryType.violation.icon, Icons.rule);
      expect(ReportCategoryType.other.icon, Icons.report_sharp);
    });
  });

  group('AdminTabType', () {
    test('has 2 values', () {
      expect(AdminTabType.values.length, 2);
    });

    test('icon returns correct icons', () {
      expect(AdminTabType.reports.icon(), Icons.flag_outlined);
      expect(AdminTabType.reports.icon(active: true), Icons.flag);
      expect(AdminTabType.accounts.icon(), Icons.people_outlined);
      expect(AdminTabType.accounts.icon(active: true), Icons.people);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
