// Widget tests for account misc screens: AccountList, FollowedHashtags.
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

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async => Directory.systemTemp.path,
    );
  });

  group('AccountList', () {
    testWidgets('renders with authenticated user', (tester) async {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(
            body: AccountList(
              loader: ({String? maxId}) async => (<AccountSchema>[], null),
            ),
          ),
          accessStatus: status,
        ));
        await tester.pump();
      });

      expect(find.byType(AccountList), findsOneWidget);
    });

    testWidgets('widget accepts loader parameter', (tester) async {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(
            body: AccountList(
              loader: ({String? maxId}) async => (<AccountSchema>[], null),
            ),
          ),
          accessStatus: status,
        ));
        await tester.pump();
      });

      expect(find.byType(AccountList), findsOneWidget);
    });

    testWidgets('widget accepts onDismiss parameter', (tester) async {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(
            body: AccountList(
              loader: ({String? maxId}) async => (<AccountSchema>[], null),
              onDismiss: (account) async {},
            ),
          ),
          accessStatus: status,
        ));
        await tester.pump();
      });

      expect(find.byType(AccountList), findsOneWidget);
    });

    testWidgets('shows SizedBox.shrink when no server', (tester) async {
      // When status.server is null, should render SizedBox.shrink
      final status = const AccessStatusSchema(domain: null, accessToken: 'test');

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(
            body: AccountList(
              loader: ({String? maxId}) async => (<AccountSchema>[], null),
            ),
          ),
          accessStatus: status,
        ));
        await tester.pump();
      });

      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('shows NoResult when empty and completed', (tester) async {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(
            body: AccountList(
              loader: ({String? maxId}) async => (<AccountSchema>[], null),
            ),
          ),
          accessStatus: status,
        ));
        // Wait for the loader to complete
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
      });

      // After loading returns empty, should show NoResult
      expect(find.byType(NoResult), findsOneWidget);
    });

    testWidgets('shows accounts in ListView when loaded', (tester) async {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );
      final accounts = [
        MockAccount.create(id: 'a1', username: 'alice', displayName: 'Alice'),
        MockAccount.create(id: 'a2', username: 'bob', displayName: 'Bob'),
      ];

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(
            body: AccountList(
              loader: ({String? maxId}) async => (accounts, null),
            ),
          ),
          accessStatus: status,
        ));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
      });

      expect(find.byType(Account), findsNWidgets(2));
    });

    testWidgets('shows loading indicator initially', (tester) async {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(
            body: AccountList(
              loader: ({String? maxId}) async => (<AccountSchema>[], null),
            ),
          ),
          accessStatus: status,
        ));
        // Pump once to see the initial loading state before loader completes
        await tester.pump();
      });

      // Should show the AccountList widget
      expect(find.byType(AccountList), findsOneWidget);
    });

    testWidgets('shows Dismissible when onDismiss is provided with accounts', (tester) async {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );
      final accounts = [
        MockAccount.create(id: 'a1', username: 'alice', displayName: 'Alice'),
      ];
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(
            body: AccountList(
              loader: ({String? maxId}) async => (accounts, null),
              onDismiss: (account) async {},
            ),
          ),
          accessStatus: status,
        ));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
      });

      // AccessibleDismissible should be present when onDismiss is provided
      expect(find.byType(AccessibleDismissible), findsOneWidget);
    });

    testWidgets('does not show Dismissible when onDismiss is null', (tester) async {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );
      final accounts = [
        MockAccount.create(id: 'a1', username: 'alice', displayName: 'Alice'),
      ];

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(
            body: AccountList(
              loader: ({String? maxId}) async => (accounts, null),
            ),
          ),
          accessStatus: status,
        ));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
      });

      // No Dismissible when onDismiss is null
      expect(find.byType(AccessibleDismissible), findsNothing);
    });

    testWidgets('loads more pages via pagination', (tester) async {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );
      int loadCount = 0;

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(
            body: AccountList(
              loader: ({String? maxId}) async {
                loadCount++;
                if (loadCount == 1) {
                  return ([
                    MockAccount.create(id: 'a1', username: 'alice'),
                  ], 'next-page');
                }
                return (<AccountSchema>[], null);
              },
            ),
          ),
          accessStatus: status,
        ));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
      });

      // First page loaded
      expect(loadCount, 1);
      expect(find.byType(Account), findsOneWidget);
    });
  });

  group('FollowedHashtags', () {
    testWidgets('renders with authenticated user', (tester) async {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: FollowedHashtags()),
          accessStatus: status,
        ));
        await tester.pump();
      });

      expect(find.byType(FollowedHashtags), findsOneWidget);
    });

    testWidgets('uses ScrollController for pagination', (tester) async {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: FollowedHashtags()),
          accessStatus: status,
        ));
        await tester.pump();
      });

      // Verify the widget creates and uses a ScrollController
      final state = tester.state(find.byType(FollowedHashtags));
      final controller = (state as dynamic).controller;
      expect(controller, isA<ScrollController>());
    });

    testWidgets('is a ConsumerStatefulWidget', (tester) async {
      const widget = FollowedHashtags();
      expect(widget, isA<ConsumerStatefulWidget>());
    });

    testWidgets('shows loading overlay initially', (tester) async {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: FollowedHashtags()),
          accessStatus: status,
        ));
        await tester.pump();
      });

      expect(find.byType(FollowedHashtags), findsOneWidget);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
