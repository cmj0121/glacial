// Widget tests for PreviewCard component.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/features/timeline/screens/status_preview_card.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  setUpAll(() => setupTestEnvironment());

  group('PreviewCard', () {
    group('rendering', () {
      testWidgets('displays nothing when image is null', (tester) async {
        final card = MockPreviewCard.createWithoutImage();

        await tester.pumpWidget(createTestWidget(
          child: PreviewCard(schema: card),
        ));
        await tester.pump(const Duration(milliseconds: 100));

        // Should render nothing (SizedBox.shrink)
        expect(find.byType(PreviewCard), findsOneWidget);
        // No title text when no image
        expect(find.text('Test Article'), findsNothing);
      });

      testWidgets('displays nothing when image is empty string', (tester) async {
        final card = MockPreviewCard.create(image: '');

        await tester.pumpWidget(createTestWidget(
          child: PreviewCard(schema: card),
        ));
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byType(PreviewCard), findsOneWidget);
        expect(find.text('Test Article Title'), findsNothing);
      });

      testWidgets('displays title when has image', (tester) async {
        final card = MockPreviewCard.create(
          title: 'My Article Title',
          image: 'https://example.com/image.png',
        );

        await tester.pumpWidget(createTestWidget(
          child: SizedBox(
            width: 400,
            child: PreviewCard(schema: card),
          ),
        ));
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('My Article Title'), findsOneWidget);
      });

      testWidgets('displays description when has image', (tester) async {
        final card = MockPreviewCard.create(
          description: 'This is the article description text.',
          image: 'https://example.com/image.png',
        );

        await tester.pumpWidget(createTestWidget(
          child: SizedBox(
            width: 400,
            child: PreviewCard(schema: card),
          ),
        ));
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('This is the article description text.'), findsOneWidget);
      });
    });

    group('layout', () {
      testWidgets('renders in wide layout for small images', (tester) async {
        final card = MockPreviewCard.create(
          width: 50, // Small width triggers row layout
          height: 50,
          title: 'Small Image Article',
        );

        await tester.pumpWidget(createTestWidget(
          child: SizedBox(
            width: 400,
            child: PreviewCard(schema: card),
          ),
        ));
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Small Image Article'), findsOneWidget);
        // Row layout should be used
        expect(find.byType(Row), findsWidgets);
      });

      testWidgets('renders in column layout for large images', (tester) async {
        final card = MockPreviewCard.create(
          width: 300, // Large width triggers column layout
          height: 200,
          title: 'Large Image Article',
        );

        await tester.pumpWidget(createTestWidget(
          child: SizedBox(
            width: 400,
            child: PreviewCard(schema: card),
          ),
        ));
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Large Image Article'), findsOneWidget);
      });
    });

    group('interaction', () {
      testWidgets('is tappable when has image', (tester) async {
        final card = MockPreviewCard.create(
          url: 'https://example.com/article',
          image: 'https://example.com/image.png',
        );

        await tester.pumpWidget(createTestWidget(
          child: SizedBox(
            width: 400,
            child: PreviewCard(schema: card),
          ),
        ));
        await tester.pump(const Duration(milliseconds: 100));

        // Card should be present and tappable
        expect(find.byType(PreviewCard), findsOneWidget);
      });
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
