// Widget tests for AnnouncementSheet.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glacial/cores/screens/misc.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  setupTestEnvironment();

  group('AnnouncementSheet', () {
    testWidgets('renders with null status', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const AnnouncementSheet(status: null),
      ));
      await tester.pump();

      expect(find.byType(AnnouncementSheet), findsOneWidget);
    });

    testWidgets('shows title text', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const AnnouncementSheet(status: null),
      ));
      await tester.pump();

      expect(find.textContaining('Announcement'), findsOneWidget);
    });

    testWidgets('wrapped in Padding and Column', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const AnnouncementSheet(status: null),
      ));
      await tester.pump();

      expect(find.byType(Padding), findsWidgets);
      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('renders with no-domain status', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: const AnnouncementSheet(
            status: AccessStatusSchema(domain: null, accessToken: 'test'),
          ),
        ));
        await tester.pump();
      });

      expect(find.byType(AnnouncementSheet), findsOneWidget);
    });

    testWidgets('shows NoResult when announcements empty and loaded', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: const AnnouncementSheet(status: null),
        ));
        await tester.pump();
      });

      // After load with null status, announcements = [] → shows NoResult
      expect(find.byType(NoResult), findsOneWidget);
    });

    testWidgets('NoResult shows campaign icon', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: const AnnouncementSheet(status: null),
        ));
        await tester.pump();
      });

      expect(find.byIcon(Icons.campaign_outlined), findsOneWidget);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
