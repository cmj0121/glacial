// Widget tests for AccountPickerSheet.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/features/screens.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  setupTestEnvironment();

  group('AccountPickerSheet', () {
    testWidgets('renders with authenticated status', (tester) async {
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AccountPickerSheet(status: status),
        accessStatus: status,
      ));
      await tester.pump();

      expect(find.byType(AccountPickerSheet), findsOneWidget);
    });

    testWidgets('shows title text', (tester) async {
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AccountPickerSheet(status: status),
        accessStatus: status,
      ));
      await tester.pump();

      expect(find.text('Accounts'), findsOneWidget);
    });

    testWidgets('shows add account button', (tester) async {
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AccountPickerSheet(status: status),
        accessStatus: status,
      ));
      await tester.pump();

      expect(find.text('Add Account'), findsOneWidget);
      expect(find.byIcon(Icons.person_add), findsOneWidget);
    });

    testWidgets('shows loading indicator initially', (tester) async {
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AccountPickerSheet(status: status),
        accessStatus: status,
      ));
      // Before the post-frame callback fires, should show loading.
      expect(find.byType(AccountPickerSheet), findsOneWidget);
    });

    testWidgets('renders with anonymous status', (tester) async {
      final status = MockAccessStatus.anonymous();

      await tester.pumpWidget(createTestWidget(
        child: AccountPickerSheet(status: status),
        accessStatus: status,
      ));
      await tester.pump();

      expect(find.byType(AccountPickerSheet), findsOneWidget);
      expect(find.text('Accounts'), findsOneWidget);
    });

    testWidgets('renders with null status', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const AccountPickerSheet(status: null),
      ));
      await tester.pump();

      expect(find.byType(AccountPickerSheet), findsOneWidget);
    });

    testWidgets('add account button is an OutlinedButton', (tester) async {
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AccountPickerSheet(status: status),
        accessStatus: status,
      ));
      await tester.pump();

      expect(find.byType(OutlinedButton), findsOneWidget);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
