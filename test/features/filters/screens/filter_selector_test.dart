// Widget tests for FilterSelector and Filters.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glacial/cores/screens/misc.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

import '../../../helpers/test_helpers.dart';

// Use domain-null status so API calls short-circuit without HTTP.
AccessStatusSchema _noDomainAuth() {
  return const AccessStatusSchema(domain: null, accessToken: 'test');
}

void main() {
  setupTestEnvironment();

  group('FilterSelector', () {
    test('is a ConsumerStatefulWidget', () {
      final widget = FilterSelector(status: MockStatus.create());
      expect(widget, isA<ConsumerStatefulWidget>());
    });

    test('accepts required status parameter', () {
      final status = MockStatus.create(id: 'fs-test');
      final widget = FilterSelector(status: status);
      expect(widget.status.id, 'fs-test');
    });

    test('accepts optional callbacks', () {
      final widget = FilterSelector(
        status: MockStatus.create(),
        onSelected: (_) {},
        onDeleted: (_) {},
      );
      expect(widget.onSelected, isNotNull);
      expect(widget.onDeleted, isNotNull);
    });

    testWidgets('renders with no-domain status', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: FilterSelector(status: MockStatus.create()),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();
      });

      expect(find.byType(FilterSelector), findsOneWidget);
    });

    testWidgets('shows Divider', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: FilterSelector(status: MockStatus.create()),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();
      });

      expect(find.byType(Divider), findsOneWidget);
    });
  });

  group('Filters', () {
    test('is a ConsumerStatefulWidget', () {
      const widget = Filters();
      expect(widget, isA<ConsumerStatefulWidget>());
    });

    testWidgets('renders with no-domain status', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: Filters()),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();
      });

      expect(find.byType(Filters), findsOneWidget);
    });

    testWidgets('shows add button', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: Filters()),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();
      });

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('shows text field for new filter', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: Filters()),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();
      });

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('shows NoResult when empty', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: Filters()),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();
      });

      // When filters list is empty, shows NoResult
      expect(find.byType(NoResult), findsOneWidget);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
