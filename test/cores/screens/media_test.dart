// Widget tests for MediaHero, MediaGallery, and MediaViewer.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/cores/screens/media.dart';
import 'package:glacial/cores/screens/misc.dart';
import 'package:glacial/features/models.dart';

import '../../helpers/test_helpers.dart';

void main() {
  setupTestEnvironment();

  group('MediaHero', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const MediaHero(child: Text('Media Child')),
      ));
      await tester.pump();

      expect(find.text('Media Child'), findsOneWidget);
    });

    testWidgets('wraps child in InkWellDone', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const MediaHero(child: Icon(Icons.image)),
      ));
      await tester.pump();

      expect(find.byType(InkWellDone), findsOneWidget);
    });

    testWidgets('uses custom onTap when provided', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(createTestWidget(
        child: MediaHero(
          onTap: () => tapped = true,
          child: const Text('Tap me'),
        ),
      ));
      await tester.pump();

      await tester.tap(find.text('Tap me'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('navigates to gallery on tap when schemas provided', (tester) async {
      final schemas = [
        MockAttachment.create(id: 'att-1'),
        MockAttachment.create(id: 'att-2'),
      ];

      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          body: MediaHero(
            schemas: schemas,
            child: const Text('Gallery tap'),
          ),
        ),
      ));
      await tester.pump();

      await tester.tap(find.text('Gallery tap'));
      await tester.pump();
      await tester.pump();

      expect(find.byType(MediaGallery), findsOneWidget);
    });

    testWidgets('navigates to single MediaViewer when no schemas', (tester) async {
      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          body: MediaHero(
            child: const Text('Single media'),
          ),
        ),
      ));
      await tester.pump();

      await tester.tap(find.text('Single media'));
      await tester.pump();
      await tester.pump();

      expect(find.byType(MediaViewer), findsOneWidget);
    });

    testWidgets('passes initialIndex to gallery', (tester) async {
      final schemas = [
        MockAttachment.create(id: 'att-1'),
        MockAttachment.create(id: 'att-2'),
        MockAttachment.create(id: 'att-3'),
      ];

      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          body: MediaHero(
            schemas: schemas,
            initialIndex: 2,
            child: const Text('Index 2'),
          ),
        ),
      ));
      await tester.pump();

      await tester.tap(find.text('Index 2'));
      await tester.pump();
      await tester.pump();

      // Gallery is shown at page index 2 → shows "3 / 3"
      expect(find.text('3 / 3'), findsOneWidget);
    });
  });

  group('MediaGallery', () {
    testWidgets('renders PageView', (tester) async {
      final schemas = [MockAttachment.create()];

      await tester.pumpWidget(createTestWidgetRaw(
        child: MediaGallery(schemas: schemas),
      ));
      await tester.pump();

      expect(find.byType(PageView), findsOneWidget);
    });

    testWidgets('shows close button in top bar', (tester) async {
      final schemas = [MockAttachment.create()];

      await tester.pumpWidget(createTestWidgetRaw(
        child: MediaGallery(schemas: schemas),
      ));
      await tester.pump();

      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('shows info button in top bar', (tester) async {
      final schemas = [MockAttachment.create()];

      await tester.pumpWidget(createTestWidgetRaw(
        child: MediaGallery(schemas: schemas),
      ));
      await tester.pump();

      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('hides page counter for single image', (tester) async {
      final schemas = [MockAttachment.create()];

      await tester.pumpWidget(createTestWidgetRaw(
        child: MediaGallery(schemas: schemas),
      ));
      await tester.pump();

      expect(find.text('1 / 1'), findsNothing);
    });

    testWidgets('shows page counter for multiple images', (tester) async {
      final schemas = [
        MockAttachment.create(id: '1'),
        MockAttachment.create(id: '2'),
      ];

      await tester.pumpWidget(createTestWidgetRaw(
        child: MediaGallery(schemas: schemas),
      ));
      await tester.pump();

      expect(find.text('1 / 2'), findsOneWidget);
    });

    testWidgets('shows page indicators for multiple images', (tester) async {
      final schemas = [
        MockAttachment.create(id: '1'),
        MockAttachment.create(id: '2'),
        MockAttachment.create(id: '3'),
      ];

      await tester.pumpWidget(createTestWidgetRaw(
        child: MediaGallery(schemas: schemas),
      ));
      await tester.pump();

      // Bottom bar has 3 dot indicators (Container with BoxShape.circle)
      final dots = tester.widgetList<Container>(find.byType(Container)).where((c) {
        final decoration = c.decoration;
        if (decoration is BoxDecoration) {
          return decoration.shape == BoxShape.circle;
        }
        return false;
      }).toList();

      expect(dots.length, 3);
    });

    testWidgets('hides bottom bar for single image', (tester) async {
      final schemas = [MockAttachment.create()];

      await tester.pumpWidget(createTestWidgetRaw(
        child: MediaGallery(schemas: schemas),
      ));
      await tester.pump();

      // No page indicator dots
      final dots = tester.widgetList<Container>(find.byType(Container)).where((c) {
        final decoration = c.decoration;
        if (decoration is BoxDecoration) {
          return decoration.shape == BoxShape.circle;
        }
        return false;
      }).toList();

      expect(dots.length, 0);
    });

    testWidgets('starts at initialIndex', (tester) async {
      final schemas = [
        MockAttachment.create(id: '1'),
        MockAttachment.create(id: '2'),
        MockAttachment.create(id: '3'),
      ];

      await tester.pumpWidget(createTestWidgetRaw(
        child: MediaGallery(schemas: schemas, initialIndex: 1),
      ));
      await tester.pump();

      expect(find.text('2 / 3'), findsOneWidget);
    });

    testWidgets('renders Scaffold with black background', (tester) async {
      final schemas = [MockAttachment.create()];

      await tester.pumpWidget(createTestWidgetRaw(
        child: MediaGallery(schemas: schemas),
      ));
      await tester.pump();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    test('MediaGallery accepts description in schemas', () {
      final schemas = [
        MockAttachment.create(description: 'Beautiful sunset'),
      ];
      final gallery = MediaGallery(schemas: schemas);
      expect(gallery.schemas.first.description, 'Beautiful sunset');
    });

    testWidgets('shows unsupported icon for non-image media', (tester) async {
      final schemas = [
        MockAttachment.create(type: MediaType.unknown),
      ];

      await tester.pumpWidget(createTestWidgetRaw(
        child: MediaGallery(schemas: schemas),
      ));
      await tester.pump();

      expect(find.byIcon(Icons.image_not_supported), findsOneWidget);
    });
  });

  group('MediaViewer', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          body: MediaViewer(child: const Text('Viewer Content')),
        ),
      ));
      await tester.pump();

      expect(find.text('Viewer Content'), findsOneWidget);
    });

    testWidgets('wraps content in InteractiveViewer', (tester) async {
      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          body: MediaViewer(child: const Icon(Icons.image)),
        ),
      ));
      await tester.pump();

      expect(find.byType(InteractiveViewer), findsOneWidget);
    });

    testWidgets('shows close button when no onDismiss callback', (tester) async {
      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          body: MediaViewer(child: const Text('With close')),
        ),
      ));
      await tester.pump();

      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('hides close button when onDismiss is provided', (tester) async {
      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          body: MediaViewer(
            onDismiss: () {},
            child: const Text('Gallery mode'),
          ),
        ),
      ));
      await tester.pump();

      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('uses GestureDetector for interactions', (tester) async {
      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          body: MediaViewer(child: const Text('Gestures')),
        ),
      ));
      await tester.pump();

      expect(find.byType(GestureDetector), findsWidgets);
    });

    testWidgets('uses Padding with 8.0 inset', (tester) async {
      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          body: MediaViewer(child: const Text('Padded')),
        ),
      ));
      await tester.pump();

      final padding = tester.widget<Padding>(find.byType(Padding).first);
      expect(padding.padding, const EdgeInsets.all(8.0));
    });

    testWidgets('uses FittedBox with BoxFit.contain', (tester) async {
      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          body: MediaViewer(child: const Text('Fitted')),
        ),
      ));
      await tester.pump();

      final fittedBox = tester.widget<FittedBox>(find.byType(FittedBox));
      expect(fittedBox.fit, BoxFit.contain);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
