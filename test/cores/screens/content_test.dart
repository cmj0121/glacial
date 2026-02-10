// Widget tests for HtmlDone and PopUpTextField.
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/cores/screens/content.dart';
import 'package:glacial/cores/screens/misc.dart';

import '../../helpers/test_helpers.dart';

void main() {
  setupTestEnvironment();

  group('HtmlDone', () {
    testWidgets('renders Html widget', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const HtmlDone(html: '<p>Hello World</p>'),
      ));
      await tester.pump();

      expect(find.byType(Html), findsOneWidget);
    });

    testWidgets('displays provided HTML content', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const HtmlDone(html: '<p>Test Content</p>'),
      ));
      await tester.pump();

      expect(find.text('Test Content'), findsOneWidget);
    });

    test('accepts emojis parameter without rendering', () {
      final emoji = MockEmoji.create(shortcode: 'wave');
      final widget = HtmlDone(html: '<p>Hello :wave:</p>', emojis: [emoji]);

      expect(widget.emojis.length, 1);
      expect(widget.emojis.first.shortcode, 'wave');
    });

    testWidgets('renders empty HTML without error', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const HtmlDone(html: ''),
      ));
      await tester.pump();

      expect(find.byType(Html), findsOneWidget);
    });

    testWidgets('renders HTML with link tags', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const HtmlDone(html: '<p><a href="https://example.com">Link</a></p>'),
      ));
      await tester.pump();

      expect(find.byType(Html), findsOneWidget);
    });

    testWidgets('accepts onLinkTap callback', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(createTestWidget(
        child: HtmlDone(
          html: '<p><a href="https://example.com">Tap me</a></p>',
          onLinkTap: (url, attributes, element) {
            tapped = true;
          },
        ),
      ));
      await tester.pump();

      expect(find.byType(Html), findsOneWidget);
      // The callback is registered even if not yet triggered
      expect(tapped, isFalse);
    });
  });

  group('PopUpTextField', () {
    testWidgets('renders InkWellDone wrapper', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: PopUpTextField(
          controller: TextEditingController(text: 'Hello'),
        ),
      ));
      await tester.pump();

      expect(find.byType(InkWellDone), findsOneWidget);
    });

    testWidgets('displays controller text', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: PopUpTextField(
          controller: TextEditingController(text: 'Sample text'),
        ),
      ));
      await tester.pump();

      expect(find.text('Sample text'), findsOneWidget);
    });

    testWidgets('displays empty text when no controller', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const PopUpTextField(),
      ));
      await tester.pump();

      // Should render without error — empty string is shown
      expect(find.byType(PopUpTextField), findsOneWidget);
    });

    testWidgets('uses Align with centerLeft alignment', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: PopUpTextField(
          controller: TextEditingController(text: 'Aligned'),
        ),
      ));
      await tester.pump();

      final align = tester.widget<Align>(find.byType(Align).first);
      expect(align.alignment, Alignment.centerLeft);
    });

    testWidgets('shows dialog on tap', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: PopUpTextField(
          controller: TextEditingController(text: 'Tap me'),
        ),
      ));
      await tester.pump();

      await tester.tap(find.byType(InkWellDone));
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('dialog TextField uses OutlineInputBorder', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: PopUpTextField(
          controller: TextEditingController(text: 'Border test'),
        ),
      ));
      await tester.pump();

      await tester.tap(find.byType(InkWellDone));
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.decoration?.border, isA<OutlineInputBorder>());
    });

    testWidgets('renders HtmlDone when isHTML is true', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: PopUpTextField(
          isHTML: true,
          controller: TextEditingController(text: '<p>HTML text</p>'),
        ),
      ));
      await tester.pump();

      expect(find.byType(HtmlDone), findsOneWidget);
    });

    testWidgets('renders Text when isHTML is false', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: PopUpTextField(
          isHTML: false,
          controller: TextEditingController(text: 'Plain text'),
        ),
      ));
      await tester.pump();

      expect(find.text('Plain text'), findsOneWidget);
      expect(find.byType(HtmlDone), findsNothing);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
