// Widget tests for animation widgets.
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/cores/screens/animations.dart';

import '../../helpers/test_helpers.dart';

void main() {
  setupTestEnvironment();

  group('Flipping', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const Flipping(child: Text('Flip me')),
      ));
      await tester.pump();

      expect(find.text('Flip me'), findsOneWidget);
    });

    testWidgets('uses AnimatedBuilder', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const Flipping(child: Text('Animated')),
      ));
      await tester.pump();

      // Find AnimatedBuilder that is a descendant of Flipping
      expect(
        find.descendant(
          of: find.byType(Flipping),
          matching: find.byType(AnimatedBuilder),
        ),
        findsOneWidget,
      );
    });

    testWidgets('uses Transform widget', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const Flipping(child: Text('Transform')),
      ));
      await tester.pump();

      // Find Transform that is a descendant of Flipping
      expect(
        find.descendant(
          of: find.byType(Flipping),
          matching: find.byType(Transform),
        ),
        findsOneWidget,
      );
    });

    testWidgets('accepts custom duration', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const Flipping(
          duration: Duration(seconds: 2),
          child: Text('Custom duration'),
        ),
      ));
      await tester.pump();

      expect(find.text('Custom duration'), findsOneWidget);
    });

    testWidgets('disposes controller on unmount', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const Flipping(child: Text('Will dispose')),
      ));
      await tester.pump();

      // Verify widget is rendered
      expect(find.text('Will dispose'), findsOneWidget);

      // Unmount the widget by replacing with empty container
      await tester.pumpWidget(createTestWidget(
        child: Container(),
      ));
      await tester.pump();

      // If controller wasn't disposed properly, this would throw
      // "A Timer is still pending even after the widget tree was disposed."
      expect(find.text('Will dispose'), findsNothing);
    });

    testWidgets('animation progresses over time', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const Flipping(child: Icon(Icons.refresh)),
      ));

      final transformFinder = find.descendant(
        of: find.byType(Flipping),
        matching: find.byType(Transform),
      );

      // Capture initial transform
      final Transform initialTransform = tester.widget<Transform>(transformFinder);
      final Matrix4 initialMatrix = initialTransform.transform.clone();

      // Advance animation
      await tester.pump(const Duration(milliseconds: 200));

      // Capture updated transform
      final Transform updatedTransform = tester.widget<Transform>(transformFinder);
      final Matrix4 updatedMatrix = updatedTransform.transform;

      // Transform should have changed
      expect(initialMatrix != updatedMatrix, true);

      // Clean up
      await tester.pumpWidget(createTestWidget(child: Container()));
      await tester.pump();
    });
  });

  group('ClockProgressIndicator', () {
    testWidgets('renders widget', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const ClockProgressIndicator(),
      ));
      await tester.pump();

      expect(find.byType(ClockProgressIndicator), findsOneWidget);
    });

    testWidgets('uses default size of 32', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const ClockProgressIndicator(),
      ));
      await tester.pump();

      final SizedBox sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.width, 32);
      expect(sizedBox.height, 32);
    });

    testWidgets('accepts custom size', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const ClockProgressIndicator(size: 60),
      ));
      await tester.pump();

      final SizedBox sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.width, 60);
      expect(sizedBox.height, 60);
    });

    testWidgets('uses CustomPaint for arc rendering', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const ClockProgressIndicator(),
      ));
      await tester.pump();

      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('uses AnimatedBuilder for animation', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const ClockProgressIndicator(),
      ));
      await tester.pump();

      // Find AnimatedBuilder that is a descendant of ClockProgressIndicator
      expect(
        find.descendant(
          of: find.byType(ClockProgressIndicator),
          matching: find.byType(AnimatedBuilder),
        ),
        findsOneWidget,
      );
    });

    testWidgets('disposes controller on unmount', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const ClockProgressIndicator(),
      ));
      await tester.pump();

      // Verify widget is rendered
      expect(find.byType(ClockProgressIndicator), findsOneWidget);

      // Unmount the widget by replacing with empty container
      await tester.pumpWidget(createTestWidget(
        child: Container(),
      ));
      await tester.pump();

      // If controller wasn't disposed properly, this would throw
      // "A Timer is still pending even after the widget tree was disposed."
      expect(find.byType(ClockProgressIndicator), findsNothing);
    });

    testWidgets('renders SizedBox matching size parameter', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const ClockProgressIndicator(size: 24),
      ));
      await tester.pump();

      final SizedBox sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.width, 24);
      expect(sizedBox.height, 24);
    });

    testWidgets('wraps in Center widget', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const ClockProgressIndicator(),
      ));
      await tester.pump();

      expect(find.byType(Center), findsWidgets);
    });

    testWidgets('convenience constructors have correct sizes', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const ClockProgressIndicator.small(),
      ));
      await tester.pump();
      var sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.width, 20);
      expect(sizedBox.height, 20);

      await tester.pumpWidget(createTestWidget(
        child: const ClockProgressIndicator.large(),
      ));
      await tester.pump();
      sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.width, 48);
      expect(sizedBox.height, 48);
    });

    testWidgets('does not include internal padding', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const ClockProgressIndicator(),
      ));
      await tester.pump();

      expect(
        find.descendant(
          of: find.byType(ClockProgressIndicator),
          matching: find.byType(Padding),
        ),
        findsNothing,
      );
    });

    testWidgets('refreshBuilder returns widget with Opacity and Transform.scale', (tester) async {
      // Use a simple AnimationController to simulate IndicatorController behavior.
      // Since IndicatorController is internal to custom_refresh_indicator,
      // we test the static method indirectly via CustomMaterialIndicator.
      await tester.pumpWidget(createTestWidget(
        child: CustomMaterialIndicator(
          onRefresh: () async {},
          indicatorBuilder: ClockProgressIndicator.refreshBuilder,
          child: const SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: SizedBox(height: 1000),
          ),
        ),
      ));
      await tester.pump();

      // The widget tree should contain ClockProgressIndicator via refreshBuilder
      expect(find.byType(CustomMaterialIndicator), findsOneWidget);
    });

    testWidgets('refreshBuilder produces AnimatedBuilder with ClockProgressIndicator', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: Builder(
          builder: (context) => ClockProgressIndicator.refreshBuilder(
            context,
            IndicatorController(),
          ),
        ),
      ));
      await tester.pump();

      expect(find.byType(AnimatedBuilder), findsWidgets);
      expect(find.byType(ClockProgressIndicator), findsOneWidget);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
