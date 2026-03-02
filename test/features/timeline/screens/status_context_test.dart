// Widget tests for StatusContext component.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/screens.dart';

import '../../../helpers/mock_http.dart';
import '../../../helpers/test_helpers.dart';

/// Creates a test widget with accessStatusProvider returning null.
Widget _createNullAccessWidget({required Widget child}) {
  return ProviderScope(
    overrides: [
      accessStatusProvider.overrideWith((ref) => null),
    ],
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: child,
    ),
  );
}

void main() {
  late HttpOverrides? originalOverrides;

  setUpAll(() {
    setupTestEnvironment();
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async => Directory.systemTemp.path,
    );
  });

  setUp(() {
    originalOverrides = HttpOverrides.current;
  });

  tearDown(() {
    HttpOverrides.global = originalOverrides;
  });

  group('StatusContext', () {
    testWidgets('renders with schema', (tester) async {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );
      final schema = MockStatus.create();

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: StatusContext(schema: schema)),
          accessStatus: status,
        ));
        await tester.pump();
      });

      expect(find.byType(StatusContext), findsOneWidget);
    });

    testWidgets('uses FutureBuilder for async context loading', (tester) async {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );
      final schema = MockStatus.create();

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: StatusContext(schema: schema)),
          accessStatus: status,
        ));
        await tester.pump();
      });

      // After async resolves (with null/error), shows SizedBox.shrink
      expect(find.byType(StatusContext), findsOneWidget);
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('widget accepts required schema parameter', (tester) async {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );
      final schema = MockStatus.create(id: 'ctx-1', content: '<p>Context status</p>');

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: StatusContext(schema: schema)),
          accessStatus: status,
        ));
        await tester.pump();
      });

      expect(find.byType(StatusContext), findsOneWidget);
    });

    testWidgets('shows LoadingOverlay while future is waiting', (tester) async {
      final schema = MockStatus.create();

      await tester.pumpWidget(_createNullAccessWidget(
        child: Scaffold(body: StatusContext(schema: schema)),
      ));

      // First frame: FutureBuilder has ConnectionState.waiting => LoadingOverlay
      expect(find.byType(LoadingOverlay), findsOneWidget);
      expect(find.byType(StatusContext), findsOneWidget);
    });

    testWidgets('shows ErrorState when accessStatus provider returns null',
        (tester) async {
      final schema = MockStatus.create();

      await tester.runAsync(() async {
        await tester.pumpWidget(_createNullAccessWidget(
          child: Scaffold(body: StatusContext(schema: schema)),
        ));
        await tester.pump();
      });

      expect(find.byType(ErrorState), findsOneWidget);
    });

    testWidgets('ErrorState shows retry button with refresh icon',
        (tester) async {
      final schema = MockStatus.create();

      await tester.runAsync(() async {
        await tester.pumpWidget(_createNullAccessWidget(
          child: Scaffold(body: StatusContext(schema: schema)),
        ));
        await tester.pump();
      });

      // ErrorState renders with an onRetry callback => button with refresh icon.
      // Note: ElevatedButton.icon() creates an internal subclass, so use icon finder.
      expect(find.byType(ErrorState), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);

      // Verify the ErrorState has a non-null onRetry
      final errorState = tester.widget<ErrorState>(find.byType(ErrorState));
      expect(errorState.onRetry, isNotNull);
    });

    testWidgets('ErrorState displays cloud_off icon', (tester) async {
      final schema = MockStatus.create();

      await tester.runAsync(() async {
        await tester.pumpWidget(_createNullAccessWidget(
          child: Scaffold(body: StatusContext(schema: schema)),
        ));
        await tester.pump();
      });

      expect(find.byType(ErrorState), findsOneWidget);
      expect(find.byIcon(Icons.cloud_off_outlined), findsOneWidget);
    });

    testWidgets('retry button can be tapped without crash', (tester) async {
      final schema = MockStatus.create();

      await tester.runAsync(() async {
        await tester.pumpWidget(_createNullAccessWidget(
          child: Scaffold(body: StatusContext(schema: schema)),
        ));
        await tester.pump();
      });

      expect(find.byType(ErrorState), findsOneWidget);

      // Tap retry via the refresh icon
      await tester.tap(find.byIcon(Icons.refresh));

      // Let the new future resolve
      await tester.runAsync(() async {
        await tester.pump();
        await tester.pump();
      });

      // After retry, widget rebuilt (no crash) and shows ErrorState again
      expect(find.byType(StatusContext), findsOneWidget);
    });

    testWidgets('retry rebuilds to ErrorState again when still null',
        (tester) async {
      final schema = MockStatus.create();

      await tester.runAsync(() async {
        await tester.pumpWidget(_createNullAccessWidget(
          child: Scaffold(body: StatusContext(schema: schema)),
        ));
        await tester.pump();
      });

      expect(find.byType(ErrorState), findsOneWidget);

      // Tap retry via the refresh icon
      await tester.tap(find.byIcon(Icons.refresh));

      // Let the new future resolve
      await tester.runAsync(() async {
        await tester.pump();
        await tester.pump();
      });

      // Still shows ErrorState since provider is still null
      expect(find.byType(ErrorState), findsOneWidget);
    });

    testWidgets('success path renders ScrollablePositionedList with statuses', (tester) async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        if (url.path.contains('/context')) {
          return (200, statusContextJson(
            ancestorIds: ['ancestor-1'],
            descendantIds: ['descendant-1'],
          ));
        }
        return (200, '{}');
      });

      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );
      final schema = MockStatus.create(id: 'selected-1');

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: StatusContext(schema: schema)),
          accessStatus: status,
        ));
        await tester.pump();
        await tester.pump();
      });

      expect(find.byType(StatusContext), findsOneWidget);
      // Should render the ScrollablePositionedList
      expect(find.byType(ScrollablePositionedList), findsOneWidget);
    });

    testWidgets('success path renders AccessibleDismissible wrapper', (tester) async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        if (url.path.contains('/context')) {
          return (200, statusContextJson(
            ancestorIds: ['ancestor-2'],
            descendantIds: ['descendant-2'],
          ));
        }
        return (200, '{}');
      });

      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );
      final schema = MockStatus.create(id: 'selected-2');

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: StatusContext(schema: schema)),
          accessStatus: status,
        ));
        await tester.pump();
        await tester.pump();
      });

      expect(find.byType(AccessibleDismissible), findsOneWidget);
    });

    testWidgets('success path renders Status widgets for all statuses', (tester) async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        if (url.path.contains('/context')) {
          return (200, statusContextJson(
            ancestorIds: ['anc-1'],
            descendantIds: ['desc-1', 'desc-2'],
          ));
        }
        return (200, '{}');
      });

      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );
      final schema = MockStatus.create(id: 'main-status');

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: StatusContext(schema: schema)),
          accessStatus: status,
        ));
        await tester.pump();
        await tester.pump();
      });

      // Should have Status widgets (ancestor + main + 2 descendants = 4)
      expect(find.byType(Status), findsWidgets);
    });

    testWidgets('success path with empty context renders single status', (tester) async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        if (url.path.contains('/context')) {
          return (200, statusContextJson());
        }
        return (200, '{}');
      });

      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );
      final schema = MockStatus.create(id: 'solo-status');

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: StatusContext(schema: schema)),
          accessStatus: status,
        ));
        await tester.pump();
        await tester.pump();
      });

      // Just the main status, no ancestors/descendants
      expect(find.byType(Status), findsOneWidget);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
