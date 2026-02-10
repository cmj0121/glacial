// Widget tests for profile familiar screens: FamiliarFollowers, FeaturedTags.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:glacial/features/screens.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  setupTestEnvironment();

  // Initialize sqflite FFI for CachedNetworkImage's cache manager in runAsync tests.
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('FamiliarFollowers', () {
    setUpAll(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        (MethodCall methodCall) async => Directory.systemTemp.path,
      );
    });

    testWidgets('renders empty initially', (tester) async {
      final account = MockAccount.create(id: '999');
      final status = MockAccessStatus.authenticated();

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: FamiliarFollowers(schema: account),
          accessStatus: status,
        ));
        await tester.pump();
      });

      // accounts is empty before API load, so renders SizedBox.shrink
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('accepts required schema parameter', (tester) async {
      final account = MockAccount.create(id: '999', displayName: 'Alice');
      final status = MockAccessStatus.authenticated();

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: FamiliarFollowers(schema: account),
          accessStatus: status,
        ));
        await tester.pump();
      });

      expect(find.byType(FamiliarFollowers), findsOneWidget);
    });

    testWidgets('accepts custom avatarSize', (tester) async {
      final account = MockAccount.create(id: '999');
      final status = MockAccessStatus.authenticated();

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: FamiliarFollowers(schema: account, avatarSize: 32),
          accessStatus: status,
        ));
        await tester.pump();
      });

      expect(find.byType(FamiliarFollowers), findsOneWidget);
    });
  });

  group('FeaturedTags', () {
    testWidgets('renders empty initially for non-self', (tester) async {
      // Use a different account ID so isSelf is false
      final viewedAccount = MockAccount.create(id: '999');
      final selfAccount = MockAccount.create(id: '123');
      final status = MockAccessStatus.authenticated(account: selfAccount);

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: FeaturedTags(schema: viewedAccount),
          accessStatus: status,
        ));
        await tester.pump();
      });

      // tags is empty and not self, so renders SizedBox.shrink
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('accepts required schema parameter', (tester) async {
      final account = MockAccount.create(id: '999');
      final status = MockAccessStatus.authenticated();

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: FeaturedTags(schema: account),
          accessStatus: status,
        ));
        await tester.pump();
      });

      expect(find.byType(FeaturedTags), findsOneWidget);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
