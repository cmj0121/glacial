// Widget tests for TrendsLink widget.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/trends/screens/link.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  setupTestEnvironment();

  group('TrendsLink', () {
    testWidgets('renders title text', (tester) async {
      final link = MockLink.create(title: 'Amazing Article Title');

      await tester.pumpWidget(createTestWidget(
        child: TrendsLink(schema: link),
      ));
      await tester.pump();

      expect(find.text('Amazing Article Title'), findsOneWidget);
    });

    testWidgets('renders description text', (tester) async {
      final link = MockLink.create(desc: 'This is a great description.');

      await tester.pumpWidget(createTestWidget(
        child: TrendsLink(schema: link),
      ));
      await tester.pump();

      expect(find.text('This is a great description.'), findsOneWidget);
    });

    testWidgets('renders author name', (tester) async {
      final link = MockLink.create(authName: 'John Doe');

      await tester.pumpWidget(createTestWidget(
        child: TrendsLink(schema: link),
      ));
      await tester.pump();

      expect(find.text('John Doe'), findsOneWidget);
    });

    testWidgets('displays image with CachedNetworkImage', (tester) async {
      final link = MockLink.create(image: 'https://example.com/test-image.jpg');

      await tester.pumpWidget(createTestWidget(
        child: TrendsLink(schema: link),
      ));
      await tester.pump();

      expect(find.byType(CachedNetworkImage), findsOneWidget);
      final CachedNetworkImage image = tester.widget<CachedNetworkImage>(
        find.byType(CachedNetworkImage),
      );
      expect(image.imageUrl, 'https://example.com/test-image.jpg');
    });

    testWidgets('uses default maxHeight and imageSize', (tester) async {
      final link = MockLink.create();

      await tester.pumpWidget(createTestWidget(
        child: TrendsLink(schema: link),
      ));
      await tester.pump();

      // Verify widget renders with defaults
      expect(find.byType(TrendsLink), findsOneWidget);

      // Image size should be 120 (default)
      final SizedBox imageSizedBox = tester.widget<SizedBox>(
        find.ancestor(
          of: find.byType(CachedNetworkImage),
          matching: find.byType(SizedBox),
        ).first,
      );
      expect(imageSizedBox.width, 120);
      expect(imageSizedBox.height, 120);
    });

    testWidgets('accepts custom maxHeight', (tester) async {
      final link = MockLink.create();

      await tester.pumpWidget(createTestWidget(
        child: TrendsLink(schema: link, maxHeight: 300),
      ));
      await tester.pump();

      // Find the Container with BoxConstraints
      final Container container = tester.widget<Container>(
        find.ancestor(
          of: find.byType(InkWellDone),
          matching: find.byType(Container),
        ).first,
      );
      expect(container.constraints?.maxHeight, 300);
    });

    testWidgets('accepts custom imageSize', (tester) async {
      final link = MockLink.create();

      await tester.pumpWidget(createTestWidget(
        child: TrendsLink(schema: link, imageSize: 80),
      ));
      await tester.pump();

      // Image size should be 80 (custom)
      final SizedBox imageSizedBox = tester.widget<SizedBox>(
        find.ancestor(
          of: find.byType(CachedNetworkImage),
          matching: find.byType(SizedBox),
        ).first,
      );
      expect(imageSizedBox.width, 80);
      expect(imageSizedBox.height, 80);
    });

    testWidgets('wraps content in InkWellDone', (tester) async {
      final link = MockLink.create();

      await tester.pumpWidget(createTestWidget(
        child: TrendsLink(schema: link),
      ));
      await tester.pump();

      // TrendsLink uses InkWellDone for the main content wrapper
      expect(
        find.descendant(
          of: find.byType(TrendsLink),
          matching: find.byType(InkWellDone),
        ),
        findsWidgets,
      );
    });

    testWidgets('uses Row layout for content', (tester) async {
      final link = MockLink.create();

      await tester.pumpWidget(createTestWidget(
        child: TrendsLink(schema: link),
      ));
      await tester.pump();

      expect(find.byType(Row), findsOneWidget);
    });

    testWidgets('displays author as plain text when authUrl is empty', (tester) async {
      final link = MockLink.create(
        authName: 'Plain Author',
        authUrl: '',
      );

      await tester.pumpWidget(createTestWidget(
        child: TrendsLink(schema: link),
      ));
      await tester.pump();

      expect(find.text('Plain Author'), findsOneWidget);
      // Should not have an InkWell around the author when URL is empty
      // The InkWellDone is for the main card, not the author
    });

    testWidgets('displays author as tappable link when authUrl is valid', (tester) async {
      final link = MockLink.create(
        authName: 'Linked Author',
        authUrl: 'https://example.com/author',
      );

      await tester.pumpWidget(createTestWidget(
        child: TrendsLink(schema: link),
      ));
      await tester.pump();

      expect(find.text('Linked Author'), findsOneWidget);
      // Should have an InkWell around the author when URL is valid
      expect(find.byType(InkWell), findsWidgets);
    });

    testWidgets('renders with no-author link', (tester) async {
      final link = MockLink.withoutAuthor(
        title: 'No Author Article',
        desc: 'Article with no author info',
      );

      await tester.pumpWidget(createTestWidget(
        child: TrendsLink(schema: link),
      ));
      await tester.pump();

      expect(find.text('No Author Article'), findsOneWidget);
      expect(find.text('Article with no author info'), findsOneWidget);
    });

    testWidgets('clips image with rounded corners', (tester) async {
      final link = MockLink.create();

      await tester.pumpWidget(createTestWidget(
        child: TrendsLink(schema: link),
      ));
      await tester.pump();

      expect(find.byType(ClipRRect), findsOneWidget);
      final ClipRRect clipRRect = tester.widget<ClipRRect>(find.byType(ClipRRect));
      expect(clipRRect.borderRadius, BorderRadius.circular(8));
    });

    testWidgets('main card onTap triggers navigation', (tester) async {
      final link = MockLink.create(url: 'https://example.com/article');

      await tester.pumpWidget(createTestWidget(
        child: TrendsLink(schema: link),
      ));
      await tester.pump();

      // Find the InkWellDone wrapping the card and verify its onTap is set
      final InkWellDone inkWellDone = tester.widget<InkWellDone>(
        find.descendant(
          of: find.byType(TrendsLink),
          matching: find.byType(InkWellDone),
        ).first,
      );
      expect(inkWellDone.onTap, isNotNull);

      // Tap the card — triggers context.push which throws without GoRouter
      await tester.tap(find.byType(InkWellDone).first);
      await tester.pump();

      // Consume the expected GoRouter error
      expect(tester.takeException(), isNotNull);
    });

    testWidgets('author link onTap triggers navigation when authUrl is valid', (tester) async {
      final link = MockLink.create(
        authName: 'Tappable Author',
        authUrl: 'https://example.com/author-page',
      );

      await tester.pumpWidget(createTestWidget(
        child: TrendsLink(schema: link),
      ));
      await tester.pump();

      // Find the author InkWell (not InkWellDone)
      final Finder authorInkWell = find.ancestor(
        of: find.text('Tappable Author'),
        matching: find.byType(InkWell),
      );
      expect(authorInkWell, findsWidgets);

      // Tap the author link — triggers context.push which throws without GoRouter
      await tester.tap(find.text('Tappable Author'));
      await tester.pump();

      // Consume the expected GoRouter error
      expect(tester.takeException(), isNotNull);
    });

    testWidgets('CachedNetworkImage has an errorWidget callback', (tester) async {
      final link = MockLink.create(image: 'https://example.com/broken.jpg');

      await tester.pumpWidget(createTestWidget(
        child: TrendsLink(schema: link),
      ));
      await tester.pump();

      // Verify the CachedNetworkImage has an errorWidget that returns ImageErrorPlaceholder
      final CachedNetworkImage image = tester.widget<CachedNetworkImage>(
        find.byType(CachedNetworkImage),
      );
      expect(image.errorWidget, isNotNull);

      // Invoke the errorWidget callback to cover line 88
      final Widget errorWidget = image.errorWidget!(
        tester.element(find.byType(CachedNetworkImage)),
        'https://example.com/broken.jpg',
        Exception('load failed'),
      );
      expect(errorWidget, isA<ImageErrorPlaceholder>());
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
