// Widget tests for directory screens: DirectoryType, DirectoryTab.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:glacial/core.dart';
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
  });
}

// vim: set ts=2 sw=2 sts=2 et:
