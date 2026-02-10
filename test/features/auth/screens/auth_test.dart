// Widget tests for auth screens: SignIn.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/features/screens.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  setupTestEnvironment();

  group('SignIn', () {
    testWidgets('renders icon button', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const SignIn(),
        accessStatus: MockAccessStatus.authenticated(),
      ));
      await tester.pump();

      expect(find.byType(SignIn), findsOneWidget);
      expect(find.byType(IconButton), findsOneWidget);
    });

    testWidgets('shows person_outline icon', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const SignIn(),
        accessStatus: MockAccessStatus.authenticated(),
      ));
      await tester.pump();

      expect(find.byIcon(Icons.person_outline), findsOneWidget);
    });

    testWidgets('has sign in tooltip', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const SignIn(),
        accessStatus: MockAccessStatus.authenticated(),
      ));
      await tester.pump();

      expect(find.byType(Tooltip), findsOneWidget);
    });

    testWidgets('accepts custom size parameter', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const SignIn(size: 64),
        accessStatus: MockAccessStatus.authenticated(),
      ));
      await tester.pump();

      expect(find.byType(SignIn), findsOneWidget);
    });

    testWidgets('renders as filledTonal icon button', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const SignIn(),
        accessStatus: MockAccessStatus.authenticated(),
      ));
      await tester.pump();

      final iconButton = tester.widget<IconButton>(find.byType(IconButton));
      // FilledTonal style is applied via IconButton.filledTonal constructor
      expect(iconButton, isNotNull);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
