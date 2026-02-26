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
