// Widget tests for StatusContext component.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/features/screens.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  setupTestEnvironment();

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
  });
}

// vim: set ts=2 sw=2 sts=2 et:
