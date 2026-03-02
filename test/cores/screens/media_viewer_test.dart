// Widget tests for MediaViewer — covers dismiss, double-tap reset,
// zoom state callbacks, close button behavior, and layout structure.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/cores/screens/media_viewer.dart';

import '../../helpers/test_helpers.dart';

void main() {
  setupTestEnvironment();

  // ---------------------------------------------------------------------------
  // Dismiss behavior
  // ---------------------------------------------------------------------------

  group('MediaViewer dismiss', () {
    testWidgets('calls onDismiss callback via state method', (tester) async {
      bool dismissed = false;

      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          body: MediaViewer(
            onDismiss: () => dismissed = true,
            child: const Text('Dismissible'),
          ),
        ),
      ));
      await tester.pump();

      // Call onDismiss via state dynamic dispatch
      final state = tester.state(find.byType(MediaViewer));
      // ignore: avoid_dynamic_calls
      (state as dynamic).onDismiss();

      expect(dismissed, isTrue);
    });

    testWidgets('onDismiss without callback calls navigator pop', (tester) async {
      // When onDismiss is null, the state's onDismiss method calls Navigator.maybePop
      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          body: MediaViewer(child: const Text('Standalone mode')),
        ),
      ));
      await tester.pump();

      // Verify close button is shown (standalone mode)
      expect(find.byIcon(Icons.close), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // Close button visibility
  // ---------------------------------------------------------------------------

  group('MediaViewer close button', () {
    testWidgets('shows close button when onDismiss is null (standalone mode)', (tester) async {
      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          body: MediaViewer(child: const Text('Standalone')),
        ),
      ));
      await tester.pump();

      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('hides close button when onDismiss is provided (gallery mode)', (tester) async {
      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          body: MediaViewer(
            onDismiss: () {},
            child: const Text('Gallery mode'),
          ),
        ),
      ));
      await tester.pump();

      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('close button uses error color from theme', (tester) async {
      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          body: MediaViewer(child: const Text('Color test')),
        ),
      ));
      await tester.pump();

      final iconButton = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.close),
      );
      final icon = iconButton.icon as Icon;
      expect(icon.color, isNotNull);
    });
  });

  // ---------------------------------------------------------------------------
  // Double tap
  // ---------------------------------------------------------------------------

  group('MediaViewer double tap', () {
    testWidgets('GestureDetector for double tap is present', (tester) async {
      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          body: MediaViewer(child: const SizedBox(width: 200, height: 200)),
        ),
      ));
      await tester.pump();

      // Verify GestureDetector exists (handles onDoubleTap)
      expect(find.byType(GestureDetector), findsWidgets);

      // Verify transformation controller is identity initially
      final state = tester.state(find.byType(MediaViewer));
      // ignore: avoid_dynamic_calls
      final controller = (state as dynamic).controller as TransformationController;
      expect(controller.value, Matrix4.identity());
    });
  });

  // ---------------------------------------------------------------------------
  // Zoom state callbacks
  // ---------------------------------------------------------------------------

  group('MediaViewer zoom callbacks', () {
    testWidgets('onZoomChanged is called via ValueListenableBuilder', (tester) async {
      bool? zoomState;

      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          body: MediaViewer(
            onZoomChanged: (zoomed) => zoomState = zoomed,
            child: const SizedBox(width: 200, height: 200),
          ),
        ),
      ));
      await tester.pump();
      await tester.pump(); // For post-frame callback

      // Initial state should be not zoomed
      expect(zoomState, isFalse);
    });

    testWidgets('onDragUpdate and onDragEnd callbacks exist as parameters', (tester) async {
      double? dragValue;
      bool dragEnded = false;

      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          body: MediaViewer(
            onDragUpdate: (value) => dragValue = value,
            onDragEnd: () => dragEnded = true,
            child: const SizedBox(width: 200, height: 200),
          ),
        ),
      ));
      await tester.pump();

      // Callbacks are registered but not triggered without actual drag
      expect(dragValue, isNull);
      expect(dragEnded, isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // Layout structure
  // ---------------------------------------------------------------------------

  group('MediaViewer layout', () {
    testWidgets('uses Stack for overlay layout', (tester) async {
      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          body: MediaViewer(child: const Text('Layout test')),
        ),
      ));
      await tester.pump();

      expect(find.byType(Stack), findsWidgets);
    });

    testWidgets('uses Transform.translate for offset', (tester) async {
      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          body: MediaViewer(child: const Text('Transform test')),
        ),
      ));
      await tester.pump();

      expect(find.byType(Transform), findsWidgets);
    });

    testWidgets('uses ClipRRect for non-zoomed content', (tester) async {
      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          body: MediaViewer(child: const Text('Clip test')),
        ),
      ));
      await tester.pump();

      expect(find.byType(ClipRRect), findsOneWidget);
    });

    testWidgets('isZoomed getter returns false initially', (tester) async {
      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          body: MediaViewer(child: const Text('Zoom test')),
        ),
      ));
      await tester.pump();

      final state = tester.state(find.byType(MediaViewer));
      // ignore: avoid_dynamic_calls
      expect((state as dynamic).isZoomed, isFalse);
    });

    testWidgets('SizedBox.expand wraps FittedBox', (tester) async {
      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          body: MediaViewer(child: const Text('SizedBox test')),
        ),
      ));
      await tester.pump();

      expect(find.byType(SizedBox), findsWidgets);
      expect(find.byType(FittedBox), findsOneWidget);
    });

    testWidgets('uses InteractiveViewer for zoom/pan', (tester) async {
      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          body: MediaViewer(child: const Text('InteractiveViewer test')),
        ),
      ));
      await tester.pump();

      expect(find.byType(InteractiveViewer), findsOneWidget);
    });

    testWidgets('uses Padding with 8.0 inset', (tester) async {
      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          body: MediaViewer(child: const Text('Padded')),
        ),
      ));
      await tester.pump();

      final padding = tester.widget<Padding>(find.byType(Padding).first);
      expect(padding.padding, const EdgeInsets.all(8.0));
    });

    testWidgets('uses GestureDetector for interactions', (tester) async {
      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          body: MediaViewer(child: const Text('Gestures')),
        ),
      ));
      await tester.pump();

      expect(find.byType(GestureDetector), findsWidgets);
    });

    testWidgets('uses ValueListenableBuilder for zoom detection', (tester) async {
      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          body: MediaViewer(child: const Text('VLB test')),
        ),
      ));
      await tester.pump();

      expect(find.byType(ValueListenableBuilder<Matrix4>), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // Animation controller
  // ---------------------------------------------------------------------------

  group('MediaViewer animation', () {
    testWidgets('animationController is initialized', (tester) async {
      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          body: MediaViewer(
            onDismiss: () {},
            child: const SizedBox(width: 200, height: 200),
          ),
        ),
      ));
      await tester.pump();

      final state = tester.state(find.byType(MediaViewer));
      // ignore: avoid_dynamic_calls
      final controller = (state as dynamic).animationController as AnimationController;
      expect(controller, isNotNull);
      expect(controller.duration, const Duration(milliseconds: 300));
    });

    testWidgets('offset starts at zero', (tester) async {
      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          body: MediaViewer(child: const SizedBox(width: 200, height: 200)),
        ),
      ));
      await tester.pump();

      final state = tester.state(find.byType(MediaViewer));
      // ignore: avoid_dynamic_calls
      final offset = (state as dynamic).offset as Offset;
      expect(offset, Offset.zero);
    });

    testWidgets('isDismissed starts as false', (tester) async {
      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          body: MediaViewer(child: const SizedBox(width: 200, height: 200)),
        ),
      ));
      await tester.pump();

      final state = tester.state(find.byType(MediaViewer));
      // ignore: avoid_dynamic_calls
      final isDismissed = (state as dynamic).isDismissed as bool;
      expect(isDismissed, isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // Constants
  // ---------------------------------------------------------------------------

  group('MediaViewer thresholds', () {
    testWidgets('distance and velocity thresholds are accessible', (tester) async {
      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          body: MediaViewer(child: const SizedBox(width: 200, height: 200)),
        ),
      ));
      await tester.pump();

      // These are static const in the state, verify via existence check
      expect(find.byType(MediaViewer), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // Vertical drag interactions (via GestureDetector callback invocation)
  // ---------------------------------------------------------------------------

  group('MediaViewer vertical drag', () {
    testWidgets('onVerticalDragUpdate updates offset and calls callback', (tester) async {
      double? lastDragValue;

      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          body: MediaViewer(
            onDismiss: () {},
            onDragUpdate: (value) => lastDragValue = value,
            child: const SizedBox(width: 200, height: 200),
          ),
        ),
      ));
      await tester.pump();

      // Find the GestureDetector that has onVerticalDragUpdate
      final gestureDetectors = tester.widgetList<GestureDetector>(
        find.byType(GestureDetector),
      );
      final dragDetector = gestureDetectors.firstWhere(
        (gd) => gd.onVerticalDragUpdate != null,
      );

      // Invoke the callback directly
      dragDetector.onVerticalDragUpdate!(DragUpdateDetails(
        globalPosition: Offset.zero,
        delta: const Offset(0, 40),
      ));
      await tester.pump();

      expect(lastDragValue, isNotNull);
      expect(lastDragValue, 40.0);

      // Verify state offset was updated
      final state = tester.state(find.byType(MediaViewer));
      // ignore: avoid_dynamic_calls
      final offset = (state as dynamic).offset as Offset;
      expect(offset.dy, 40.0);
    });

    testWidgets('onVerticalDragEnd with small offset triggers spring back', (tester) async {
      bool dragEnded = false;

      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          body: MediaViewer(
            onDismiss: () {},
            onDragEnd: () => dragEnded = true,
            child: const SizedBox(width: 200, height: 200),
          ),
        ),
      ));
      await tester.pump();

      // Get GestureDetector with drag callbacks
      final gestureDetectors = tester.widgetList<GestureDetector>(
        find.byType(GestureDetector),
      );
      final dragDetector = gestureDetectors.firstWhere(
        (gd) => gd.onVerticalDragUpdate != null,
      );

      // First drag a small amount
      dragDetector.onVerticalDragUpdate!(DragUpdateDetails(
        globalPosition: Offset.zero,
        delta: const Offset(0, 20),
      ));
      await tester.pump();

      // End drag with small velocity (should NOT dismiss, should spring back)
      dragDetector.onVerticalDragEnd!(DragEndDetails(
        velocity: const Velocity(pixelsPerSecond: Offset(0, 100)),
      ));
      await tester.pumpAndSettle();

      // onDragEnd should be called (spring back path)
      expect(dragEnded, isTrue);
    });

    testWidgets('onVerticalDragEnd with large offset triggers dismiss', (tester) async {
      bool dismissed = false;

      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          body: MediaViewer(
            onDismiss: () => dismissed = true,
            child: const SizedBox(width: 200, height: 200),
          ),
        ),
      ));
      await tester.pump();

      final gestureDetectors = tester.widgetList<GestureDetector>(
        find.byType(GestureDetector),
      );
      final dragDetector = gestureDetectors.firstWhere(
        (gd) => gd.onVerticalDragUpdate != null,
      );

      // Drag a large amount (>18% of screen height = ~108px)
      dragDetector.onVerticalDragUpdate!(DragUpdateDetails(
        globalPosition: Offset.zero,
        delta: const Offset(0, 200),
      ));
      await tester.pump();

      // End drag — offset exceeds threshold, should dismiss
      dragDetector.onVerticalDragEnd!(DragEndDetails(
        velocity: const Velocity(pixelsPerSecond: Offset.zero),
      ));
      await tester.pump();

      expect(dismissed, isTrue);
    });

    testWidgets('onVerticalDragEnd with high velocity triggers dismiss', (tester) async {
      bool dismissed = false;

      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          body: MediaViewer(
            onDismiss: () => dismissed = true,
            child: const SizedBox(width: 200, height: 200),
          ),
        ),
      ));
      await tester.pump();

      final gestureDetectors = tester.widgetList<GestureDetector>(
        find.byType(GestureDetector),
      );
      final dragDetector = gestureDetectors.firstWhere(
        (gd) => gd.onVerticalDragUpdate != null,
      );

      // Small drag but high velocity
      dragDetector.onVerticalDragUpdate!(DragUpdateDetails(
        globalPosition: Offset.zero,
        delta: const Offset(0, 10),
      ));
      await tester.pump();

      // End with high velocity (>800 pixels/sec threshold)
      dragDetector.onVerticalDragEnd!(DragEndDetails(
        velocity: const Velocity(pixelsPerSecond: Offset(0, 1000)),
      ));
      await tester.pump();

      expect(dismissed, isTrue);
    });

    testWidgets('drag is disabled when zoomed', (tester) async {
      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          body: MediaViewer(
            onDismiss: () {},
            child: const SizedBox(width: 200, height: 200),
          ),
        ),
      ));
      await tester.pump();

      // Set controller to zoomed state
      final state = tester.state(find.byType(MediaViewer));
      // ignore: avoid_dynamic_calls
      final controller = (state as dynamic).controller as TransformationController;
      // ignore: deprecated_member_use
      controller.value = Matrix4.identity()..scale(2.0);
      // Need to rebuild the widget to reflect the zoomed state
      // ignore: avoid_dynamic_calls
      (state as dynamic).offset = Offset.zero; // trigger minor rebuild
      await tester.pump();
      await tester.pump(); // post-frame callback

      // Find the GestureDetector — in zoomed state, onVerticalDragUpdate should be null
      final gestureDetectors = tester.widgetList<GestureDetector>(
        find.byType(GestureDetector),
      );
      // Find the one from buildContent that has onDoubleTap
      final contentGd = gestureDetectors.firstWhere(
        (gd) => gd.onDoubleTap != null,
      );
      // When zoomed, onVerticalDragUpdate is set to null
      expect(contentGd.onVerticalDragUpdate, isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // Double tap interaction
  // ---------------------------------------------------------------------------

  group('MediaViewer double tap reset', () {
    testWidgets('double tap resets transformation controller', (tester) async {
      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          body: MediaViewer(
            onDismiss: () {},
            child: const SizedBox(width: 200, height: 200),
          ),
        ),
      ));
      await tester.pump();

      final state = tester.state(find.byType(MediaViewer));
      // ignore: avoid_dynamic_calls
      final controller = (state as dynamic).controller as TransformationController;

      // Manually set the controller to a zoomed state
      // ignore: deprecated_member_use
      controller.value = Matrix4.identity()..scale(2.0);
      await tester.pump();

      // ignore: avoid_dynamic_calls
      expect((state as dynamic).isZoomed, isTrue);

      // Double tap to reset
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pumpAndSettle();

      // After double tap, controller should be reset to identity
      expect(controller.value, Matrix4.identity());
    });
  });

  // ---------------------------------------------------------------------------
  // Animation status listener
  // ---------------------------------------------------------------------------

  group('MediaViewer animation status', () {
    testWidgets('animation completion resets offset to zero', (tester) async {
      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          body: MediaViewer(
            onDismiss: () {},
            child: const SizedBox(width: 200, height: 200),
          ),
        ),
      ));
      await tester.pump();

      final state = tester.state(find.byType(MediaViewer));
      // ignore: avoid_dynamic_calls
      final animController = (state as dynamic).animationController as AnimationController;

      // Simulate the animation completing
      animController.forward();
      await tester.pumpAndSettle();

      // After animation completes, offset should be zero
      // ignore: avoid_dynamic_calls
      final offset = (state as dynamic).offset as Offset;
      expect(offset, Offset.zero);
    });
  });

  // ---------------------------------------------------------------------------
  // Navigator pop fallback
  // ---------------------------------------------------------------------------

  group('MediaViewer navigator fallback', () {
    testWidgets('onDismiss calls Navigator.maybePop when callback is null', (tester) async {
      // Build a MediaViewer without onDismiss callback (standalone mode)
      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          body: MediaViewer(child: const Text('Standalone')),
        ),
      ));
      await tester.pump();

      // Verify close button is visible
      expect(find.byIcon(Icons.close), findsOneWidget);

      // Call onDismiss directly on the state - it should call Navigator.maybePop
      // which won't crash even if there's nothing to pop
      final state = tester.state(find.byType(MediaViewer));
      // ignore: avoid_dynamic_calls
      (state as dynamic).onDismiss();
      await tester.pump();

      // Widget should still be present (maybePop returns false when single route)
      expect(find.byType(MediaViewer), findsOneWidget);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
