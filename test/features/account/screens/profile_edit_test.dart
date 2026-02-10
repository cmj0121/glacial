// Widget tests for profile edit screens: EditProfilePage, EditProfileCategory.
import 'dart:io';

import 'package:flutter/cupertino.dart';
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

  group('EditProfilePage', () {
    setUpAll(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        (MethodCall methodCall) async => Directory.systemTemp.path,
      );
    });

    testWidgets('renders SwipeTabView', (tester) async {
      final account = MockAccount.create();
      final status = MockAccessStatus.authenticated(account: account);

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(
            body: EditProfilePage(account: account),
          ),
          accessStatus: status,
        ));
        await tester.pump();
      });

      expect(find.byType(SwipeTabView), findsOneWidget);
    });

    testWidgets('shows tab icons for categories', (tester) async {
      final account = MockAccount.create();
      final status = MockAccessStatus.authenticated(account: account);

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(
            body: EditProfilePage(account: account),
          ),
          accessStatus: status,
        ));
        await tester.pump();
      });

      // The general tab should show its active icon (selected by default)
      expect(find.byIcon(CupertinoIcons.doc_person_fill), findsOneWidget);
      // The privacy tab should show its inactive icon
      expect(find.byIcon(Icons.privacy_tip_outlined), findsOneWidget);
    });
  });

  group('EditProfilePage.icon', () {
    testWidgets('renders icon button', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: EditProfilePage.icon(),
      ));
      await tester.pump();

      expect(find.byType(IconButton), findsOneWidget);
    });

    testWidgets('shows manage_accounts_outlined icon', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: EditProfilePage.icon(),
      ));
      await tester.pump();

      expect(find.byIcon(Icons.manage_accounts_outlined), findsOneWidget);
    });
  });

  group('EditProfileCategory', () {
    test('has 2 values', () {
      expect(EditProfileCategory.values.length, 2);
      expect(EditProfileCategory.values, contains(EditProfileCategory.general));
      expect(EditProfileCategory.values, contains(EditProfileCategory.privacy));
    });

    test('each has icon() method', () {
      for (final category in EditProfileCategory.values) {
        expect(category.icon(), isA<IconData>());
        expect(category.icon(active: true), isA<IconData>());
        expect(category.icon(active: false), isA<IconData>());
      }
    });

    testWidgets('each has tooltip() method', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: Builder(
          builder: (context) {
            for (final category in EditProfileCategory.values) {
              final tooltip = category.tooltip(context);
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
}

// vim: set ts=2 sw=2 sts=2 et:
