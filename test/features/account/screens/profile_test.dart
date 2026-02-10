// Widget tests for profile screens: UserStatistics, ProfilePage.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  setupTestEnvironment();

  // Initialize sqflite FFI for CachedNetworkImage's cache manager in runAsync tests.
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('UserStatistics', () {
    testWidgets('shows statuses count', (tester) async {
      final account = MockAccount.create(statusesCount: 42);

      await tester.pumpWidget(createTestWidget(
        child: UserStatistics(schema: account),
      ));
      await tester.pump();

      expect(find.text('42'), findsOneWidget);
    });

    testWidgets('shows followers count', (tester) async {
      final account = MockAccount.create(followersCount: 150);

      await tester.pumpWidget(createTestWidget(
        child: UserStatistics(schema: account),
      ));
      await tester.pump();

      expect(find.text('150'), findsOneWidget);
    });

    testWidgets('shows following count', (tester) async {
      final account = MockAccount.create(followingCount: 75);

      await tester.pumpWidget(createTestWidget(
        child: UserStatistics(schema: account),
      ));
      await tester.pump();

      expect(find.text('75'), findsOneWidget);
    });

    testWidgets('shows correct icons for statistics', (tester) async {
      final account = MockAccount.create();

      await tester.pumpWidget(createTestWidget(
        child: UserStatistics(schema: account),
      ));
      await tester.pump();

      expect(find.byIcon(Icons.post_add), findsOneWidget);
      expect(find.byIcon(Icons.visibility), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('shows lock icon for locked accounts', (tester) async {
      final account = MockAccount.create(locked: true);

      await tester.pumpWidget(createTestWidget(
        child: UserStatistics(schema: account),
      ));
      await tester.pump();

      expect(find.byIcon(Icons.lock_person), findsOneWidget);
    });

    testWidgets('does not show lock icon for unlocked accounts', (tester) async {
      final account = MockAccount.create(locked: false);

      await tester.pumpWidget(createTestWidget(
        child: UserStatistics(schema: account),
      ));
      await tester.pump();

      expect(find.byIcon(Icons.lock_person), findsNothing);
    });

    testWidgets('fires onStatusesTap callback', (tester) async {
      bool tapped = false;
      final account = MockAccount.create();

      await tester.pumpWidget(createTestWidget(
        child: UserStatistics(
          schema: account,
          onStatusesTap: () => tapped = true,
        ),
      ));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.post_add));
      expect(tapped, isTrue);
    });

    testWidgets('fires onFollowersTap callback', (tester) async {
      bool tapped = false;
      final account = MockAccount.create();

      await tester.pumpWidget(createTestWidget(
        child: UserStatistics(
          schema: account,
          onFollowersTap: () => tapped = true,
        ),
      ));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.visibility));
      expect(tapped, isTrue);
    });
  });

  group('ProfilePage', () {
    setUpAll(() {
      // Mock path_provider to prevent MissingPluginException from CachedNetworkImage's
      // cache manager when running with tester.runAsync().
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        (MethodCall methodCall) async => Directory.systemTemp.path,
      );
    });

    testWidgets('returns empty when no domain set', (tester) async {
      final account = MockAccount.create();
      // Create status with domain explicitly null
      final status = AccessStatusSchema(
        domain: null,
        accessToken: 'test_token',
        account: account,
      );

      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          body: ProfilePage(schema: account),
        ),
        accessStatus: status,
      ));
      await tester.pump();

      // Should return SizedBox.shrink when domain is null
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('renders with account schema', (tester) async {
      final viewedAccount = MockAccount.create(id: '999', displayName: 'Alice');
      final selfAccount = MockAccount.create(id: '123');
      final status = MockAccessStatus.authenticated(
        account: selfAccount,
        server: MockServer.create(),
      );

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(
            body: ProfilePage(schema: viewedAccount),
          ),
          accessStatus: status,
        ));
        await tester.pump();
      });

      expect(find.byType(ProfilePage), findsOneWidget);
    });

    testWidgets('shows acct text', (tester) async {
      final viewedAccount = MockAccount.create(
        id: '999',
        username: 'alice',
        displayName: 'Alice Wonderland',
      );
      final selfAccount = MockAccount.create(id: '123');
      final status = MockAccessStatus.authenticated(
        account: selfAccount,
        server: MockServer.create(),
      );

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(
            body: ProfilePage(schema: viewedAccount),
          ),
          accessStatus: status,
        ));
        await tester.pump();
      });

      // The profile page shows acct (username@domain) in buildAccountName
      expect(find.textContaining('alice'), findsWidgets);
    });

    testWidgets('contains UserStatistics widget', (tester) async {
      final viewedAccount = MockAccount.create(id: '999');
      final selfAccount = MockAccount.create(id: '123');
      final status = MockAccessStatus.authenticated(
        account: selfAccount,
        server: MockServer.create(),
      );

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(
            body: ProfilePage(schema: viewedAccount),
          ),
          accessStatus: status,
        ));
        await tester.pump();
      });

      expect(find.byType(UserStatistics), findsOneWidget);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
