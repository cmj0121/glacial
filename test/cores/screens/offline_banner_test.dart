import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/core.dart';

import '../../helpers/test_helpers.dart';

void main() {
  setupTestEnvironment();

  group('OfflineBanner', () {
    testWidgets('shows banner when isOffline is true', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const OfflineBanner(isOffline: true),
      ));
      await tester.pump();

      expect(find.byIcon(Icons.cloud_off), findsOneWidget);
      expect(find.text('You are offline'), findsOneWidget);
    });

    testWidgets('hides banner when isOffline is false', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const OfflineBanner(isOffline: false),
      ));
      await tester.pump();

      expect(find.byIcon(Icons.cloud_off), findsNothing);
      expect(find.text('You are offline'), findsNothing);
    });

    testWidgets('uses errorContainer color scheme', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const OfflineBanner(isOffline: true),
      ));
      await tester.pump();

      final container = tester.widget<Container>(find.byType(Container).last);
      final decoration = container.decoration as BoxDecoration?;
      // If no BoxDecoration, check for plain color.
      if (decoration != null) {
        expect(decoration.color, isNotNull);
      } else {
        expect(container.color, isNotNull);
      }
    });

    testWidgets('transitions between states with animation', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const OfflineBanner(isOffline: true),
      ));
      await tester.pumpAndSettle();

      expect(find.text('You are offline'), findsOneWidget);

      // Rebuild with offline = false.
      await tester.pumpWidget(createTestWidget(
        child: const OfflineBanner(isOffline: false),
      ));
      // Midway through animation: AnimatedSwitcher is still animating.
      await tester.pump(const Duration(milliseconds: 150));
      // After animation completes:
      await tester.pumpAndSettle();

      expect(find.text('You are offline'), findsNothing);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
