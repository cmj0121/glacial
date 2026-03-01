// Widget tests for AutoCompleteForm.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/features/screens.dart';

import '../../../helpers/test_helpers.dart';

/// A default field builder for tests (required by RawAutocomplete).
AutocompleteFieldViewBuilder _defaultBuilder() {
  return (context, textEditingController, focusNode, onFieldSubmitted) {
    return TextField(
      controller: textEditingController,
      focusNode: focusNode,
      decoration: const InputDecoration(hintText: 'Test field'),
    );
  };
}

void main() {
  setupTestEnvironment();

  group('AutoCompleteForm', () {
    testWidgets('renders with builder', (tester) async {
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AutoCompleteForm(builder: _defaultBuilder()),
        accessStatus: status,
      ));
      await tester.pump();

      expect(find.byType(AutoCompleteForm), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('renders with initial text', (tester) async {
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AutoCompleteForm(
          initialText: 'Hello world',
          builder: _defaultBuilder(),
        ),
        accessStatus: status,
      ));
      await tester.pump();

      expect(find.byType(AutoCompleteForm), findsOneWidget);
    });

    testWidgets('renders with external controller', (tester) async {
      final controller = TextEditingController(text: 'Test');
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AutoCompleteForm(
          controller: controller,
          builder: _defaultBuilder(),
        ),
        accessStatus: status,
      ));
      await tester.pump();

      expect(find.byType(AutoCompleteForm), findsOneWidget);
      controller.dispose();
    });

    testWidgets('renders with custom hint text in builder', (tester) async {
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AutoCompleteForm(
          builder: (context, controller, focusNode, onSubmitted) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: const InputDecoration(hintText: 'Custom hint'),
            );
          },
        ),
        accessStatus: status,
      ));
      await tester.pump();

      expect(find.text('Custom hint'), findsOneWidget);
    });

    testWidgets('renders with custom maxSuggestions', (tester) async {
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AutoCompleteForm(
          maxSuggestions: 5,
          builder: _defaultBuilder(),
        ),
        accessStatus: status,
      ));
      await tester.pump();

      expect(find.byType(AutoCompleteForm), findsOneWidget);
    });

    testWidgets('uses RawAutocomplete internally', (tester) async {
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AutoCompleteForm(builder: _defaultBuilder()),
        accessStatus: status,
      ));
      await tester.pump();

      expect(find.byType(RawAutocomplete<String>), findsOneWidget);
    });

    testWidgets('renders with anonymous status', (tester) async {
      final status = MockAccessStatus.anonymous();

      await tester.pumpWidget(createTestWidget(
        child: AutoCompleteForm(builder: _defaultBuilder()),
        accessStatus: status,
      ));
      await tester.pump();

      expect(find.byType(AutoCompleteForm), findsOneWidget);
    });

    testWidgets('shows hint text from builder', (tester) async {
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AutoCompleteForm(builder: _defaultBuilder()),
        accessStatus: status,
      ));
      await tester.pump();

      expect(find.text('Test field'), findsOneWidget);
    });

    testWidgets('initialText populates the text field', (tester) async {
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AutoCompleteForm(
          initialText: 'Hello @user',
          builder: _defaultBuilder(),
        ),
        accessStatus: status,
      ));
      await tester.pump();

      expect(find.text('Hello @user'), findsOneWidget);
    });

    testWidgets('external controller text is shown in field', (tester) async {
      final controller = TextEditingController(text: 'External text');
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AutoCompleteForm(
          controller: controller,
          builder: _defaultBuilder(),
        ),
        accessStatus: status,
      ));
      await tester.pump();

      expect(find.text('External text'), findsOneWidget);
      controller.dispose();
    });

    testWidgets('disposes internal controller safely', (tester) async {
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AutoCompleteForm(builder: _defaultBuilder()),
        accessStatus: status,
      ));
      await tester.pump();

      // Replacing widget tree should not throw
      await tester.pumpWidget(createTestWidget(
        child: const SizedBox.shrink(),
        accessStatus: status,
      ));
      await tester.pump();
    });

    testWidgets('does not dispose external controller', (tester) async {
      final controller = TextEditingController(text: 'Keep me');
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AutoCompleteForm(
          controller: controller,
          builder: _defaultBuilder(),
        ),
        accessStatus: status,
      ));
      await tester.pump();

      // Replace widget tree
      await tester.pumpWidget(createTestWidget(
        child: const SizedBox.shrink(),
        accessStatus: status,
      ));
      await tester.pump();

      // Controller should still be usable
      expect(controller.text, 'Keep me');
      controller.dispose();
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
