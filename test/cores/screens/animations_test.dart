// Widget tests for animation widgets.
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

    testWidgets('uses default size of 40', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const ClockProgressIndicator(),
      ));
      await tester.pump();

      // Default size is 40, so SizedBox should be 80x80 (size * 2)
      final SizedBox sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.width, 80);
      expect(sizedBox.height, 80);
    });

    testWidgets('accepts custom size', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const ClockProgressIndicator(size: 60),
      ));
      await tester.pump();

      // Custom size is 60, so SizedBox should be 120x120 (size * 2)
      final SizedBox sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.width, 120);
      expect(sizedBox.height, 120);
    });

    testWidgets('creates 12 clock bars', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const ClockProgressIndicator(),
      ));
      await tester.pump();

      // The clock indicator creates 12 Positioned widgets (one for each hour)
      expect(find.byType(Positioned), findsNWidgets(12));
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

    testWidgets('uses Stack for bar layout', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const ClockProgressIndicator(),
      ));
      await tester.pump();

      expect(find.byType(Stack), findsWidgets);
    });

    testWidgets('wraps in Center widget', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const ClockProgressIndicator(),
      ));
      await tester.pump();

      expect(find.byType(Center), findsWidgets);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
