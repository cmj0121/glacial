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
  });
}

// vim: set ts=2 sw=2 sts=2 et:
