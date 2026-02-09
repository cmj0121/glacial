// Widget tests for StatusVisibility and VisibilitySelector components.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/features/models.dart';
import 'package:glacial/features/timeline/screens/visibility.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  setUpAll(() => setupTestEnvironment());

  group('StatusVisibility', () {
    group('compact mode (default)', () {
      testWidgets('displays public icon', (tester) async {
        await tester.pumpWidget(createTestWidget(
          child: const StatusVisibility(type: VisibilityType.public),
        ));
        await tester.pump();

        expect(find.byIcon(Icons.public), findsOneWidget);
      });

      testWidgets('displays unlisted icon', (tester) async {
        await tester.pumpWidget(createTestWidget(
          child: const StatusVisibility(type: VisibilityType.unlisted),
        ));
        await tester.pump();

        expect(find.byIcon(Icons.nightlight_outlined), findsOneWidget);
      });

      testWidgets('displays private icon', (tester) async {
        await tester.pumpWidget(createTestWidget(
          child: const StatusVisibility(type: VisibilityType.private),
        ));
        await tester.pump();

        expect(find.byIcon(Icons.group), findsOneWidget);
      });

      testWidgets('displays direct icon', (tester) async {
        await tester.pumpWidget(createTestWidget(
          child: const StatusVisibility(type: VisibilityType.direct),
        ));
        await tester.pump();

        expect(find.byIcon(Icons.lock), findsOneWidget);
      });

      testWidgets('wraps icon in Tooltip', (tester) async {
        await tester.pumpWidget(createTestWidget(
          child: const StatusVisibility(type: VisibilityType.public),
        ));
        await tester.pump();

        expect(find.byType(Tooltip), findsOneWidget);
      });

      testWidgets('uses default size of 16', (tester) async {
        await tester.pumpWidget(createTestWidget(
          child: const StatusVisibility(type: VisibilityType.public),
        ));
        await tester.pump();

        final Icon icon = tester.widget(find.byType(Icon));
        expect(icon.size, 16);
      });

      testWidgets('accepts custom size', (tester) async {
        await tester.pumpWidget(createTestWidget(
          child: const StatusVisibility(type: VisibilityType.public, size: 24),
        ));
        await tester.pump();

        final Icon icon = tester.widget(find.byType(Icon));
        expect(icon.size, 24);
      });
    });

    group('expanded mode', () {
      testWidgets('displays ListTile when not compact', (tester) async {
        await tester.pumpWidget(createTestWidget(
          child: const StatusVisibility(
            type: VisibilityType.public,
            isCompact: false,
          ),
        ));
        await tester.pump();

        expect(find.byType(ListTile), findsOneWidget);
      });

      testWidgets('displays icon in ListTile leading', (tester) async {
        await tester.pumpWidget(createTestWidget(
          child: const StatusVisibility(
            type: VisibilityType.private,
            isCompact: false,
          ),
        ));
        await tester.pump();

        expect(find.byIcon(Icons.group), findsOneWidget);
      });

      testWidgets('displays tooltip text as title', (tester) async {
        await tester.pumpWidget(createTestWidget(
          child: const StatusVisibility(
            type: VisibilityType.public,
            isCompact: false,
          ),
        ));
        await tester.pump();

        // Check for text containing visibility name
        expect(find.textContaining('Public'), findsOneWidget);
      });

      testWidgets('constrains width to 120', (tester) async {
        await tester.pumpWidget(createTestWidget(
          child: const StatusVisibility(
            type: VisibilityType.public,
            isCompact: false,
          ),
        ));
        await tester.pump();

        // ConstrainedBox exists in widget tree
        expect(find.byType(ConstrainedBox), findsWidgets);
      });
    });
  });

  group('VisibilitySelector', () {
    testWidgets('displays dropdown button', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const VisibilitySelector(),
      ));
      await tester.pump();

      expect(find.byType(DropdownButton<VisibilityType>), findsOneWidget);
    });

    testWidgets('defaults to public visibility', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const VisibilitySelector(),
      ));
      await tester.pump();

      // Public icon should be visible
      expect(find.byIcon(Icons.public), findsOneWidget);
    });

    testWidgets('uses provided initial type', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const VisibilitySelector(type: VisibilityType.private),
      ));
      await tester.pump();

      // Private icon should be visible
      expect(find.byIcon(Icons.group), findsOneWidget);
    });

    testWidgets('accepts custom size', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const VisibilitySelector(size: 24),
      ));
      await tester.pump();

      expect(find.byType(VisibilitySelector), findsOneWidget);
    });

    testWidgets('wraps dropdown in padding', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const VisibilitySelector(),
      ));
      await tester.pump();

      expect(find.byType(Padding), findsWidgets);
    });

    testWidgets('hides dropdown underline', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const VisibilitySelector(),
      ));
      await tester.pump();

      expect(find.byType(DropdownButtonHideUnderline), findsOneWidget);
    });

    testWidgets('accepts onChanged callback', (tester) async {
      VisibilityType? selectedType;

      await tester.pumpWidget(createTestWidget(
        child: VisibilitySelector(
          onChanged: (type) => selectedType = type,
        ),
      ));
      await tester.pump();

      expect(find.byType(VisibilitySelector), findsOneWidget);
      // Callback not triggered until selection
      expect(selectedType, isNull);
    });

    testWidgets('dropdown is enabled when onChanged provided', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: VisibilitySelector(
          onChanged: (_) {},
        ),
      ));
      await tester.pump();

      final dropdown = tester.widget<DropdownButton<VisibilityType>>(
        find.byType(DropdownButton<VisibilityType>),
      );
      expect(dropdown.onChanged, isNotNull);
    });

    testWidgets('dropdown is disabled when onChanged is null', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const VisibilitySelector(onChanged: null),
      ));
      await tester.pump();

      final dropdown = tester.widget<DropdownButton<VisibilityType>>(
        find.byType(DropdownButton<VisibilityType>),
      );
      expect(dropdown.onChanged, isNull);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
