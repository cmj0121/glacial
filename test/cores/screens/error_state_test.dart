// Widget tests for error handling components.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/cores/screens/error_state.dart';

import '../../helpers/test_helpers.dart';

void main() {
  setUpAll(() => setupTestEnvironment());

  group('ImageErrorPlaceholder', () {
    testWidgets('renders broken image icon', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const ImageErrorPlaceholder(),
      ));

      expect(find.byIcon(Icons.broken_image_outlined), findsOneWidget);
    });

    testWidgets('uses default size of 24', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const ImageErrorPlaceholder(),
      ));

      final Icon icon = tester.widget<Icon>(find.byIcon(Icons.broken_image_outlined));
      expect(icon.size, 24);
    });

    testWidgets('uses custom size', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const ImageErrorPlaceholder(size: 48),
      ));

      final Icon icon = tester.widget<Icon>(find.byIcon(Icons.broken_image_outlined));
      expect(icon.size, 48);
    });

    testWidgets('uses theme outline color', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const ImageErrorPlaceholder(),
      ));

      final Icon icon = tester.widget<Icon>(find.byIcon(Icons.broken_image_outlined));
      final BuildContext context = tester.element(find.byType(ImageErrorPlaceholder));
      expect(icon.color, Theme.of(context).colorScheme.outline);
    });
  });

  group('ErrorState', () {
    testWidgets('shows error icon and message', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const ErrorState(message: 'Test error'),
      ));

      expect(find.byIcon(Icons.cloud_off_outlined), findsOneWidget);
      expect(find.text('Test error'), findsOneWidget);
    });

    testWidgets('shows retry button when onRetry provided', (tester) async {
      bool retried = false;

      await tester.pumpWidget(createTestWidget(
        child: ErrorState(
          message: 'Test error',
          onRetry: () => retried = true,
        ),
      ));
      await tester.pump();

      // Find the retry button via the refresh icon
      expect(find.byIcon(Icons.refresh), findsOneWidget);

      await tester.tap(find.byIcon(Icons.refresh));
      expect(retried, isTrue);
    });

    testWidgets('hides retry button when onRetry is null', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const ErrorState(message: 'Test error'),
      ));

      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('shows secondary action button', (tester) async {
      bool secondaryTapped = false;

      await tester.pumpWidget(createTestWidget(
        child: ErrorState(
          message: 'Test error',
          onRetry: () {},
          onSecondaryAction: () => secondaryTapped = true,
          secondaryLabel: 'Change server',
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Change server'), findsOneWidget);

      await tester.tap(find.text('Change server'));
      expect(secondaryTapped, isTrue);
    });

    testWidgets('hides secondary button when not provided', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: ErrorState(
          message: 'Test error',
          onRetry: () {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(TextButton), findsNothing);
    });

    testWidgets('uses custom icon', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const ErrorState(
          message: 'Test error',
          icon: Icons.wifi_off,
        ),
      ));

      expect(find.byIcon(Icons.wifi_off), findsOneWidget);
      expect(find.byIcon(Icons.cloud_off_outlined), findsNothing);
    });

    testWidgets('uses default message from l10n when message is null', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const ErrorState(),
      ));
      await tester.pumpAndSettle();

      // Should show the l10n msg_network_error string
      expect(find.text('Something went wrong. Please try again.'), findsOneWidget);
    });

    testWidgets('uses custom retry label', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: ErrorState(
          message: 'Test error',
          onRetry: () {},
          retryLabel: 'Try again',
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Try again'), findsOneWidget);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
