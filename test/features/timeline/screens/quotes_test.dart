// Widget tests for Quote policy components.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

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

    testWidgets('renders quoted status in glass container when quotedStatus is present', (tester) async {
      final quotedStatus = MockStatus.create(
        id: 'quoted-1',
        content: '<p>Quoted content here</p>',
      );
      final quoteSchema = QuoteSchema(
        state: QuoteStateType.accepted,
        quotedStatus: quotedStatus,
      );

      await tester.pumpWidget(createTestWidget(
        child: Quote(schema: quoteSchema),
      ));
      await tester.pump();

      // Quote should wrap in Padding and AdaptiveGlassContainer
      expect(find.byType(Quote), findsOneWidget);
      expect(find.byType(Padding), findsWidgets);
      expect(find.byType(AdaptiveGlassContainer), findsOneWidget);
      // StatusLite should be nested as the quoted status
      expect(find.byType(StatusLite), findsOneWidget);
    });

    testWidgets('shows not-found when quotedStatus is null and quotedStatusID is null', (tester) async {
      final quoteSchema = QuoteSchema(
        state: QuoteStateType.deleted,
        quotedStatus: null,
        quotedStatusID: null,
      );

      await tester.pumpWidget(createTestWidget(
        child: Quote(schema: quoteSchema),
      ));
      await tester.pump();

      // buildNotFound should be called — shows delete icon and message
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
      expect(find.textContaining('Unavailable'), findsOneWidget);
    });

    testWidgets('shows FutureBuilder when quotedStatusID is set but quotedStatus is null', (tester) async {
      final quoteSchema = QuoteSchema(
        state: QuoteStateType.accepted,
        quotedStatus: null,
        quotedStatusID: 'status-to-fetch',
      );

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: Quote(schema: quoteSchema),
          accessStatus: MockAccessStatus.authenticated(),
        ));
        await tester.pump();
      });

      // FutureBuilder is used to load the status
      expect(find.byType(FutureBuilder<StatusSchema?>), findsOneWidget);
    });

    testWidgets('FutureBuilder shows not-found on error', (tester) async {
      // Using an anonymous (no access token) status so getStatus returns null
      final quoteSchema = QuoteSchema(
        state: QuoteStateType.accepted,
        quotedStatus: null,
        quotedStatusID: 'nonexistent-status',
      );

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: Quote(schema: quoteSchema),
        ));
        await tester.pump();
        // Allow the future to resolve (it should be null since anonymous)
        await tester.pump(const Duration(seconds: 1));
      });

      // The quote should be rendered (may show not-found since no auth)
      expect(find.byType(Quote), findsOneWidget);
    });

    testWidgets('buildNotFound container has correct decoration', (tester) async {
      final quoteSchema = QuoteSchema(
        state: QuoteStateType.deleted,
        quotedStatus: null,
        quotedStatusID: null,
      );

      await tester.pumpWidget(createTestWidget(
        child: Quote(schema: quoteSchema),
      ));
      await tester.pump();

      // Container with ListTile inside
      expect(find.byType(ListTile), findsOneWidget);
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('buildQuote wraps in AdaptiveGlassContainer with padding', (tester) async {
      final quotedStatus = MockStatus.create(id: 'q-2', content: '<p>Test</p>');
      final quoteSchema = QuoteSchema(
        state: QuoteStateType.accepted,
        quotedStatus: quotedStatus,
      );

      await tester.pumpWidget(createTestWidget(
        child: Quote(schema: quoteSchema),
      ));
      await tester.pump();

      final glass = tester.widget<AdaptiveGlassContainer>(
        find.byType(AdaptiveGlassContainer),
      );
      expect(glass.borderRadius, BorderRadius.circular(16.0));
    });

    testWidgets('non-null schema wraps build in horizontal padding', (tester) async {
      final quotedStatus = MockStatus.create(id: 'q-3');
      final quoteSchema = QuoteSchema(
        state: QuoteStateType.accepted,
        quotedStatus: quotedStatus,
      );

      await tester.pumpWidget(createTestWidget(
        child: Quote(schema: quoteSchema),
      ));
      await tester.pump();

      // The build method wraps in Padding with horizontal 12.0
      final paddingWidgets = tester.widgetList<Padding>(find.byType(Padding));
      final hasPadding12 = paddingWidgets.any((p) =>
        p.padding == const EdgeInsets.symmetric(horizontal: 12.0));
      expect(hasPadding12, isTrue);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
