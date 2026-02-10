// Widget tests for StatusInfo component.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/timeline/screens/status_info.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  setUpAll(() => setupTestEnvironment());

  // Use an access status with no domain to prevent real API calls.
  final accessStatus = AccessStatusSchema(domain: null);

  Widget buildStatusInfo(StatusSchema status) {
    return SizedBox(
      height: 400,
      child: StatusInfo(schema: status),
    );
  }

  group('StatusInfo', () {
    group('rendering', () {
      testWidgets('renders with status', (tester) async {
        final status = MockStatus.create();

        await tester.pumpWidget(createTestWidget(
          accessStatus: accessStatus,
          child: buildStatusInfo(status),
        ));
        await tester.pump();

        expect(find.byType(StatusInfo), findsOneWidget);
      });

      testWidgets('shows SwipeTabView', (tester) async {
        final status = MockStatus.create();

        await tester.pumpWidget(createTestWidget(
          accessStatus: accessStatus,
          child: buildStatusInfo(status),
        ));
        await tester.pump();

        expect(find.byType(SwipeTabView), findsOneWidget);
      });
    });

    group('tabs', () {
      testWidgets('shows reblog tab icon', (tester) async {
        final status = MockStatus.create(reblogsCount: 3);

        await tester.pumpWidget(createTestWidget(
          accessStatus: accessStatus,
          child: buildStatusInfo(status),
        ));
        await tester.pump();

        // Reblog tab uses repeat icon (active for selected tab)
        expect(find.byIcon(Icons.repeat), findsOneWidget);
      });

      testWidgets('shows favourite tab icon', (tester) async {
        final status = MockStatus.create(favouritesCount: 5);

        await tester.pumpWidget(createTestWidget(
          accessStatus: accessStatus,
          child: buildStatusInfo(status),
        ));
        await tester.pump();

        // Favourite tab uses star_outline_outlined icon (inactive, not selected)
        expect(find.byIcon(Icons.star_outline_outlined), findsOneWidget);
      });

      testWidgets('has Tooltip on tabs', (tester) async {
        final status = MockStatus.create();

        await tester.pumpWidget(createTestWidget(
          accessStatus: accessStatus,
          child: buildStatusInfo(status),
        ));
        await tester.pump();

        expect(find.byType(Tooltip), findsWidgets);
      });

      testWidgets('uses Align with topCenter alignment', (tester) async {
        final status = MockStatus.create();

        await tester.pumpWidget(createTestWidget(
          accessStatus: accessStatus,
          child: buildStatusInfo(status),
        ));
        await tester.pump();

        final align = tester.widget<Align>(find.byType(Align).first);
        expect(align.alignment, Alignment.topCenter);
      });
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
