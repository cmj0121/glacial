// Widget tests for ListAccountWidget.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  // Mock path_provider for CachedNetworkImage cache manager.
  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async => Directory.systemTemp.path,
    );
  });

  // Use domain-less access status so API calls short-circuit.
  AccessStatusSchema noDomainStatus() {
    return const AccessStatusSchema(
      domain: null,
      accessToken: 'test_token',
    );
  }

  group('ListAccountWidget', () {
    test('is a ConsumerStatefulWidget', () {
      const widget = ListAccountWidget(name: 'test');
      expect(widget, isA<ConsumerStatefulWidget>());
    });

    test('accepts name parameter', () {
      const widget = ListAccountWidget(name: 'searchQuery');
      expect(widget.name, 'searchQuery');
    });

    test('accepts onSelected callback', () {
      final widget = ListAccountWidget(
        name: 'test',
        onSelected: (_) {},
      );
      expect(widget.onSelected, isNotNull);
    });

    testWidgets('renders with no-domain status', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: ListAccountWidget(name: 'test')),
          accessStatus: noDomainStatus(),
        ));
        await tester.pump();
      });

      expect(find.byType(ListAccountWidget), findsOneWidget);
    });

    testWidgets('shows NoResult when search returns empty', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: ListAccountWidget(name: 'nonexistent')),
          accessStatus: noDomainStatus(),
        ));
        await tester.pump();
      });

      // With null domain, searchAccounts returns empty list → NoResult
      expect(find.byType(NoResult), findsOneWidget);
    });

    testWidgets('shows ListView when accounts are injected', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: ListAccountWidget(name: 'test')),
          accessStatus: noDomainStatus(),
        ));
        await tester.pump();
      });

      // Inject accounts into state
      final dynamic state = tester.state(find.byType(ListAccountWidget));
      state.accounts.addAll([
        MockAccount.create(id: 'a1', username: 'alice', displayName: 'Alice'),
        MockAccount.create(id: 'a2', username: 'bob', displayName: 'Bob'),
      ]);
      (tester.element(find.byType(ListAccountWidget)) as StatefulElement).markNeedsBuild();
      await tester.pump();

      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(AccountLite), findsNWidgets(2));
    });

    testWidgets('tapping an account triggers onSelected callback', (tester) async {
      AccountSchema? selectedAccount;

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(
            body: ListAccountWidget(
              name: 'test',
              onSelected: (account) => selectedAccount = account,
            ),
          ),
          accessStatus: noDomainStatus(),
        ));
        await tester.pump();
      });

      // Inject accounts into state
      final dynamic state = tester.state(find.byType(ListAccountWidget));
      state.accounts.addAll([
        MockAccount.create(id: 'a1', username: 'alice', displayName: 'Alice'),
      ]);
      (tester.element(find.byType(ListAccountWidget)) as StatefulElement).markNeedsBuild();
      await tester.pump();

      // Tap the AccountLite widget (ListTile)
      await tester.tap(find.byType(AccountLite));
      await tester.pump();

      expect(selectedAccount, isNotNull);
      expect(selectedAccount!.id, 'a1');
    });

    testWidgets('tapping account without onSelected does not crash', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(
            body: ListAccountWidget(name: 'test'),
          ),
          accessStatus: noDomainStatus(),
        ));
        await tester.pump();
      });

      // Inject accounts into state
      final dynamic state = tester.state(find.byType(ListAccountWidget));
      state.accounts.addAll([
        MockAccount.create(id: 'a1', username: 'alice', displayName: 'Alice'),
      ]);
      (tester.element(find.byType(ListAccountWidget)) as StatefulElement).markNeedsBuild();
      await tester.pump();

      // Tap the AccountLite widget — should not crash (onSelected is null, lambda is no-op)
      await tester.tap(find.byType(AccountLite));
      await tester.pump();

      // No exception expected — the onTap lambda calls onSelected?.call() which is a no-op
      expect(find.byType(ListAccountWidget), findsOneWidget);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
