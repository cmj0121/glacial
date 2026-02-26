// Widget tests for SingleNotification.
import 'package:flutter_test/flutter_test.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

import '../../../helpers/test_helpers.dart';

// Use domain-null status so API calls short-circuit without HTTP.
AccessStatusSchema _noDomainAuth() {
  return const AccessStatusSchema(domain: null, accessToken: 'test');
}

GroupSchema _makeGroup({
  required String type,
  String key = 'grp-1',
  String? statusId,
  List<String> accounts = const [],
}) {
  return GroupSchema.fromJson({
    'type': type,
    'group_key': key,
    'notifications_count': 1,
    'most_recent_notification_id': 1,
    'sample_account_ids': accounts,
    if (statusId != null) 'status_id': statusId,
  });
}

void main() {
  setupTestEnvironment();

  group('SingleNotification', () {
    testWidgets('renders with mention type', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: SingleNotification(schema: _makeGroup(type: 'mention')),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();
      });

      expect(find.byType(SingleNotification), findsOneWidget);
    });

    testWidgets('renders with follow type', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: SingleNotification(schema: _makeGroup(type: 'follow')),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();
      });

      expect(find.byType(SingleNotification), findsOneWidget);
    });

    testWidgets('renders with favourite type', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: SingleNotification(schema: _makeGroup(type: 'favourite')),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();
      });

      expect(find.byType(SingleNotification), findsOneWidget);
    });

    testWidgets('renders with reblog type', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: SingleNotification(schema: _makeGroup(type: 'reblog')),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();
      });

      expect(find.byType(SingleNotification), findsOneWidget);
    });

    testWidgets('renders with unknown type', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: SingleNotification(schema: _makeGroup(type: 'xyz_unknown')),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();
      });

      expect(find.byType(SingleNotification), findsOneWidget);
    });

    testWidgets('shows loading state before async completes', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: SingleNotification(schema: _makeGroup(type: 'mention')),
        accessStatus: _noDomainAuth(),
      ));

      expect(find.byType(SingleNotification), findsOneWidget);
    });

    testWidgets('accepts custom iconSize', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: SingleNotification(
            schema: _makeGroup(type: 'follow'),
            iconSize: 24,
          ),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();
      });

      expect(find.byType(SingleNotification), findsOneWidget);
    });

    testWidgets('renders with poll type', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: SingleNotification(schema: _makeGroup(type: 'poll')),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();
      });

      expect(find.byType(SingleNotification), findsOneWidget);
    });

    testWidgets('renders with admin.sign_up type', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: SingleNotification(schema: _makeGroup(type: 'admin.sign_up')),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();
      });

      expect(find.byType(SingleNotification), findsOneWidget);
    });

    testWidgets('renders with follow_request type', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: SingleNotification(schema: _makeGroup(type: 'follow_request')),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();
      });

      expect(find.byType(SingleNotification), findsOneWidget);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
