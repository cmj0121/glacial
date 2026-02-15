import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/cores/screens/shimmer.dart';

import '../../helpers/test_helpers.dart';

void main() {
  setupTestEnvironment();

  group('ShimmerEffect', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: ShimmerEffect(
          child: Container(width: 100, height: 50, color: Colors.red),
        ),
      ));
      await tester.pump();

      expect(find.byType(ShimmerEffect), findsOneWidget);
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('contains ShaderMask for gradient effect', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: ShimmerEffect(
          child: SizedBox(width: 100, height: 50),
        ),
      ));
      await tester.pump();

      expect(find.byType(ShaderMask), findsOneWidget);
    });

    testWidgets('accepts custom duration', (tester) async {
      const duration = Duration(milliseconds: 2000);

      await tester.pumpWidget(createTestWidget(
        child: ShimmerEffect(
          duration: duration,
          child: SizedBox(width: 100, height: 50),
        ),
      ));
      await tester.pump();

      final ShimmerEffect widget = tester.widget(find.byType(ShimmerEffect));
      expect(widget.duration, duration);
    });

    testWidgets('animation progresses over time', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: ShimmerEffect(
          child: Container(width: 100, height: 50, color: Colors.grey),
        ),
      ));
      await tester.pump();

      // Pump partial duration to advance animation
      await tester.pump(const Duration(milliseconds: 750));
      expect(find.byType(ShaderMask), findsOneWidget);

      // Pump again to continue animation
      await tester.pump(const Duration(milliseconds: 750));
      expect(find.byType(ShaderMask), findsOneWidget);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
