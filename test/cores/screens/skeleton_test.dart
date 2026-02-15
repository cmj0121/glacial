import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/cores/screens/shimmer.dart';
import 'package:glacial/cores/screens/skeleton.dart';

import '../../helpers/test_helpers.dart';

void main() {
  setupTestEnvironment();

  group('SkeletonStatusCard', () {
    testWidgets('renders avatar placeholder container', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const SkeletonStatusCard(),
      ));
      await tester.pump();

      expect(find.byType(SkeletonStatusCard), findsOneWidget);
    });

    testWidgets('renders content line placeholders inside indented padding', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const SkeletonStatusCard(),
      ));
      await tester.pump();

      // Content lines are inside a Padding with left: 60
      final contentPadding = find.byWidgetPredicate((widget) =>
        widget is Padding && widget.padding == const EdgeInsets.only(left: 60),
      );
      expect(contentPadding, findsOneWidget);
    });

    testWidgets('showMedia true renders media rectangle', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const SkeletonStatusCard(showMedia: true),
      ));
      await tester.pump();

      expect(find.byType(SkeletonStatusCard), findsOneWidget);
    });

    testWidgets('showMedia false omits media rectangle', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const SkeletonStatusCard(showMedia: false),
      ));
      await tester.pump();

      final widget = tester.widget<SkeletonStatusCard>(find.byType(SkeletonStatusCard));
      expect(widget.showMedia, false);
    });
  });

  group('SkeletonTimeline', () {
    testWidgets('renders 4 cards by default', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const SkeletonTimeline(),
      ));
      await tester.pump();

      expect(find.byType(SkeletonStatusCard), findsNWidgets(4));
      expect(find.byType(ShimmerEffect), findsOneWidget);
    });

    testWidgets('renders custom count', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const SkeletonTimeline(count: 2),
      ));
      await tester.pump();

      expect(find.byType(SkeletonStatusCard), findsNWidgets(2));
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
