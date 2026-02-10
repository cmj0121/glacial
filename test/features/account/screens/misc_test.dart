// Widget tests for account misc screens: AccountList, FollowedHashtags.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  setupTestEnvironment();

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
  });
}

// vim: set ts=2 sw=2 sts=2 et:
