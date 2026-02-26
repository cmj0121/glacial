// Widget tests for ListAccountWidget.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glacial/cores/screens/misc.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  setupTestEnvironment();

  // Use domain-less access status so API calls short-circuit.
  AccessStatusSchema noDomainStatus() {
    return const AccessStatusSchema(
      domain: null,
      accessToken: 'test_token',
    );
  }

  group('ListAccountWidget', () {
    test('is a ConsumerStatefulWidget', () {
      const widget = ListAccountWidget(name: 'test');
      expect(widget, isA<ConsumerStatefulWidget>());
    });

    test('accepts name parameter', () {
      const widget = ListAccountWidget(name: 'searchQuery');
      expect(widget.name, 'searchQuery');
    });

    test('accepts onSelected callback', () {
      final widget = ListAccountWidget(
        name: 'test',
        onSelected: (_) {},
      );
      expect(widget.onSelected, isNotNull);
    });

    testWidgets('renders with no-domain status', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: ListAccountWidget(name: 'test')),
          accessStatus: noDomainStatus(),
        ));
        await tester.pump();
      });

      expect(find.byType(ListAccountWidget), findsOneWidget);
    });

    testWidgets('shows NoResult when search returns empty', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: ListAccountWidget(name: 'nonexistent')),
          accessStatus: noDomainStatus(),
        ));
        await tester.pump();
      });

      // With null domain, searchAccounts returns empty list → NoResult
      expect(find.byType(NoResult), findsOneWidget);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
