// Tests for NotificationPolicySheet widget.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/notifications/screens/notification_policy.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  setupTestEnvironment();

  group('NotificationPolicySheet', () {
    testWidgets('renders with null status', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const NotificationPolicySheet(status: null),
      ));
      await tester.pump();

      expect(find.byType(NotificationPolicySheet), findsOneWidget);
    });

    testWidgets('is wrapped in Padding', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const NotificationPolicySheet(status: null),
      ));
      await tester.pump();

      expect(find.byType(Padding), findsWidgets);
    });

    testWidgets('contains Column layout', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const NotificationPolicySheet(status: null),
      ));
      await tester.pump();

      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('renders with no-domain status', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: const NotificationPolicySheet(
            status: AccessStatusSchema(domain: null, accessToken: 'test'),
          ),
        ));
        await tester.pump();
      });

      expect(find.byType(NotificationPolicySheet), findsOneWidget);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
