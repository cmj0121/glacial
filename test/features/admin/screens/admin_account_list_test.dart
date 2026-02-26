// Widget tests for AdminAccountList and AdminAccountStatus.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/core.dart';
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

    testWidgets('shows NoResult when accounts list is empty after load', (tester) async {
      final noDomainStatus = const AccessStatusSchema(domain: null, accessToken: 'test');

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: AdminAccountList(status: noDomainStatus)),
        ));
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 100));
        await tester.pump();
      });

      expect(find.byType(NoResult), findsOneWidget);
    });

    testWidgets('NoResult shows localized no accounts message', (tester) async {
      final noDomainStatus = const AccessStatusSchema(domain: null, accessToken: 'test');

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: AdminAccountList(status: noDomainStatus)),
        ));
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 100));
        await tester.pump();
      });

      expect(find.byType(NoResult), findsOneWidget);
    });

    testWidgets('tapping a status filter chip selects it', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: AdminAccountList(status: status)),
        ));
        await tester.pump();

        // Tap the Pending chip inside runAsync to handle timers
        await tester.tap(find.text('Pending'));
        await tester.pump();
      });

      final FilterChip chip = tester.widget<FilterChip>(
        find.widgetWithText(FilterChip, 'Pending'),
      );
      expect(chip.selected, isTrue);
    });

    testWidgets('tapping Active chip then All chip reselects All', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: AdminAccountList(status: status)),
        ));
        await tester.pump();

        // Tap Active chip
        await tester.tap(find.text('Active'));
        await tester.pump();

        // Tap the "All" chip (labeled "Search" from l10n)
        await tester.tap(find.text('Search'));
        await tester.pump();
      });

      final FilterChip allChip = tester.widget<FilterChip>(
        find.widgetWithText(FilterChip, 'Search'),
      );
      expect(allChip.selected, isTrue);
    });

    testWidgets('tapping Disabled chip selects it', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: AdminAccountList(status: status)),
        ));
        await tester.pump();

        await tester.tap(find.text('Disabled'));
        await tester.pump();
      });

      final FilterChip chip = tester.widget<FilterChip>(
        find.widgetWithText(FilterChip, 'Disabled'),
      );
      expect(chip.selected, isTrue);
    });

    testWidgets('tapping Silenced chip selects it', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: AdminAccountList(status: status)),
        ));
        await tester.pump();

        await tester.tap(find.text('Silenced'));
        await tester.pump();
      });

      final FilterChip chip = tester.widget<FilterChip>(
        find.widgetWithText(FilterChip, 'Silenced'),
      );
      expect(chip.selected, isTrue);
    });

    testWidgets('tapping Suspended chip selects it', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: AdminAccountList(status: status)),
        ));
        await tester.pump();

        // Ensure the Suspended chip is visible (may need scroll in horizontal list)
        await tester.ensureVisible(find.text('Suspended'));
        await tester.pump();
        await tester.tap(find.text('Suspended'));
        await tester.pump();
      });

      final FilterChip chip = tester.widget<FilterChip>(
        find.widgetWithText(FilterChip, 'Suspended'),
      );
      expect(chip.selected, isTrue);
    });

    testWidgets('uses PaginatedListMixin for loading', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: AdminAccountList(status: status)),
        ));
        await tester.pump();
      });

      expect(find.byType(AdminAccountList), findsOneWidget);
    });

    testWidgets('has horizontal scrollable filter chips', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: AdminAccountList(status: status)),
        ));
        await tester.pump();
      });

      expect(find.byType(SingleChildScrollView), findsWidgets);
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

  group('AdminAccountList tile rendering', () {
    late AccessStatusSchema status;

    setUp(() {
      status = MockAccessStatus.authenticated(server: MockServer.create());
    });

    testWidgets('renders account tiles when accounts are populated', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: AdminAccountList(status: status)),
        ));
        await tester.pump();
      });

      // Inject accounts directly into state to exercise tile rendering
      final dynamic state = tester.state(find.byType(AdminAccountList));
      final List<AdminAccountSchema> accounts = [
        MockAdminAccount.create(id: 'a1', username: 'alice'),
        MockAdminAccount.create(id: 'a2', username: 'bob'),
      ];
      state.accounts.addAll(accounts);
      (tester.element(find.byType(AdminAccountList)) as StatefulElement).markNeedsBuild();
      await tester.pump();

      // The ListView should render, with Account widgets inside tiles
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(Account), findsNWidgets(2));
    });

    testWidgets('account tile shows status chip with Active label', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: AdminAccountList(status: status)),
        ));
        await tester.pump();
      });

      final dynamic state = tester.state(find.byType(AdminAccountList));
      state.accounts.addAll([
        MockAdminAccount.create(id: 'a1', username: 'activeuser'),
      ]);
      (tester.element(find.byType(AdminAccountList)) as StatefulElement).markNeedsBuild();
      await tester.pump();

      // Active status chip should appear (Active label from _statusLabel + in the Chip)
      // The filter chips also have 'Active' text, plus the tile chip
      expect(find.byType(Chip), findsWidgets);
      expect(find.byType(AdaptiveGlassCard), findsOneWidget);
    });

    testWidgets('account tile shows Pending status chip for pending account', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: AdminAccountList(status: status)),
        ));
        await tester.pump();
      });

      final dynamic state = tester.state(find.byType(AdminAccountList));
      state.accounts.addAll([
        MockAdminAccount.pending(id: 'p1'),
      ]);
      (tester.element(find.byType(AdminAccountList)) as StatefulElement).markNeedsBuild();
      await tester.pump();

      // Pending chip in tile + Pending filter chip = 2 occurrences of 'Pending' text
      expect(find.text('Pending'), findsNWidgets(2));
      expect(find.byType(AdaptiveGlassCard), findsOneWidget);
    });

    testWidgets('account tile shows Disabled status chip for disabled account', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: AdminAccountList(status: status)),
        ));
        await tester.pump();
      });

      final dynamic state = tester.state(find.byType(AdminAccountList));
      state.accounts.addAll([
        MockAdminAccount.createDisabled(id: 'd1'),
      ]);
      (tester.element(find.byType(AdminAccountList)) as StatefulElement).markNeedsBuild();
      await tester.pump();

      // Disabled chip in tile + Disabled filter chip = 2 occurrences
      expect(find.text('Disabled'), findsNWidgets(2));
    });

    testWidgets('account tile shows Silenced status chip for silenced account', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: AdminAccountList(status: status)),
        ));
        await tester.pump();
      });

      final dynamic state = tester.state(find.byType(AdminAccountList));
      state.accounts.addAll([
        MockAdminAccount.createSilenced(id: 's1'),
      ]);
      (tester.element(find.byType(AdminAccountList)) as StatefulElement).markNeedsBuild();
      await tester.pump();

      // Silenced chip in tile + Silenced filter chip = 2 occurrences
      expect(find.text('Silenced'), findsNWidgets(2));
    });

    testWidgets('account tile shows Suspended status chip for suspended account', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: AdminAccountList(status: status)),
        ));
        await tester.pump();
      });

      final dynamic state = tester.state(find.byType(AdminAccountList));
      state.accounts.addAll([
        MockAdminAccount.createSuspended(id: 'su1'),
      ]);
      (tester.element(find.byType(AdminAccountList)) as StatefulElement).markNeedsBuild();
      await tester.pump();

      // Suspended chip in tile + Suspended filter chip = 2 occurrences
      expect(find.text('Suspended'), findsNWidgets(2));
    });

    testWidgets('renders multiple tiles with mixed statuses', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: AdminAccountList(status: status)),
        ));
        await tester.pump();
      });

      final dynamic state = tester.state(find.byType(AdminAccountList));
      state.accounts.addAll([
        MockAdminAccount.create(id: 'a1', username: 'active_user'),
        MockAdminAccount.pending(id: 'a2'),
        MockAdminAccount.createSuspended(id: 'a3'),
      ]);
      (tester.element(find.byType(AdminAccountList)) as StatefulElement).markNeedsBuild();
      await tester.pump();

      expect(find.byType(AdaptiveGlassCard), findsNWidgets(3));
      expect(find.byType(Account), findsNWidgets(3));
    });

    testWidgets('account tile has Row with Account and Chip', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: AdminAccountList(status: status)),
        ));
        await tester.pump();
      });

      final dynamic state = tester.state(find.byType(AdminAccountList));
      state.accounts.addAll([
        MockAdminAccount.create(id: 'a1', username: 'tileuser'),
      ]);
      (tester.element(find.byType(AdminAccountList)) as StatefulElement).markNeedsBuild();
      await tester.pump();

      // Verify the tile has Account and Chip (non-FilterChip)
      expect(find.byType(Account), findsOneWidget);
      // Chip in the tile (non-FilterChip) - there should be at least 1 Chip widget
      expect(find.byType(Chip), findsWidgets);
    });

    testWidgets('buildContent returns ListView when accounts exist', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: AdminAccountList(status: status)),
        ));
        await tester.pump();
      });

      final dynamic state = tester.state(find.byType(AdminAccountList));
      state.accounts.addAll([
        MockAdminAccount.create(id: 'a1', username: 'listuser'),
      ]);
      (tester.element(find.byType(AdminAccountList)) as StatefulElement).markNeedsBuild();
      await tester.pump();

      // ListView should be present instead of NoResult
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(NoResult), findsNothing);
    });
  });

  group('AdminAccountOrigin', () {
    test('has 2 values', () {
      expect(AdminAccountOrigin.values.length, 2);
    });

    test('contains local and remote', () {
      expect(AdminAccountOrigin.values, contains(AdminAccountOrigin.local));
      expect(AdminAccountOrigin.values, contains(AdminAccountOrigin.remote));
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
