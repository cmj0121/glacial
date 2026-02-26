// Widget tests for Filters page, FilterSelector, FiltersForm interactions,
// and FilterKeywordForm callbacks.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

import '../../../helpers/test_helpers.dart';

// Use domain-null status so API calls short-circuit without HTTP.
AccessStatusSchema _noDomainAuth() {
  return const AccessStatusSchema(domain: null, accessToken: 'test');
}

void main() {
  setupTestEnvironment();

  group('Filters page', () {
    test('is a ConsumerStatefulWidget', () {
      const widget = Filters();
      expect(widget, isA<ConsumerStatefulWidget>());
    });

    testWidgets('renders Column with add field and content', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: Filters()),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();
      });

      expect(find.byType(Filters), findsOneWidget);
      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('shows TextField for adding filter title', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: Filters()),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();
      });

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('shows add IconButton', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: Filters()),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();
      });

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('shows NoResult when filters list is empty after load',
        (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: Filters()),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 100));
        await tester.pump();
      });

      expect(find.byType(NoResult), findsOneWidget);
    });

    testWidgets('add field is wrapped in ListTile', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: Filters()),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();
      });

      // The add field has a ListTile with trailing IconButton
      expect(find.byType(ListTile), findsWidgets);
    });

    testWidgets('text field has OutlineInputBorder decoration',
        (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: Filters()),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();
      });

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.decoration?.border, isA<OutlineInputBorder>());
    });

    testWidgets('text field can receive text input', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: Filters()),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();
      });

      await tester.enterText(find.byType(TextField), 'New Filter');
      await tester.pump();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, 'New Filter');
    });

    testWidgets('shows NoResult with anonymous access status', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: Filters()),
          accessStatus: MockAccessStatus.anonymous(),
        ));
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 100));
        await tester.pump();
      });

      expect(find.byType(NoResult), findsOneWidget);
    });

    testWidgets('renders ListView with filter tiles when filters are injected',
        (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: Filters()),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();
      });

      // Inject mock filters via state access
      final state = tester.state(find.byType(Filters));
      (state as dynamic).filters = [
        FiltersSchema(
          id: '1',
          title: 'Spam Filter',
          action: FilterAction.warn,
          context: [FilterContext.home],
          keywords: [],
          statuses: [],
        ),
        FiltersSchema(
          id: '2',
          title: 'NSFW Filter',
          action: FilterAction.hide,
          context: [FilterContext.public],
          keywords: [],
          statuses: [],
        ),
      ];
      (tester.element(find.byType(Filters)) as StatefulElement)
          .markNeedsBuild();
      await tester.pump();

      // ListView should now be rendered instead of NoResult
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(NoResult), findsNothing);
      // Both filter titles should appear
      expect(find.text('Spam Filter'), findsOneWidget);
      expect(find.text('NSFW Filter'), findsOneWidget);
      // Each tile is wrapped in AccessibleDismissible
      expect(find.byType(AccessibleDismissible), findsNWidgets(2));
    });

    testWidgets('filter tile shows correct action icon per filter',
        (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: Filters()),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();
      });

      // Inject a single warn-action filter
      final state = tester.state(find.byType(Filters));
      (state as dynamic).filters = [
        FiltersSchema(
          id: '1',
          title: 'Warn Me',
          action: FilterAction.warn,
          context: [FilterContext.home],
          keywords: [],
          statuses: [],
        ),
      ];
      (tester.element(find.byType(Filters)) as StatefulElement)
          .markNeedsBuild();
      await tester.pump();

      // The warn action icon should appear as the leading icon in the tile
      expect(find.byIcon(Icons.warning_amber_outlined), findsOneWidget);
      expect(find.text('Warn Me'), findsOneWidget);
    });
  });

  group('FilterSelector', () {
    test('is a ConsumerStatefulWidget', () {
      final widget = FilterSelector(status: MockStatus.create());
      expect(widget, isA<ConsumerStatefulWidget>());
    });

    test('stores required status parameter', () {
      final status = MockStatus.create(id: 'sel-1');
      final widget = FilterSelector(status: status);
      expect(widget.status.id, 'sel-1');
    });

    test('stores optional onSelected callback', () {
      final widget = FilterSelector(
        status: MockStatus.create(),
        onSelected: (_) {},
      );
      expect(widget.onSelected, isNotNull);
    });

    test('stores optional onDeleted callback', () {
      final widget = FilterSelector(
        status: MockStatus.create(),
        onDeleted: (_) {},
      );
      expect(widget.onDeleted, isNotNull);
    });

    testWidgets('renders Padding wrapper', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: FilterSelector(status: MockStatus.create()),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();
      });

      expect(find.byType(Padding), findsWidgets);
    });

    testWidgets('shows title text for filter selection', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: FilterSelector(status: MockStatus.create()),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();
      });

      // The title text should be present ("Select a filter to apply" or l10n variant)
      expect(find.byType(Text), findsWidgets);
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

    testWidgets('shows Column layout', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: FilterSelector(status: MockStatus.create()),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();
      });

      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('no ListTiles when no filters loaded (domain null)',
        (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: FilterSelector(status: MockStatus.create()),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 100));
        await tester.pump();
      });

      // With domain: null, fetchFilters returns [], so no filter items rendered
      // The only widgets should be Text (title) and Divider
      expect(find.byType(ListTile), findsNothing);
    });
  });

  group('FiltersForm context chip selection', () {
    testWidgets('tapping a context chip selects it', (tester) async {
      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          body: FiltersForm(title: 'Chip Test'),
        ),
        accessStatus: MockAccessStatus.authenticated(),
      ));
      await tester.pump();

      // All FilterContext values should be filter chips
      expect(
          find.byType(FilterChip), findsNWidgets(FilterContext.values.length));

      // Tap the first filter chip to select it
      await tester.tap(find.byType(FilterChip).first);
      await tester.pump();

      // After selection, the save button should become enabled
      final Finder buttonFinder = find.ancestor(
        of: find.byIcon(Icons.save_outlined),
        matching: find.bySubtype<ButtonStyleButton>(),
      );
      final ButtonStyleButton button =
          tester.widget<ButtonStyleButton>(buttonFinder);
      expect(button.onPressed, isNotNull);
    });

    testWidgets('tapping a selected chip deselects it', (tester) async {
      // Start with a schema that already has a context selected
      final schema = FiltersSchema(
        id: 'f1',
        title: 'Has Home',
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

      // Save button should be enabled (context is selected)
      final Finder buttonFinder = find.ancestor(
        of: find.byIcon(Icons.save_outlined),
        matching: find.bySubtype<ButtonStyleButton>(),
      );
      ButtonStyleButton button =
          tester.widget<ButtonStyleButton>(buttonFinder);
      expect(button.onPressed, isNotNull);

      // Tap the "Home" chip to deselect it
      await tester.tap(find.byType(FilterChip).first);
      await tester.pump();

      // Now save button should be disabled (no context selected)
      button = tester.widget<ButtonStyleButton>(buttonFinder);
      expect(button.onPressed, isNull);
    });

    testWidgets('selecting multiple context chips keeps submit enabled',
        (tester) async {
      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          body: FiltersForm(title: 'Multi Chip'),
        ),
        accessStatus: MockAccessStatus.authenticated(),
      ));
      await tester.pump();

      // Tap first and second chip
      await tester.tap(find.byType(FilterChip).at(0));
      await tester.pump();
      await tester.tap(find.byType(FilterChip).at(1));
      await tester.pump();

      // Save button should still be enabled
      final Finder buttonFinder = find.ancestor(
        of: find.byIcon(Icons.save_outlined),
        matching: find.bySubtype<ButtonStyleButton>(),
      );
      final ButtonStyleButton button =
          tester.widget<ButtonStyleButton>(buttonFinder);
      expect(button.onPressed, isNotNull);
    });
  });

  group('FiltersForm expiration cycling', () {
    testWidgets('tapping expiration cycles through durations', (tester) async {
      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          body: FiltersForm(title: 'Expiration Test'),
        ),
        accessStatus: MockAccessStatus.authenticated(),
      ));
      await tester.pump();

      // Default expiration is "Never" (null duration, index 0)
      expect(find.byIcon(Icons.schedule_outlined), findsOneWidget);

      // Tap to cycle to next duration (30 minutes)
      await tester.tap(find.byIcon(Icons.schedule_outlined));
      await tester.pump();

      // Should still show schedule icon (the expiration ListTile persists)
      expect(find.byIcon(Icons.schedule_outlined), findsOneWidget);
    });

    testWidgets('expiration shows Never text by default', (tester) async {
      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          body: FiltersForm(title: 'Expiration Default'),
        ),
        accessStatus: MockAccessStatus.authenticated(),
      ));
      await tester.pump();

      // Default expiration is "Never"
      expect(find.text('Never'), findsOneWidget);
    });

    testWidgets('cycling expiration changes displayed text', (tester) async {
      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          body: FiltersForm(title: 'Cycle Expiry'),
        ),
        accessStatus: MockAccessStatus.authenticated(),
      ));
      await tester.pump();

      // Initially "Never"
      expect(find.text('Never'), findsOneWidget);

      // Tap to cycle
      await tester.tap(find.byIcon(Icons.schedule_outlined));
      await tester.pump();

      // "Never" should no longer be shown (changed to a duration)
      expect(find.text('Never'), findsNothing);
    });
  });

  group('FiltersForm action cycling', () {
    testWidgets('action cycles through all FilterAction values',
        (tester) async {
      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          body: FiltersForm(title: 'Full Cycle'),
        ),
        accessStatus: MockAccessStatus.authenticated(),
      ));
      await tester.pump();

      // Default: hide → block_outlined
      expect(find.byIcon(Icons.block_outlined), findsOneWidget);

      // Cycle: hide → blur → blur_on_outlined
      await tester.tap(find.byIcon(Icons.block_outlined));
      await tester.pump();
      expect(find.byIcon(Icons.blur_on_outlined), findsOneWidget);

      // Cycle: blur → warn → warning_amber_outlined
      await tester.tap(find.byIcon(Icons.blur_on_outlined));
      await tester.pump();
      expect(find.byIcon(Icons.warning_amber_outlined), findsWidgets);

      // Cycle: warn → hide → block_outlined (wraps around)
      // Find the action ListTile's icon — warning_amber_outlined appears on the leading
      final Finder warningIcons = find.byIcon(Icons.warning_amber_outlined);
      await tester.tap(warningIcons.first);
      await tester.pump();
      expect(find.byIcon(Icons.block_outlined), findsOneWidget);
    });
  });

  group('FiltersForm keyword interactions', () {
    testWidgets('shows empty keyword form for adding new keyword',
        (tester) async {
      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          body: FiltersForm(title: 'Keyword Test'),
        ),
        accessStatus: MockAccessStatus.authenticated(),
      ));
      await tester.pump();

      // Should have at least one FilterKeywordForm (the "new keyword" form)
      expect(find.byType(FilterKeywordForm), findsOneWidget);
    });

    testWidgets('existing keywords show with delete icon', (tester) async {
      final schema = FiltersSchema(
        id: 'f1',
        title: 'Has Keywords',
        context: [FilterContext.home],
        action: FilterAction.warn,
        keywords: [
          const FilterKeywordSchema(
              id: 'kw-1', keyword: 'spam', wholeWord: true),
          const FilterKeywordSchema(
              id: 'kw-2', keyword: 'test', wholeWord: false),
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

      // 2 existing keywords + 1 new keyword form = 3 total
      expect(find.byType(FilterKeywordForm), findsNWidgets(3));
      // Existing keywords have delete icons
      expect(find.byIcon(Icons.delete_outline), findsNWidgets(2));
      // New keyword form has add icon
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('adding keyword via text submit creates new keyword form',
        (tester) async {
      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          body: FiltersForm(title: 'Add Keyword'),
        ),
        accessStatus: MockAccessStatus.authenticated(),
      ));
      await tester.pump();

      // Initially one empty keyword form
      expect(find.byType(FilterKeywordForm), findsOneWidget);

      // Find the keyword text field (inside FilterKeywordForm)
      // There are multiple TextFields — keyword form's TextField and title's TextField
      final keywordTextFields = find.descendant(
        of: find.byType(FilterKeywordForm),
        matching: find.byType(TextField),
      );
      expect(keywordTextFields, findsOneWidget);

      // Enter text and submit
      await tester.enterText(keywordTextFields, 'new keyword');
      await tester.pump();
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      // Now should have 2 keyword forms (1 existing + 1 new empty)
      expect(find.byType(FilterKeywordForm), findsNWidgets(2));
    });

    testWidgets('deleting keyword removes it from list', (tester) async {
      final schema = FiltersSchema(
        id: 'f1',
        title: 'Delete Keyword',
        context: [FilterContext.home],
        action: FilterAction.warn,
        keywords: [
          const FilterKeywordSchema(
              id: 'kw-1', keyword: 'removeme', wholeWord: false),
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

      // Initially: 1 existing keyword + 1 new = 2 forms
      expect(find.byType(FilterKeywordForm), findsNWidgets(2));

      // Tap the delete icon on the existing keyword
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pump();

      // The keyword form with destroy=true is filtered out,
      // should now show just the new keyword form
      expect(find.byType(FilterKeywordForm), findsOneWidget);
    });
  });

  group('FiltersForm title field', () {
    testWidgets('title field updates form on focus loss', (tester) async {
      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          body: FiltersForm(title: 'Original Title'),
        ),
        accessStatus: MockAccessStatus.authenticated(),
      ));
      await tester.pump();

      // Find the title text field (has text_fields_outlined leading icon)
      final titleListTile = find.ancestor(
        of: find.byIcon(Icons.text_fields_outlined),
        matching: find.byType(ListTile),
      );
      final titleTextField = find.descendant(
        of: titleListTile,
        matching: find.byType(TextField),
      );
      expect(titleTextField, findsOneWidget);

      // Edit the title
      await tester.enterText(titleTextField, 'Updated Title');
      await tester.pump();

      // Verify the text was entered
      final textField = tester.widget<TextField>(titleTextField);
      expect(textField.controller?.text, 'Updated Title');
    });
  });

  group('FiltersForm with filtered statuses', () {
    testWidgets('shows Divider when schema has statuses', (tester) async {
      final schema = FiltersSchema(
        id: 'f1',
        title: 'With Statuses',
        context: [FilterContext.home],
        action: FilterAction.warn,
        keywords: [],
        statuses: [
          const FilterStatusSchema(id: 'fs-1', statusId: 'status-1'),
        ],
      );

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(
            body: FiltersForm(title: schema.title, schema: schema),
          ),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 100));
        await tester.pump();
      });

      // Should show a Divider separating keywords from statuses
      expect(find.byType(Divider), findsWidgets);
    });

    testWidgets('shows ImageErrorPlaceholder when status fetch returns null',
        (tester) async {
      final schema = FiltersSchema(
        id: 'f1',
        title: 'Null Status',
        context: [FilterContext.home],
        action: FilterAction.warn,
        keywords: [],
        statuses: [
          const FilterStatusSchema(id: 'fs-1', statusId: 'status-1'),
        ],
      );

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(
            body: FiltersForm(title: schema.title, schema: schema),
          ),
          // domain: null causes getStatus() to return null
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();
        // Wait for FutureBuilder to complete
        await Future<void>.delayed(const Duration(milliseconds: 200));
        await tester.pump();
      });

      // FutureBuilder completes with null data → ImageErrorPlaceholder
      expect(find.byType(ImageErrorPlaceholder), findsOneWidget);
    });

    testWidgets('shows multiple error placeholders for multiple null statuses',
        (tester) async {
      final schema = FiltersSchema(
        id: 'f2',
        title: 'Multi Status',
        context: [FilterContext.home],
        action: FilterAction.hide,
        keywords: [],
        statuses: [
          const FilterStatusSchema(id: 'fs-1', statusId: 'status-1'),
          const FilterStatusSchema(id: 'fs-2', statusId: 'status-2'),
        ],
      );

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(
            body: FiltersForm(title: schema.title, schema: schema),
          ),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 200));
        await tester.pump();
      });

      // Both statuses resolve to null → 2 error placeholders
      expect(find.byType(ImageErrorPlaceholder), findsNWidgets(2));
    });
  });

  group('FilterKeywordForm callbacks', () {
    testWidgets('onChanged called with updated schema on wholeWord toggle',
        (tester) async {
      FilterKeywordFormSchema? changedSchema;
      const schema = FilterKeywordFormSchema(
        keyword: 'callback',
        wholeWord: false,
      );

      await tester.pumpWidget(createTestWidget(
        child: FilterKeywordForm(
          schema: schema,
          onDelete: () {},
          onChanged: (item) => changedSchema = item,
        ),
        accessStatus: MockAccessStatus.authenticated(),
      ));
      await tester.pump();

      // Tap the ListTile area (which toggles wholeWord and calls onChanged)
      await tester.tap(find.byIcon(Icons.code_off_outlined));
      await tester.pump();

      expect(changedSchema, isNotNull);
      expect(changedSchema!.wholeWord, isTrue);
    });

    testWidgets('onChanged not called when onDelete is null on toggle',
        (tester) async {
      FilterKeywordFormSchema? changedSchema;
      const schema = FilterKeywordFormSchema(
        keyword: 'no-delete',
        wholeWord: false,
      );

      await tester.pumpWidget(createTestWidget(
        child: FilterKeywordForm(
          schema: schema,
          onChanged: (item) => changedSchema = item,
          // onDelete is null
        ),
        accessStatus: MockAccessStatus.authenticated(),
      ));
      await tester.pump();

      // Tap the leading icon area — onTap toggles wholeWord
      // but only calls onChanged when onDelete != null
      await tester.tap(find.byIcon(Icons.code_off_outlined));
      await tester.pump();

      // onChanged should NOT have been called since onDelete is null
      expect(changedSchema, isNull);
    });

    testWidgets('onSave called via text field submit', (tester) async {
      FilterKeywordFormSchema? changedSchema;
      const schema = FilterKeywordFormSchema(
        keyword: '',
        wholeWord: false,
      );

      await tester.pumpWidget(createTestWidget(
        child: FilterKeywordForm(
          schema: schema,
          onChanged: (item) => changedSchema = item,
        ),
        accessStatus: MockAccessStatus.authenticated(),
      ));
      await tester.pump();

      // Enter text and submit
      await tester.enterText(find.byType(TextField), 'submitted keyword');
      await tester.pump();
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(changedSchema, isNotNull);
      expect(changedSchema!.keyword, 'submitted keyword');
    });

    testWidgets('onSave not called when text is empty', (tester) async {
      FilterKeywordFormSchema? changedSchema;
      const schema = FilterKeywordFormSchema(
        keyword: '',
        wholeWord: false,
      );

      await tester.pumpWidget(createTestWidget(
        child: FilterKeywordForm(
          schema: schema,
          onChanged: (item) => changedSchema = item,
        ),
        accessStatus: MockAccessStatus.authenticated(),
      ));
      await tester.pump();

      // Submit with empty text
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      // onChanged should NOT be called since text is empty
      expect(changedSchema, isNull);
    });

    testWidgets('onSave triggered via add button press', (tester) async {
      FilterKeywordFormSchema? changedSchema;
      const schema = FilterKeywordFormSchema(
        keyword: '',
        wholeWord: false,
      );

      await tester.pumpWidget(createTestWidget(
        child: FilterKeywordForm(
          schema: schema,
          onChanged: (item) => changedSchema = item,
          // onDelete is null, so trailing shows add icon
        ),
        accessStatus: MockAccessStatus.authenticated(),
      ));
      await tester.pump();

      // Enter text first
      await tester.enterText(find.byType(TextField), 'added keyword');
      await tester.pump();

      // Tap the add button
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(changedSchema, isNotNull);
      expect(changedSchema!.keyword, 'added keyword');
    });

    testWidgets('keyword form disposes controller when no external controller',
        (tester) async {
      const schema = FilterKeywordFormSchema(
        keyword: 'disposable',
        wholeWord: false,
      );

      await tester.pumpWidget(createTestWidget(
        child: FilterKeywordForm(schema: schema),
        accessStatus: MockAccessStatus.authenticated(),
      ));
      await tester.pump();

      expect(find.byType(FilterKeywordForm), findsOneWidget);

      // Pump a new widget to trigger dispose
      await tester.pumpWidget(createTestWidget(
        child: const SizedBox.shrink(),
        accessStatus: MockAccessStatus.authenticated(),
      ));
      await tester.pump();

      // No crash means dispose was handled correctly
    });

    testWidgets('keyword form with external controller does not dispose it',
        (tester) async {
      final controller = TextEditingController(text: 'external');
      const schema = FilterKeywordFormSchema(
        keyword: 'external',
        wholeWord: false,
      );

      await tester.pumpWidget(createTestWidget(
        child: FilterKeywordForm(
          schema: schema,
          controller: controller,
        ),
        accessStatus: MockAccessStatus.authenticated(),
      ));
      await tester.pump();

      // The external controller's text should be used
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, 'external');

      // Replace widget to trigger dispose
      await tester.pumpWidget(createTestWidget(
        child: const SizedBox.shrink(),
        accessStatus: MockAccessStatus.authenticated(),
      ));
      await tester.pump();

      // External controller should still be alive
      expect(controller.text, 'external');
      controller.dispose();
    });
  });

  group('FiltersForm with existing schema', () {
    testWidgets('shows correct action icon for warn filter', (tester) async {
      final schema = FiltersSchema(
        id: 'f1',
        title: 'Warn Filter',
        context: [FilterContext.home, FilterContext.notifications],
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

      expect(find.byIcon(Icons.warning_amber_outlined), findsWidgets);
    });

    testWidgets('shows correct action icon for blur filter', (tester) async {
      final schema = FiltersSchema(
        id: 'f2',
        title: 'Blur Filter',
        context: [FilterContext.public],
        action: FilterAction.blur,
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

      expect(find.byIcon(Icons.blur_on_outlined), findsOneWidget);
    });

    testWidgets('pre-selected contexts appear in chips', (tester) async {
      final schema = FiltersSchema(
        id: 'f1',
        title: 'Pre-selected',
        context: [FilterContext.home, FilterContext.public],
        action: FilterAction.hide,
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

      // The save button should be enabled (contexts pre-selected)
      final Finder buttonFinder = find.ancestor(
        of: find.byIcon(Icons.save_outlined),
        matching: find.bySubtype<ButtonStyleButton>(),
      );
      final ButtonStyleButton button =
          tester.widget<ButtonStyleButton>(buttonFinder);
      expect(button.onPressed, isNotNull);
    });

    testWidgets('expired filter shows expired duration text', (tester) async {
      final schema = FiltersSchema(
        id: 'f1',
        title: 'Expired Filter',
        context: [FilterContext.home],
        expiresAt: DateTime.now().subtract(const Duration(hours: 1)),
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

      // The expired filter should show "Expired" text
      expect(find.text('Expired'), findsOneWidget);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
