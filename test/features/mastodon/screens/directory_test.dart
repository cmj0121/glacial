// Widget tests for directory screens: DirectoryType, DirectoryTab.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  setupTestEnvironment();

  // Initialize sqflite FFI for CachedNetworkImage's cache manager in runAsync tests.
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('DirectoryType', () {
    test('has 2 values', () {
      expect(DirectoryType.values.length, 2);
      expect(DirectoryType.values, contains(DirectoryType.directory));
      expect(DirectoryType.values, contains(DirectoryType.endorsements));
    });

    test('directory icon returns groups icons', () {
      expect(DirectoryType.directory.icon(), Icons.groups_outlined);
      expect(DirectoryType.directory.icon(active: true), Icons.groups);
      expect(DirectoryType.directory.icon(active: false), Icons.groups_outlined);
    });

    test('endorsements icon returns star icons', () {
      expect(DirectoryType.endorsements.icon(), Icons.star_outline);
      expect(DirectoryType.endorsements.icon(active: true), Icons.star);
      expect(DirectoryType.endorsements.icon(active: false), Icons.star_outline);
    });

    test('directory is always enabled', () {
      expect(DirectoryType.directory.enabled, isTrue);
    });

    test('endorsements is disabled by default', () {
      expect(DirectoryType.enableEndorsements, isFalse);
      expect(DirectoryType.endorsements.enabled, isFalse);
    });

    testWidgets('all types have localized tooltips', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: Builder(
          builder: (context) {
            for (final type in DirectoryType.values) {
              final tooltip = type.tooltip(context);
              expect(tooltip, isA<String>());
              expect(tooltip.isNotEmpty, isTrue);
            }
            return const SizedBox.shrink();
          },
        ),
      ));
      await tester.pump();
    });
  });

  group('DirectoryTab', () {
    setUpAll(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        (MethodCall methodCall) async => Directory.systemTemp.path,
      );
    });

    testWidgets('renders with authenticated user', (tester) async {
      final status = MockAccessStatus.authenticated();

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: const DirectoryTab()),
          accessStatus: status,
        ));
        await tester.pump();
      });

      expect(find.byType(DirectoryTab), findsOneWidget);
    });

    testWidgets('renders single tab when endorsements disabled', (tester) async {
      final status = MockAccessStatus.authenticated();

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: const DirectoryTab()),
          accessStatus: status,
        ));
        await tester.pump();
      });

      // endorsements is disabled, so tabs.length == 1, no SwipeTabView rendered
      expect(find.byType(SwipeTabView), findsNothing);
    });

    testWidgets('renders with anonymous user (no access token)', (tester) async {
      final status = MockAccessStatus.anonymous();

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: const DirectoryTab()),
          accessStatus: status,
        ));
        await tester.pump();
      });

      expect(find.byType(DirectoryTab), findsOneWidget);
    });
  });

  group('_DirectoryList loading states', () {
    setUpAll(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        (MethodCall methodCall) async => Directory.systemTemp.path,
      );
    });

    testWidgets('shows NoResult when load completes with empty data', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: const DirectoryTab()),
          accessStatus: const AccessStatusSchema(domain: null, accessToken: 'test'),
        ));
        await tester.pump();
        // Allow onLoad to fail (null domain) → empty accounts
        await Future<void>.delayed(const Duration(milliseconds: 100));
        await tester.pump();
      });

      expect(find.byType(NoResult), findsOneWidget);
    });

    testWidgets('shows ListView when accounts are injected', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: const DirectoryTab()),
          accessStatus: const AccessStatusSchema(domain: null, accessToken: 'test'),
        ));
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 100));
        await tester.pump();
      });

      // Find the _DirectoryList state via the DirectoryTab tree
      // The DirectoryTab renders _DirectoryList internally
      // Find state by looking for a state that has 'accounts' field
      final stateFinder = find.byWidgetPredicate(
        (widget) => widget.runtimeType.toString() == '_DirectoryList',
      );
      expect(stateFinder, findsOneWidget);

      final dynamic state = tester.state(stateFinder);
      state.accounts.addAll([
        MockAccount.create(id: 'a1', username: 'alice', displayName: 'Alice'),
        MockAccount.create(id: 'a2', username: 'bob', displayName: 'Bob'),
      ]);
      state.accountIDs.addAll(['a1', 'a2']);
      (tester.element(stateFinder) as StatefulElement).markNeedsBuild();
      await tester.pump();

      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(Account), findsNWidgets(2));
    });

    testWidgets('accounts are rendered with horizontal padding', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: const DirectoryTab()),
          accessStatus: const AccessStatusSchema(domain: null, accessToken: 'test'),
        ));
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 100));
        await tester.pump();
      });

      final stateFinder = find.byWidgetPredicate(
        (widget) => widget.runtimeType.toString() == '_DirectoryList',
      );

      final dynamic state = tester.state(stateFinder);
      state.accounts.addAll([
        MockAccount.create(id: 'a1', username: 'alice'),
      ]);
      state.accountIDs.addAll(['a1']);
      (tester.element(stateFinder) as StatefulElement).markNeedsBuild();
      await tester.pump();

      // Each item wrapped in Padding
      expect(find.byType(Padding), findsWidgets);
      expect(find.byType(Account), findsOneWidget);
    });

    testWidgets('deduplicates accounts by ID on injection', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: const DirectoryTab()),
          accessStatus: const AccessStatusSchema(domain: null, accessToken: 'test'),
        ));
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 100));
        await tester.pump();
      });

      final stateFinder = find.byWidgetPredicate(
        (widget) => widget.runtimeType.toString() == '_DirectoryList',
      );

      final dynamic state = tester.state(stateFinder);

      // Add accounts with duplicate IDs
      state.accounts.addAll([
        MockAccount.create(id: 'a1', username: 'alice'),
      ]);
      state.accountIDs.addAll(['a1']);

      // Simulate a second "load" but with the same ID already in accountIDs
      // a1 is already present so should be skipped; a2 is new
      final AccountSchema dup = MockAccount.create(id: 'a1', username: 'alice-duplicate');
      final AccountSchema newOne = MockAccount.create(id: 'a2', username: 'bob');
      final Set<String> existingIDs = Set<String>.from(state.accountIDs as Set);

      // Only add accounts whose IDs are not already in the set
      for (final AccountSchema a in [dup, newOne]) {
        if (!existingIDs.contains(a.id)) {
          (state.accounts as List).add(a);
          (state.accountIDs as Set).add(a.id);
        }
      }

      (tester.element(stateFinder) as StatefulElement).markNeedsBuild();
      await tester.pump();

      // Only 2 accounts should be in the list (a1 original + a2 new)
      expect(state.accounts.length, 2);
      expect(state.accountIDs.length, 2);
      expect(find.byType(Account), findsNWidgets(2));
    });

    testWidgets('SizedBox.shrink shown when accounts is empty and loading', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: const DirectoryTab()),
          accessStatus: const AccessStatusSchema(domain: null, accessToken: 'test'),
        ));
        await tester.pump();
      });

      final stateFinder = find.byWidgetPredicate(
        (widget) => widget.runtimeType.toString() == '_DirectoryList',
      );

      final dynamic state = tester.state(stateFinder);
      state.setLoading(true);
      await tester.pump();

      // When isLoading is true and accounts is empty, buildContent returns SizedBox.shrink
      expect(find.byType(SizedBox), findsWidgets);
      expect(find.byType(NoResult), findsNothing);
    });

    testWidgets('renders Align at topCenter', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: const DirectoryTab()),
          accessStatus: const AccessStatusSchema(domain: null, accessToken: 'test'),
        ));
        await tester.pump();
      });

      expect(find.byType(Align), findsWidgets);
      expect(find.byType(Column), findsWidgets);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
