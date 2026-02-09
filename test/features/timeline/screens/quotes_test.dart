// Widget tests for Quote policy components.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/features/models.dart';
import 'package:glacial/features/timeline/screens/quotes.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  setUpAll(() => setupTestEnvironment());

  group('QuotePolicy', () {
    testWidgets('displays public icon', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const QuotePolicy(policy: QuotePolicyType.public),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.format_quote_sharp), findsOneWidget);
    });

    testWidgets('displays followers icon', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const QuotePolicy(policy: QuotePolicyType.followers),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.group), findsOneWidget);
    });

    testWidgets('displays nobody icon', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const QuotePolicy(policy: QuotePolicyType.nobody),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.lock), findsOneWidget);
    });

    testWidgets('displays policy title', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const QuotePolicy(policy: QuotePolicyType.public),
      ));
      await tester.pumpAndSettle();

      expect(find.textContaining('Public'), findsOneWidget);
    });

    testWidgets('wraps in Tooltip', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const QuotePolicy(policy: QuotePolicyType.public),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(Tooltip), findsOneWidget);
    });

    testWidgets('uses ConstrainedBox for sizing', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const QuotePolicy(policy: QuotePolicyType.public),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(ConstrainedBox), findsWidgets);
    });

    testWidgets('uses ListTile layout', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const QuotePolicy(policy: QuotePolicyType.public),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(ListTile), findsOneWidget);
    });
  });

  group('QuotePolicyTypeSelector', () {
    testWidgets('displays dropdown button', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const QuotePolicyTypeSelector(),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(DropdownButton<QuotePolicyType>), findsOneWidget);
    });

    testWidgets('defaults to public policy', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const QuotePolicyTypeSelector(),
      ));
      await tester.pumpAndSettle();

      // Public icon should be visible
      expect(find.byIcon(Icons.format_quote_sharp), findsOneWidget);
    });

    testWidgets('uses provided initial policy', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const QuotePolicyTypeSelector(policy: QuotePolicyType.nobody),
      ));
      await tester.pumpAndSettle();

      // Nobody icon should be visible
      expect(find.byIcon(Icons.lock), findsOneWidget);
    });

    testWidgets('hides dropdown underline', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const QuotePolicyTypeSelector(),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(DropdownButtonHideUnderline), findsOneWidget);
    });

    testWidgets('accepts onChanged callback', (tester) async {
      QuotePolicyType? selectedPolicy;

      await tester.pumpWidget(createTestWidget(
        child: QuotePolicyTypeSelector(
          onChanged: (policy) => selectedPolicy = policy,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(QuotePolicyTypeSelector), findsOneWidget);
      // Callback not triggered until selection
      expect(selectedPolicy, isNull);
    });

    testWidgets('dropdown is enabled when onChanged provided', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: QuotePolicyTypeSelector(
          onChanged: (_) {},
        ),
      ));
      await tester.pumpAndSettle();

      final dropdown = tester.widget<DropdownButton<QuotePolicyType>>(
        find.byType(DropdownButton<QuotePolicyType>),
      );
      expect(dropdown.onChanged, isNotNull);
    });

    testWidgets('dropdown is disabled when onChanged is null', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const QuotePolicyTypeSelector(onChanged: null),
      ));
      await tester.pumpAndSettle();

      final dropdown = tester.widget<DropdownButton<QuotePolicyType>>(
        find.byType(DropdownButton<QuotePolicyType>),
      );
      expect(dropdown.onChanged, isNull);
    });

    testWidgets('wraps dropdown in padding', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const QuotePolicyTypeSelector(),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(Padding), findsWidgets);
    });
  });

  group('Quote', () {
    testWidgets('returns empty when schema is null', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const Quote(schema: null),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(Quote), findsOneWidget);
      expect(find.byType(SizedBox), findsWidgets);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
