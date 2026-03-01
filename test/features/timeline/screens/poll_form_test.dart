import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/features/models.dart';
import 'package:glacial/features/timeline/screens/poll_form.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  setupTestEnvironment();

  group('PollForm', () {
    test('is a ConsumerStatefulWidget', () {
      const widget = PollForm();
      expect(widget, isA<Widget>());
    });

    test('can be created with const constructor', () {
      const widget = PollForm();
      expect(widget.schema, isNull);
      expect(widget.onChanged, isNull);
    });

    test('can be created with schema', () {
      const schema = NewPollSchema();
      const widget = PollForm(schema: schema);
      expect(widget.schema, schema);
    });
  });

  group('PollForm — build branches', () {
    testWidgets('shows SizedBox.shrink when schema is null', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const PollForm(),
        accessStatus: MockAccessStatus.authenticated(server: MockServer.create()),
      ));
      await tester.pump();

      expect(find.byType(PollForm), findsOneWidget);
      // No TextFields rendered when schema is null
      expect(find.byType(TextField), findsNothing);
      // No dropdown rendered
      expect(find.byType(DropdownButton<Duration>), findsNothing);
    });

    testWidgets('renders poll options when schema provided', (tester) async {
      const schema = NewPollSchema(options: ['', '']);

      await tester.pumpWidget(createTestWidget(
        child: const PollForm(schema: schema),
        accessStatus: MockAccessStatus.authenticated(server: MockServer.create()),
      ));
      await tester.pump();

      // 2 empty options → 2 TextFields
      expect(find.byType(TextField), findsNWidgets(2));
    });

    testWidgets('renders actions row when schema provided', (tester) async {
      const schema = NewPollSchema();

      await tester.pumpWidget(createTestWidget(
        child: const PollForm(schema: schema),
        accessStatus: MockAccessStatus.authenticated(server: MockServer.create()),
      ));
      await tester.pump();

      // Actions row has icons for hide totals (visibility_off) and multiple toggle (check_outlined),
      // plus a DropdownButton for expiration
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
      expect(find.byIcon(Icons.check_outlined), findsOneWidget);
      expect(find.byType(DropdownButton<Duration>), findsOneWidget);
    });

    testWidgets('shows checkbox icons for non-empty options', (tester) async {
      const schema = NewPollSchema(options: ['Option A', 'Option B']);

      await tester.pumpWidget(createTestWidget(
        child: const PollForm(schema: schema),
        accessStatus: MockAccessStatus.authenticated(server: MockServer.create()),
      ));
      await tester.pump();

      // Non-empty options → Icons.check_box
      expect(find.byIcon(Icons.check_box), findsNWidgets(2));
      expect(find.byIcon(Icons.check_box_outline_blank), findsNothing);
    });

    testWidgets('shows outline icons for empty options', (tester) async {
      const schema = NewPollSchema(options: ['', '']);

      await tester.pumpWidget(createTestWidget(
        child: const PollForm(schema: schema),
        accessStatus: MockAccessStatus.authenticated(server: MockServer.create()),
      ));
      await tester.pump();

      // Empty options → Icons.check_box_outline_blank
      expect(find.byIcon(Icons.check_box_outline_blank), findsNWidgets(2));
      expect(find.byIcon(Icons.check_box), findsNothing);
    });

    testWidgets('renders dropdown for expiration', (tester) async {
      // expiresIn=86400 matches Duration(days: 1) in the durations list
      const schema = NewPollSchema(expiresIn: 86400);

      await tester.pumpWidget(createTestWidget(
        child: const PollForm(schema: schema),
        accessStatus: MockAccessStatus.authenticated(server: MockServer.create()),
      ));
      await tester.pump();

      expect(find.byType(DropdownButton<Duration>), findsOneWidget);
    });

    testWidgets('renders with 3 options', (tester) async {
      const schema = NewPollSchema(options: ['A', 'B', '']);

      await tester.pumpWidget(createTestWidget(
        child: const PollForm(schema: schema),
        accessStatus: MockAccessStatus.authenticated(server: MockServer.create()),
      ));
      await tester.pump();

      // 3 options → 3 TextFields
      expect(find.byType(TextField), findsNWidgets(3));
      // 2 non-empty → check_box, 1 empty → check_box_outline_blank
      expect(find.byIcon(Icons.check_box), findsNWidgets(2));
      expect(find.byIcon(Icons.check_box_outline_blank), findsOneWidget);
    });

    testWidgets('shows visibility_off icon when hideTotals is false', (tester) async {
      // Default: hideTotals is null → treated as false → visibility_off icon
      const schema = NewPollSchema();

      await tester.pumpWidget(createTestWidget(
        child: const PollForm(schema: schema),
        accessStatus: MockAccessStatus.authenticated(server: MockServer.create()),
      ));
      await tester.pump();

      // hideTotals == false → icon is visibility_off
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
      expect(find.byIcon(Icons.visibility), findsNothing);
    });

    testWidgets('shows visibility icon when hideTotals is true', (tester) async {
      const schema = NewPollSchema(hideTotals: true);

      await tester.pumpWidget(createTestWidget(
        child: const PollForm(schema: schema),
        accessStatus: MockAccessStatus.authenticated(server: MockServer.create()),
      ));
      await tester.pump();

      // hideTotals == true → icon is visibility
      expect(find.byIcon(Icons.visibility), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off), findsNothing);
    });

    testWidgets('shows check_outlined icon when multiple is false', (tester) async {
      const schema = NewPollSchema();

      await tester.pumpWidget(createTestWidget(
        child: const PollForm(schema: schema),
        accessStatus: MockAccessStatus.authenticated(server: MockServer.create()),
      ));
      await tester.pump();

      // multiple == false (default null → false) → check_outlined
      expect(find.byIcon(Icons.check_outlined), findsOneWidget);
      expect(find.byIcon(Icons.checklist_outlined), findsNothing);
    });

    testWidgets('shows checklist_outlined icon when multiple is true', (tester) async {
      const schema = NewPollSchema(multiple: true);

      await tester.pumpWidget(createTestWidget(
        child: const PollForm(schema: schema),
        accessStatus: MockAccessStatus.authenticated(server: MockServer.create()),
      ));
      await tester.pump();

      // multiple == true → checklist_outlined
      expect(find.byIcon(Icons.checklist_outlined), findsOneWidget);
      expect(find.byIcon(Icons.check_outlined), findsNothing);
    });
  });

  group('PollForm — interactions', () {
    testWidgets('tapping hide totals button calls onChanged', (tester) async {
      NewPollSchema? changedPoll;
      final schema = const NewPollSchema(hideTotals: false);

      await tester.pumpWidget(createTestWidget(
        child: PollForm(
          schema: schema,
          onChanged: (poll) => changedPoll = poll,
        ),
        accessStatus: MockAccessStatus.authenticated(server: MockServer.create()),
      ));
      await tester.pump();

      // Tap the hide totals button (visibility_off icon)
      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pump();

      expect(changedPoll, isNotNull);
      expect(changedPoll!.hideTotals, isTrue);
    });

    testWidgets('tapping show totals button calls onChanged with false', (tester) async {
      NewPollSchema? changedPoll;
      final schema = const NewPollSchema(hideTotals: true);

      await tester.pumpWidget(createTestWidget(
        child: PollForm(
          schema: schema,
          onChanged: (poll) => changedPoll = poll,
        ),
        accessStatus: MockAccessStatus.authenticated(server: MockServer.create()),
      ));
      await tester.pump();

      // Tap the show totals button (visibility icon when hideTotals is true)
      await tester.tap(find.byIcon(Icons.visibility));
      await tester.pump();

      expect(changedPoll, isNotNull);
      expect(changedPoll!.hideTotals, isFalse);
    });

    testWidgets('tapping multiple button calls onChanged', (tester) async {
      NewPollSchema? changedPoll;
      final schema = const NewPollSchema(multiple: false);

      await tester.pumpWidget(createTestWidget(
        child: PollForm(
          schema: schema,
          onChanged: (poll) => changedPoll = poll,
        ),
        accessStatus: MockAccessStatus.authenticated(server: MockServer.create()),
      ));
      await tester.pump();

      // Tap the multiple choice button (check_outlined icon when multiple=false)
      await tester.tap(find.byIcon(Icons.check_outlined));
      await tester.pump();

      expect(changedPoll, isNotNull);
      expect(changedPoll!.multiple, isTrue);
    });

    testWidgets('tapping single choice button calls onChanged with false', (tester) async {
      NewPollSchema? changedPoll;
      final schema = const NewPollSchema(multiple: true);

      await tester.pumpWidget(createTestWidget(
        child: PollForm(
          schema: schema,
          onChanged: (poll) => changedPoll = poll,
        ),
        accessStatus: MockAccessStatus.authenticated(server: MockServer.create()),
      ));
      await tester.pump();

      // Tap the single choice button (checklist_outlined icon when multiple=true)
      await tester.tap(find.byIcon(Icons.checklist_outlined));
      await tester.pump();

      expect(changedPoll, isNotNull);
      expect(changedPoll!.multiple, isFalse);
    });

    testWidgets('editing an option and losing focus calls onChanged', (tester) async {
      NewPollSchema? changedPoll;
      const schema = NewPollSchema(options: ['', '']);

      await tester.pumpWidget(createTestWidget(
        child: PollForm(
          schema: schema,
          onChanged: (poll) => changedPoll = poll,
        ),
        accessStatus: MockAccessStatus.authenticated(server: MockServer.create()),
      ));
      await tester.pump();

      // Type text into the first TextField
      final firstField = find.byType(TextField).first;
      await tester.tap(firstField);
      await tester.pump();
      await tester.enterText(firstField, 'My option');
      await tester.pump();

      // Submit the field to trigger onEditCompleted via onSubmitted
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(changedPoll, isNotNull);
      // The non-empty options should be collected + empty padding
      expect(changedPoll!.options.where((o) => o.isNotEmpty).length, 1);
      expect(changedPoll!.options.first, 'My option');
    });
  });

  group('PollForm — without server config', () {
    testWidgets('uses default maxPollCount of 4 when server is null', (tester) async {
      const schema = NewPollSchema(options: ['', '']);

      await tester.pumpWidget(createTestWidget(
        child: const PollForm(schema: schema),
        accessStatus: MockAccessStatus.authenticated(),
      ));
      await tester.pump();

      // Without server, maxPollCount defaults to 4
      // 2 options are rendered because schema has 2 options
      expect(find.byType(TextField), findsNWidgets(2));
    });

    testWidgets('uses default maxLength of 100 when server is null', (tester) async {
      const schema = NewPollSchema(options: ['']);

      await tester.pumpWidget(createTestWidget(
        child: const PollForm(schema: schema),
        accessStatus: MockAccessStatus.authenticated(),
      ));
      await tester.pump();

      // TextField should exist with maxLength of 100 (default)
      final TextField textField = tester.widget<TextField>(find.byType(TextField).first);
      expect(textField.maxLength, 100);
    });

    testWidgets('uses server config maxCharacters when available', (tester) async {
      const schema = NewPollSchema(options: ['']);

      await tester.pumpWidget(createTestWidget(
        child: const PollForm(schema: schema),
        accessStatus: MockAccessStatus.authenticated(server: MockServer.create()),
      ));
      await tester.pump();

      // MockServerConfig creates PollConfigSchema with maxCharacters: 50
      final TextField textField = tester.widget<TextField>(find.byType(TextField).first);
      expect(textField.maxLength, 50);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
