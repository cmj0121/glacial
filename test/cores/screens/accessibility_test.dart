// Widget tests for accessibility helpers.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/cores/screens/accessibility.dart';

import '../../helpers/test_helpers.dart';

void main() {
  setupTestEnvironment();

  group('SemanticIcon', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const SemanticIcon(
          label: 'Test label',
          child: Icon(Icons.star),
        ),
      ));
      await tester.pump();

      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('wraps child in Semantics widget', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const SemanticIcon(
          label: 'Star icon',
          child: Icon(Icons.star),
        ),
      ));
      await tester.pump();

      expect(find.byType(Semantics), findsWidgets);
      final Semantics semantics = tester.widget<Semantics>(
        find.ancestor(
          of: find.byIcon(Icons.star),
          matching: find.byType(Semantics),
        ).first,
      );
      expect(semantics.properties.label, 'Star icon');
    });

    testWidgets('applies semantic label', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const SemanticIcon(
          label: 'Favorite button',
          child: Icon(Icons.favorite),
        ),
      ));
      await tester.pump();

      final Semantics semantics = tester.widget<Semantics>(
        find.ancestor(
          of: find.byIcon(Icons.favorite),
          matching: find.byType(Semantics),
        ).first,
      );
      expect(semantics.properties.label, 'Favorite button');
    });

    testWidgets('respects excludeSemantics flag when true', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const SemanticIcon(
          label: 'Hidden label',
          excludeSemantics: true,
          child: Icon(Icons.visibility_off),
        ),
      ));
      await tester.pump();

      final Semantics semantics = tester.widget<Semantics>(
        find.ancestor(
          of: find.byIcon(Icons.visibility_off),
          matching: find.byType(Semantics),
        ).first,
      );
      expect(semantics.excludeSemantics, true);
    });

    testWidgets('excludeSemantics defaults to false', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const SemanticIcon(
          label: 'Visible label',
          child: Icon(Icons.visibility),
        ),
      ));
      await tester.pump();

      final Semantics semantics = tester.widget<Semantics>(
        find.ancestor(
          of: find.byIcon(Icons.visibility),
          matching: find.byType(Semantics),
        ).first,
      );
      expect(semantics.excludeSemantics, false);
    });
  });

  group('AccessibleTooltip', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const AccessibleTooltip(
          message: 'Tooltip message',
          child: Icon(Icons.info),
        ),
      ));
      await tester.pump();

      expect(find.byIcon(Icons.info), findsOneWidget);
    });

    testWidgets('wraps child in Tooltip widget', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const AccessibleTooltip(
          message: 'Help text',
          child: Icon(Icons.help),
        ),
      ));
      await tester.pump();

      expect(find.byType(Tooltip), findsOneWidget);
      final Tooltip tooltip = tester.widget<Tooltip>(find.byType(Tooltip));
      expect(tooltip.message, 'Help text');
    });

    testWidgets('uses message as default semanticLabel', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const AccessibleTooltip(
          message: 'Default semantic',
          child: Icon(Icons.info_outline),
        ),
      ));
      await tester.pump();

      final Semantics semantics = tester.widget<Semantics>(
        find.ancestor(
          of: find.byType(Tooltip),
          matching: find.byType(Semantics),
        ).first,
      );
      expect(semantics.properties.label, 'Default semantic');
    });

    testWidgets('uses semanticLabel when provided', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const AccessibleTooltip(
          message: 'Tooltip message',
          semanticLabel: 'Custom semantic label',
          child: Icon(Icons.info),
        ),
      ));
      await tester.pump();

      final Semantics semantics = tester.widget<Semantics>(
        find.ancestor(
          of: find.byType(Tooltip),
          matching: find.byType(Semantics),
        ).first,
      );
      expect(semantics.properties.label, 'Custom semantic label');
    });
  });

  group('AccessibleDismissible', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: AccessibleDismissible(
          dismissKey: const Key('test-dismiss'),
          child: const Text('Dismissible content'),
        ),
      ));
      await tester.pump();

      expect(find.text('Dismissible content'), findsOneWidget);
    });

    testWidgets('wraps child in Dismissible widget', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: AccessibleDismissible(
          dismissKey: const Key('test-dismiss'),
          child: const Text('Content'),
        ),
      ));
      await tester.pump();

      expect(find.byType(Dismissible), findsOneWidget);
    });

    testWidgets('applies dismiss direction', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: AccessibleDismissible(
          dismissKey: const Key('test-dismiss'),
          direction: DismissDirection.endToStart,
          child: const Text('Swipe to dismiss'),
        ),
      ));
      await tester.pump();

      final Dismissible dismissible = tester.widget<Dismissible>(find.byType(Dismissible));
      expect(dismissible.direction, DismissDirection.endToStart);
    });

    testWidgets('defaults to horizontal direction', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: AccessibleDismissible(
          dismissKey: const Key('test-dismiss'),
          child: const Text('Content'),
        ),
      ));
      await tester.pump();

      final Dismissible dismissible = tester.widget<Dismissible>(find.byType(Dismissible));
      expect(dismissible.direction, DismissDirection.horizontal);
    });

    testWidgets('includes dismiss hint in Semantics', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: AccessibleDismissible(
          dismissKey: const Key('test-dismiss'),
          dismissLabel: 'Swipe to remove',
          child: const Text('Content'),
        ),
      ));
      await tester.pump();

      final Semantics semantics = tester.widget<Semantics>(
        find.ancestor(
          of: find.byType(Dismissible),
          matching: find.byType(Semantics),
        ).first,
      );
      expect(semantics.properties.hint, 'Swipe to remove');
    });
  });

  group('IconAccessibility extension', () {
    testWidgets('withSemantics adds Semantics wrapper', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const Icon(Icons.settings).withSemantics('Settings'),
      ));
      await tester.pump();

      expect(find.byIcon(Icons.settings), findsOneWidget);
      expect(find.byType(Semantics), findsWidgets);
    });

    testWidgets('withSemantics applies correct label', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const Icon(Icons.home).withSemantics('Home button'),
      ));
      await tester.pump();

      final Semantics semantics = tester.widget<Semantics>(
        find.ancestor(
          of: find.byIcon(Icons.home),
          matching: find.byType(Semantics),
        ).first,
      );
      expect(semantics.properties.label, 'Home button');
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
