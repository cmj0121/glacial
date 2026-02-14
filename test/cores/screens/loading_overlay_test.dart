// Widget tests for LoadingOverlay.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/cores/screens/animations.dart';
import 'package:glacial/cores/screens/loading_overlay.dart';

import '../../helpers/test_helpers.dart';

void main() {
  setupTestEnvironment();

  group('LoadingOverlay', () {
    testWidgets('shows child when not loading', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const LoadingOverlay(
          isLoading: false,
          child: Text('Content'),
        ),
      ));
      await tester.pump();

      expect(find.text('Content'), findsOneWidget);
      expect(find.byType(ClockProgressIndicator), findsNothing);
    });

    testWidgets('shows spinner overlay when loading', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const LoadingOverlay(
          isLoading: true,
          child: Text('Content'),
        ),
      ));
      await tester.pump();

      expect(find.text('Content'), findsOneWidget);
      expect(find.byType(ClockProgressIndicator), findsOneWidget);
    });

    testWidgets('uses Stack to layer overlay on top of child', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const LoadingOverlay(
          isLoading: true,
          child: Text('Underneath'),
        ),
      ));
      await tester.pump();

      expect(
        find.descendant(
          of: find.byType(LoadingOverlay),
          matching: find.byType(Stack),
        ),
        findsOneWidget,
      );
    });

    testWidgets('overlay uses Positioned.fill to cover content', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const LoadingOverlay(
          isLoading: true,
          child: SizedBox(width: 200, height: 200),
        ),
      ));
      await tester.pump();

      expect(
        find.descendant(
          of: find.byType(LoadingOverlay),
          matching: find.byType(Positioned),
        ),
        findsOneWidget,
      );
    });

    testWidgets('overlay uses semi-transparent ColoredBox', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const LoadingOverlay(
          isLoading: true,
          child: SizedBox(width: 200, height: 200),
        ),
      ));
      await tester.pump();

      final coloredBox = tester.widget<ColoredBox>(
        find.descendant(
          of: find.byType(LoadingOverlay),
          matching: find.byType(ColoredBox),
        ),
      );

      // Should be semi-transparent (alpha < 1.0)
      expect(coloredBox.color.a, lessThan(1.0));
      expect(coloredBox.color.a, greaterThan(0.0));
    });

    testWidgets('no overlay widgets when not loading', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const LoadingOverlay(
          isLoading: false,
          child: Text('Only me'),
        ),
      ));
      await tester.pump();

      expect(
        find.descendant(
          of: find.byType(LoadingOverlay),
          matching: find.byType(Positioned),
        ),
        findsNothing,
      );
      expect(find.byType(ClockProgressIndicator), findsNothing);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
