// Widget tests for filter screens: FiltersForm, FilterKeywordForm.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  setupTestEnvironment();

  group('FiltersForm', () {
    testWidgets('renders form with padded column', (tester) async {
      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          body: FiltersForm(title: 'Test Filter'),
        ),
        accessStatus: MockAccessStatus.authenticated(),
      ));
      await tester.pump();

      expect(find.byType(FiltersForm), findsOneWidget);
      expect(find.byType(Padding), findsWidgets);
      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('shows save button with save icon', (tester) async {
      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          body: FiltersForm(title: 'Test Filter'),
        ),
        accessStatus: MockAccessStatus.authenticated(),
      ));
      await tester.pump();

      expect(find.byIcon(Icons.save_outlined), findsOneWidget);
      // Save button text from localization
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('shows title text field with initial value', (tester) async {
      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          body: FiltersForm(title: 'My New Filter'),
        ),
        accessStatus: MockAccessStatus.authenticated(),
      ));
      await tester.pump();

      // The title field should contain the initial title
      expect(find.byIcon(Icons.text_fields_outlined), findsOneWidget);
      final Finder textFields = find.byType(TextField);
      expect(textFields, findsWidgets);

      // Find the title text field by checking its controller text
      bool foundTitleField = false;
      tester.widgetList<TextField>(textFields).forEach((tf) {
        if (tf.controller?.text == 'My New Filter') {
          foundTitleField = true;
        }
      });
      expect(foundTitleField, isTrue);
    });

    testWidgets('creates new filter when schema is null', (tester) async {
      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          body: FiltersForm(title: 'Brand New'),
        ),
        accessStatus: MockAccessStatus.authenticated(),
      ));
      await tester.pump();

      // With no schema, form should use FilterFormSchema.fromTitle defaults
      // Action defaults to hide (Icons.block_outlined)
      expect(find.byIcon(Icons.block_outlined), findsOneWidget);
    });

    testWidgets('edits existing filter with schema values', (tester) async {
      final schema = FiltersSchema(
        id: 'f1',
        title: 'Existing Filter',
        context: [FilterContext.home],
        action: FilterAction.warn,
        keywords: [
          const FilterKeywordSchema(id: 'kw-1', keyword: 'spam', wholeWord: true),
        ],
        statuses: [],
      );

      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          body: FiltersForm(title: schema.title, schema: schema),
        ),
        accessStatus: MockAccessStatus.authenticated(),
      ));
      await tester.pump();

      // Action should be warn (Icons.warning_amber_outlined)
      expect(find.byIcon(Icons.warning_amber_outlined), findsWidgets);
    });

    testWidgets('shows filter context chips', (tester) async {
      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          body: FiltersForm(title: 'Context Test'),
        ),
        accessStatus: MockAccessStatus.authenticated(),
      ));
      await tester.pump();

      // All FilterContext values should appear as FilterChips
      expect(find.byType(FilterChip), findsNWidgets(FilterContext.values.length));
      expect(find.byIcon(Icons.ballot_rounded), findsOneWidget);
    });

    testWidgets('shows expiration field with schedule icon', (tester) async {
      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          body: FiltersForm(title: 'Expiration Test'),
        ),
        accessStatus: MockAccessStatus.authenticated(),
      ));
      await tester.pump();

      expect(find.byIcon(Icons.schedule_outlined), findsOneWidget);
    });

    testWidgets('action cycles on tap', (tester) async {
      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          body: FiltersForm(title: 'Action Cycle'),
        ),
        accessStatus: MockAccessStatus.authenticated(),
      ));
      await tester.pump();

      // Default action is hide (block_outlined)
      expect(find.byIcon(Icons.block_outlined), findsOneWidget);

      // Tap the action ListTile to cycle
      await tester.tap(find.byIcon(Icons.block_outlined));
      await tester.pump();

      // Should cycle to next action (blur → blur_on_outlined)
      expect(find.byIcon(Icons.blur_on_outlined), findsOneWidget);
    });

    testWidgets('submit button disabled when no context selected', (tester) async {
      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          body: FiltersForm(title: 'No Context'),
        ),
        accessStatus: MockAccessStatus.authenticated(),
      ));
      await tester.pump();

      // By default, no context is selected → save button should be present but disabled
      expect(find.text('Save'), findsOneWidget);
      expect(find.byIcon(Icons.save_outlined), findsOneWidget);

      // Find the ancestor FilledButton via the save icon
      final Finder buttonFinder = find.ancestor(
        of: find.byIcon(Icons.save_outlined),
        matching: find.bySubtype<ButtonStyleButton>(),
      );
      expect(buttonFinder, findsOneWidget);

      final ButtonStyleButton button = tester.widget<ButtonStyleButton>(buttonFinder);
      expect(button.onPressed, isNull);
    });

    testWidgets('submit button enabled when context is selected', (tester) async {
      final schema = FiltersSchema(
        id: 'f1',
        title: 'Has Context',
        context: [FilterContext.home],
        action: FilterAction.warn,
        keywords: [],
        statuses: [],
      );

      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          body: FiltersForm(title: schema.title, schema: schema),
        ),
        accessStatus: MockAccessStatus.authenticated(),
      ));
      await tester.pump();

      // Find the ancestor FilledButton via the save icon
      final Finder buttonFinder = find.ancestor(
        of: find.byIcon(Icons.save_outlined),
        matching: find.bySubtype<ButtonStyleButton>(),
      );
      expect(buttonFinder, findsOneWidget);

      final ButtonStyleButton button = tester.widget<ButtonStyleButton>(buttonFinder);
      expect(button.onPressed, isNotNull);
    });
  });

  group('FilterKeywordForm', () {
    testWidgets('renders with schema showing keyword text field', (tester) async {
      const schema = FilterKeywordFormSchema(
        id: 'kw-1',
        keyword: 'test keyword',
        wholeWord: false,
      );

      await tester.pumpWidget(createTestWidget(
        child: FilterKeywordForm(schema: schema),
        accessStatus: MockAccessStatus.authenticated(),
      ));
      await tester.pump();

      expect(find.byType(FilterKeywordForm), findsOneWidget);
      expect(find.byType(ListTile), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      // Check the text field has the keyword value
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, 'test keyword');
    });

    testWidgets('shows code icon for whole word match', (tester) async {
      const schema = FilterKeywordFormSchema(
        keyword: 'whole',
        wholeWord: true,
      );

      await tester.pumpWidget(createTestWidget(
        child: FilterKeywordForm(schema: schema),
        accessStatus: MockAccessStatus.authenticated(),
      ));
      await tester.pump();

      expect(find.byIcon(Icons.code_outlined), findsOneWidget);
    });

    testWidgets('shows code_off icon for partial word match', (tester) async {
      const schema = FilterKeywordFormSchema(
        keyword: 'partial',
        wholeWord: false,
      );

      await tester.pumpWidget(createTestWidget(
        child: FilterKeywordForm(schema: schema),
        accessStatus: MockAccessStatus.authenticated(),
      ));
      await tester.pump();

      expect(find.byIcon(Icons.code_off_outlined), findsOneWidget);
    });

    testWidgets('shows add icon when onDelete is null', (tester) async {
      const schema = FilterKeywordFormSchema(
        keyword: '',
        wholeWord: false,
      );

      await tester.pumpWidget(createTestWidget(
        child: FilterKeywordForm(schema: schema),
        accessStatus: MockAccessStatus.authenticated(),
      ));
      await tester.pump();

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('shows delete icon when onDelete is provided', (tester) async {
      const schema = FilterKeywordFormSchema(
        keyword: 'deletable',
        wholeWord: false,
      );

      await tester.pumpWidget(createTestWidget(
        child: FilterKeywordForm(
          schema: schema,
          onDelete: () {},
        ),
        accessStatus: MockAccessStatus.authenticated(),
      ));
      await tester.pump();

      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('toggles wholeWord on tap', (tester) async {
      const schema = FilterKeywordFormSchema(
        keyword: 'toggle',
        wholeWord: false,
      );

      await tester.pumpWidget(createTestWidget(
        child: FilterKeywordForm(
          schema: schema,
          onDelete: () {},
          onChanged: (_) {},
        ),
        accessStatus: MockAccessStatus.authenticated(),
      ));
      await tester.pump();

      // Initially partial match
      expect(find.byIcon(Icons.code_off_outlined), findsOneWidget);

      // Tap the leading icon area to toggle wholeWord (tapping ListTile center hits TextField)
      await tester.tap(find.byIcon(Icons.code_off_outlined));
      await tester.pump();

      // Should now show whole word icon
      expect(find.byIcon(Icons.code_outlined), findsOneWidget);
    });

    testWidgets('calls onDelete when delete button pressed', (tester) async {
      bool deleted = false;
      const schema = FilterKeywordFormSchema(
        keyword: 'test',
        wholeWord: false,
      );

      await tester.pumpWidget(createTestWidget(
        child: FilterKeywordForm(
          schema: schema,
          onDelete: () => deleted = true,
        ),
        accessStatus: MockAccessStatus.authenticated(),
      ));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pump();

      expect(deleted, isTrue);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
