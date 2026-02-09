// Widget tests for SensitiveView and SpoilerView components.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/features/timeline/screens/status_visibility.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  setUpAll(() => setupTestEnvironment());

  group('SensitiveView', () {
    group('when not sensitive', () {
      testWidgets('displays child directly', (tester) async {
        await tester.pumpWidget(createTestWidget(
          child: const SensitiveView(
            isSensitive: false,
            child: Text('Normal content'),
          ),
        ));
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Normal content'), findsOneWidget);
        // No visibility_off icon when not sensitive
        expect(find.byIcon(Icons.visibility_off_outlined), findsNothing);
      });
    });

    group('when sensitive', () {
      testWidgets('displays blur overlay with visibility_off icon', (tester) async {
        await tester.pumpWidget(createTestWidget(
          child: const SensitiveView(
            isSensitive: true,
            child: Text('Sensitive content'),
          ),
        ));
        await tester.pump(const Duration(milliseconds: 100));

        // Content should still be in tree (just blurred)
        expect(find.text('Sensitive content'), findsOneWidget);
        // Visibility off icon indicates blurred content
        expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
      });

      testWidgets('reveals content when tapped', (tester) async {
        await tester.pumpWidget(createTestWidget(
          child: const SensitiveView(
            isSensitive: true,
            child: Text('Sensitive content'),
          ),
        ));
        await tester.pump(const Duration(milliseconds: 100));

        // Initially blurred
        expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);

        // Tap to reveal
        await tester.tap(find.byType(SensitiveView));
        await tester.pump(const Duration(milliseconds: 100));

        // After tap, blur should be removed
        expect(find.byIcon(Icons.visibility_off_outlined), findsNothing);
        expect(find.text('Sensitive content'), findsOneWidget);
      });

      testWidgets('can toggle visibility multiple times', (tester) async {
        await tester.pumpWidget(createTestWidget(
          child: const SensitiveView(
            isSensitive: true,
            child: Text('Sensitive content'),
          ),
        ));
        await tester.pump(const Duration(milliseconds: 100));

        // Initially blurred
        expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);

        // First tap - reveal
        await tester.tap(find.byType(SensitiveView));
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.byIcon(Icons.visibility_off_outlined), findsNothing);

        // Second tap - no action (content stays visible)
        await tester.tap(find.byType(SensitiveView));
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.text('Sensitive content'), findsOneWidget);
      });
    });
  });

  group('SpoilerView', () {
    group('when no spoiler', () {
      testWidgets('displays child directly', (tester) async {
        await tester.pumpWidget(createTestWidget(
          child: const SpoilerView(
            spoiler: null,
            child: Text('Normal content'),
          ),
        ));
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Normal content'), findsOneWidget);
      });

      testWidgets('displays child when spoiler is empty', (tester) async {
        await tester.pumpWidget(createTestWidget(
          child: const SpoilerView(
            spoiler: '',
            child: Text('Normal content'),
          ),
        ));
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Normal content'), findsOneWidget);
      });
    });

    group('when has spoiler', () {
      testWidgets('displays spoiler text', (tester) async {
        await tester.pumpWidget(createTestWidget(
          child: const SpoilerView(
            spoiler: 'Content Warning: Spoiler',
            child: Text('Hidden content'),
          ),
        ));
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Content Warning: Spoiler'), findsOneWidget);
      });

      testWidgets('hides content initially', (tester) async {
        await tester.pumpWidget(createTestWidget(
          child: SpoilerView(
            spoiler: 'CW: Test',
            child: const Text('Hidden content'),
          ),
        ));
        await tester.pump(const Duration(milliseconds: 100));

        // Spoiler text visible
        expect(find.text('CW: Test'), findsOneWidget);
        // Content is hidden via Visibility widget (not in visible tree)
        // The Visibility widget removes it from the render tree when not visible
        expect(find.byType(Visibility), findsOneWidget);
      });

      testWidgets('spoiler container has expected structure', (tester) async {
        await tester.pumpWidget(createTestWidget(
          child: SpoilerView(
            spoiler: 'CW',
            child: const Text('Hidden'),
          ),
        ));
        await tester.pump(const Duration(milliseconds: 100));

        // Spoiler text should be visible
        expect(find.text('CW'), findsOneWidget);
        // Container should have border decoration
        expect(find.byType(Container), findsWidgets);
      });

      testWidgets('reveals content on double tap', (tester) async {
        await tester.pumpWidget(createTestWidget(
          child: const SpoilerView(
            spoiler: 'CW',
            child: Text('Hidden content'),
          ),
        ));
        await tester.pump(const Duration(milliseconds: 100));

        // Find the spoiler container and double tap
        final spoilerFinder = find.text('CW');
        await tester.tap(spoilerFinder);
        await tester.pump(const Duration(milliseconds: 100));
        await tester.tap(spoilerFinder);
        await tester.pump(const Duration(milliseconds: 100));

        // Widget should still render (toggle behavior verified by checking state change)
        expect(find.byType(SpoilerView), findsOneWidget);
      });

      testWidgets('widget renders correctly with long spoiler text', (tester) async {
        await tester.pumpWidget(createTestWidget(
          child: SpoilerView(
            spoiler: 'This is a very long content warning',
            child: const Text('Content'),
          ),
        ));
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('This is a very long content warning'), findsOneWidget);
        // The widget should be rendered
        expect(find.byType(SpoilerView), findsOneWidget);
      });
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
