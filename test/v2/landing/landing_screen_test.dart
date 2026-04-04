// Widget tests for V2LandingScreen.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/v2/landing/landing_screen.dart';

import '../../helpers/test_helpers.dart';

void main() {
  setupTestEnvironment();

  group('V2LandingScreen', () {
    Future<void> pumpLanding(WidgetTester tester) async {
      await tester.pumpWidget(createTestWidgetRaw(
        child: const V2LandingScreen(),
      ));
      // Pump past all staggered fade-in delays (800ms max + 400ms duration)
      await tester.pump(const Duration(milliseconds: 1300));
    }

    testWidgets('renders app icon', (tester) async {
      await pumpLanding(tester);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('shows GLACIAL text', (tester) async {
      await pumpLanding(tester);
      expect(find.text('GLACIAL'), findsOneWidget);
    });

    testWidgets('shows tagline', (tester) async {
      await pumpLanding(tester);
      expect(find.text('A calm space for social conversations'), findsOneWidget);
    });

    testWidgets('shows Get Started button with arrow', (tester) async {
      await pumpLanding(tester);
      expect(find.text('Get Started'), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
    });

    testWidgets('has only one button (no outlined button)', (tester) async {
      await pumpLanding(tester);
      expect(find.byType(OutlinedButton), findsNothing);
    });

    testWidgets('shows Powered by cmj', (tester) async {
      await pumpLanding(tester);
      expect(find.text('Powered by cmj'), findsOneWidget);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
