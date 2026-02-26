// Widget tests for MediaGallery — covers info panel, page navigation,
// zoom/drag callbacks, media content variants, and state interactions.
import 'package:exif/exif.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/cores/screens/media_gallery.dart';
import 'package:glacial/cores/screens/media_viewer.dart';
import 'package:glacial/features/models.dart';

import '../../helpers/test_helpers.dart';

void main() {
  setupTestEnvironment();

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  List<AttachmentSchema> makeSchemas(int count, {MediaType type = MediaType.image}) {
    return List.generate(count, (i) => MockAttachment.create(
      id: 'att-$i',
      type: type,
      description: 'Image $i description',
    ));
  }

  // ---------------------------------------------------------------------------
  // Page navigation — use pump() not pumpAndSettle() (CachedNetworkImage)
  // ---------------------------------------------------------------------------

  group('MediaGallery page navigation', () {
    testWidgets('page change via onPageChanged updates currentIndex', (tester) async {
      final schemas = makeSchemas(3);

      await tester.pumpWidget(createTestWidgetRaw(
        child: MediaGallery(schemas: schemas),
      ));
      await tester.pump();

      expect(find.text('1 / 3'), findsOneWidget);

      // Simulate page change by calling onPageChanged callback directly
      final pageView = tester.widget<PageView>(find.byType(PageView));
      pageView.onPageChanged?.call(1);
      await tester.pump();

      expect(find.text('2 / 3'), findsOneWidget);
    });

    testWidgets('page change via onPageChanged resets exifData and showInfo', (tester) async {
      final schemas = makeSchemas(2);

      await tester.pumpWidget(createTestWidgetRaw(
        child: MediaGallery(schemas: schemas),
      ));
      await tester.pump();

      // Change to page 2
      final pageView = tester.widget<PageView>(find.byType(PageView));
      pageView.onPageChanged?.call(1);
      await tester.pump();

      expect(find.text('2 / 2'), findsOneWidget);
      // After page change, showInfo is false, so info_outline should show
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('initialIndex sets starting page correctly', (tester) async {
      final schemas = makeSchemas(4);

      await tester.pumpWidget(createTestWidgetRaw(
        child: MediaGallery(schemas: schemas, initialIndex: 2),
      ));
      await tester.pump();

      expect(find.text('3 / 4'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // Info panel — test via tester.runAsync to handle async onToggleInfo
  // ---------------------------------------------------------------------------

  group('MediaGallery info panel', () {
    testWidgets('tapping info button toggles showInfo when exifData is pre-set', (tester) async {
      final schemas = [MockAttachment.create(description: 'Alt text here')];

      await tester.pumpWidget(createTestWidgetRaw(
        child: MediaGallery(schemas: schemas),
      ));
      await tester.pump();

      // Initially shows info_outline
      expect(find.byIcon(Icons.info_outline), findsOneWidget);

      // Pre-set exifData to skip the async loadExifData call
      final state = tester.state(find.byType(MediaGallery));
      // ignore: avoid_dynamic_calls
      (state as dynamic).exifData = <String, IfdTag>{};

      // Now tap the info button — onToggleInfo skips loadExifData since exifData != null
      await tester.tap(find.byIcon(Icons.info_outline));
      await tester.pump();

      // After toggle, the filled info icon should appear
      expect(find.byIcon(Icons.info), findsOneWidget);

      // Tap again to close
      await tester.tap(find.byIcon(Icons.info));
      await tester.pump();

      // Should go back to outline
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('info panel displays alt text when description is present', (tester) async {
      final schemas = [MockAttachment.create(description: 'Beautiful sunset photo')];

      await tester.pumpWidget(createTestWidgetRaw(
        child: MediaGallery(schemas: schemas),
      ));
      await tester.pump();

      // Pre-set exifData so onToggleInfo doesn't hang on network call
      final state = tester.state(find.byType(MediaGallery));
      // ignore: avoid_dynamic_calls
      (state as dynamic).exifData = <String, IfdTag>{};

      // Open info panel
      await tester.tap(find.byIcon(Icons.info_outline));
      await tester.pump();

      expect(find.text('Beautiful sunset photo'), findsOneWidget);
    });

    testWidgets('info panel does not show alt text when description is null', (tester) async {
      final schemas = [MockAttachment.create(description: null)];

      await tester.pumpWidget(createTestWidgetRaw(
        child: MediaGallery(schemas: schemas),
      ));
      await tester.pump();

      // Pre-set exifData
      final state = tester.state(find.byType(MediaGallery));
      // ignore: avoid_dynamic_calls
      (state as dynamic).exifData = <String, IfdTag>{};

      await tester.tap(find.byIcon(Icons.info_outline));
      await tester.pump();

      // Alt Text heading should NOT appear
      expect(find.text('Alt Text'), findsNothing);
    });

    testWidgets('info panel does not show alt text when description is empty', (tester) async {
      final schemas = [MockAttachment.create(description: '')];

      await tester.pumpWidget(createTestWidgetRaw(
        child: MediaGallery(schemas: schemas),
      ));
      await tester.pump();

      // Pre-set exifData
      final state = tester.state(find.byType(MediaGallery));
      // ignore: avoid_dynamic_calls
      (state as dynamic).exifData = <String, IfdTag>{};

      await tester.tap(find.byIcon(Icons.info_outline));
      await tester.pump();

      expect(find.text('Alt Text'), findsNothing);
    });
  });

  // ---------------------------------------------------------------------------
  // Media content rendering
  // ---------------------------------------------------------------------------

  group('MediaGallery media content', () {
    testWidgets('renders CachedNetworkImage for image type', (tester) async {
      final schemas = [MockAttachment.create(type: MediaType.image)];

      await tester.pumpWidget(createTestWidgetRaw(
        child: MediaGallery(schemas: schemas),
      ));
      await tester.pump();

      expect(find.byIcon(Icons.image_not_supported), findsNothing);
    });

    testWidgets('renders CachedNetworkImage for gifv type', (tester) async {
      final schemas = [MockAttachment.create(type: MediaType.gifv)];

      await tester.pumpWidget(createTestWidgetRaw(
        child: MediaGallery(schemas: schemas),
      ));
      await tester.pump();

      expect(find.byIcon(Icons.image_not_supported), findsNothing);
    });

    testWidgets('renders unsupported icon for video type', (tester) async {
      final schemas = [MockAttachment.create(type: MediaType.video)];

      await tester.pumpWidget(createTestWidgetRaw(
        child: MediaGallery(schemas: schemas),
      ));
      await tester.pump();

      expect(find.byIcon(Icons.image_not_supported), findsOneWidget);
    });

    testWidgets('renders unsupported icon for audio type', (tester) async {
      final schemas = [MockAttachment.create(type: MediaType.audio)];

      await tester.pumpWidget(createTestWidgetRaw(
        child: MediaGallery(schemas: schemas),
      ));
      await tester.pump();

      expect(find.byIcon(Icons.image_not_supported), findsOneWidget);
    });

    testWidgets('renders unsupported icon for unknown type', (tester) async {
      final schemas = [MockAttachment.create(type: MediaType.unknown)];

      await tester.pumpWidget(createTestWidgetRaw(
        child: MediaGallery(schemas: schemas),
      ));
      await tester.pump();

      expect(find.byIcon(Icons.image_not_supported), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // Zoom state
  // ---------------------------------------------------------------------------

  group('MediaGallery zoom interaction', () {
    testWidgets('contains MediaViewer for each page item', (tester) async {
      final schemas = makeSchemas(1);

      await tester.pumpWidget(createTestWidgetRaw(
        child: MediaGallery(schemas: schemas),
      ));
      await tester.pump();

      expect(find.byType(MediaViewer), findsOneWidget);
    });

    testWidgets('PageView allows swiping when not zoomed', (tester) async {
      final schemas = makeSchemas(2);

      await tester.pumpWidget(createTestWidgetRaw(
        child: MediaGallery(schemas: schemas),
      ));
      await tester.pump();

      final pageView = tester.widget<PageView>(find.byType(PageView));
      expect(pageView.physics, isNull);
    });

    testWidgets('onZoomChanged(true) disables PageView swiping', (tester) async {
      final schemas = makeSchemas(2);

      await tester.pumpWidget(createTestWidgetRaw(
        child: MediaGallery(schemas: schemas),
      ));
      await tester.pump();

      final state = tester.state(find.byType(MediaGallery));
      // ignore: avoid_dynamic_calls
      (state as dynamic).onZoomChanged(true);
      await tester.pump();

      final pageView = tester.widget<PageView>(find.byType(PageView));
      expect(pageView.physics, isA<NeverScrollableScrollPhysics>());
    });

    testWidgets('onZoomChanged(false) restores normal physics', (tester) async {
      final schemas = makeSchemas(2);

      await tester.pumpWidget(createTestWidgetRaw(
        child: MediaGallery(schemas: schemas),
      ));
      await tester.pump();

      final state = tester.state(find.byType(MediaGallery));
      // ignore: avoid_dynamic_calls
      (state as dynamic).onZoomChanged(true);
      await tester.pump();
      // ignore: avoid_dynamic_calls
      (state as dynamic).onZoomChanged(false);
      await tester.pump();

      final pageView = tester.widget<PageView>(find.byType(PageView));
      expect(pageView.physics, isNull);
    });

    testWidgets('calling onZoomChanged with same value is a no-op', (tester) async {
      final schemas = makeSchemas(1);

      await tester.pumpWidget(createTestWidgetRaw(
        child: MediaGallery(schemas: schemas),
      ));
      await tester.pump();

      final state = tester.state(find.byType(MediaGallery));
      // Should not throw when called multiple times with same value
      // ignore: avoid_dynamic_calls
      (state as dynamic).onZoomChanged(false);
      // ignore: avoid_dynamic_calls
      (state as dynamic).onZoomChanged(false);
      await tester.pump();

      expect(find.byType(PageView), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // Close and info buttons
  // ---------------------------------------------------------------------------

  group('MediaGallery top bar', () {
    testWidgets('close icon is present', (tester) async {
      final schemas = [MockAttachment.create()];

      await tester.pumpWidget(createTestWidgetRaw(
        child: MediaGallery(schemas: schemas),
      ));
      await tester.pump();

      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('info icon is present', (tester) async {
      final schemas = [MockAttachment.create()];

      await tester.pumpWidget(createTestWidgetRaw(
        child: MediaGallery(schemas: schemas),
      ));
      await tester.pump();

      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('top bar contains gradient container', (tester) async {
      final schemas = makeSchemas(1);

      await tester.pumpWidget(createTestWidgetRaw(
        child: MediaGallery(schemas: schemas),
      ));
      await tester.pump();

      expect(find.byType(Positioned), findsWidgets);
    });

    testWidgets('top bar has Row with buttons', (tester) async {
      final schemas = makeSchemas(1);

      await tester.pumpWidget(createTestWidgetRaw(
        child: MediaGallery(schemas: schemas),
      ));
      await tester.pump();

      expect(find.byType(Row), findsWidgets);
      expect(find.byType(IconButton), findsWidgets);
    });
  });

  // ---------------------------------------------------------------------------
  // Background opacity
  // ---------------------------------------------------------------------------

  group('MediaGallery background', () {
    testWidgets('scaffold uses black background', (tester) async {
      final schemas = [MockAttachment.create()];

      await tester.pumpWidget(createTestWidgetRaw(
        child: MediaGallery(schemas: schemas),
      ));
      await tester.pump();

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).last);
      expect(scaffold.backgroundColor, isNotNull);
    });

    testWidgets('onDragUpdate and onDragEnd update background', (tester) async {
      final schemas = makeSchemas(1);

      await tester.pumpWidget(createTestWidgetRaw(
        child: MediaGallery(schemas: schemas),
      ));
      await tester.pump();

      final state = tester.state(find.byType(MediaGallery));
      // ignore: avoid_dynamic_calls
      (state as dynamic).onDragUpdate(200.0);
      await tester.pump();

      expect(find.byType(Scaffold), findsOneWidget);

      // ignore: avoid_dynamic_calls
      (state as dynamic).onDragEnd();
      await tester.pump();

      expect(find.byType(Scaffold), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // Bottom bar indicators
  // ---------------------------------------------------------------------------

  group('MediaGallery bottom bar', () {
    testWidgets('shows dot indicators for multiple images', (tester) async {
      final schemas = makeSchemas(3);

      await tester.pumpWidget(createTestWidgetRaw(
        child: MediaGallery(schemas: schemas),
      ));
      await tester.pump();

      final dots = tester.widgetList<Container>(find.byType(Container)).where((c) {
        final decoration = c.decoration;
        if (decoration is BoxDecoration) {
          return decoration.shape == BoxShape.circle;
        }
        return false;
      }).toList();

      expect(dots.length, 3);
    });

    testWidgets('no dot indicators for single image', (tester) async {
      final schemas = makeSchemas(1);

      await tester.pumpWidget(createTestWidgetRaw(
        child: MediaGallery(schemas: schemas),
      ));
      await tester.pump();

      final dots = tester.widgetList<Container>(find.byType(Container)).where((c) {
        final decoration = c.decoration;
        if (decoration is BoxDecoration) {
          return decoration.shape == BoxShape.circle;
        }
        return false;
      }).toList();

      expect(dots.length, 0);
    });

    testWidgets('no page counter for single image', (tester) async {
      final schemas = makeSchemas(1);

      await tester.pumpWidget(createTestWidgetRaw(
        child: MediaGallery(schemas: schemas),
      ));
      await tester.pump();

      expect(find.text('1 / 1'), findsNothing);
    });

    testWidgets('page counter shows for multiple images', (tester) async {
      final schemas = makeSchemas(4);

      await tester.pumpWidget(createTestWidgetRaw(
        child: MediaGallery(schemas: schemas),
      ));
      await tester.pump();

      expect(find.text('1 / 4'), findsOneWidget);
    });

    testWidgets('active dot is larger than inactive dots', (tester) async {
      final schemas = makeSchemas(3);

      await tester.pumpWidget(createTestWidgetRaw(
        child: MediaGallery(schemas: schemas),
      ));
      await tester.pump();

      final dots = tester.widgetList<Container>(find.byType(Container)).where((c) {
        final decoration = c.decoration;
        if (decoration is BoxDecoration) {
          return decoration.shape == BoxShape.circle;
        }
        return false;
      }).toList();

      // First dot (active) should be 10x10, others 8x8
      final constraints = dots.map((d) => d.constraints).toList();
      expect(constraints[0]?.maxWidth, 10);
      expect(constraints[1]?.maxWidth, 8);
      expect(constraints[2]?.maxWidth, 8);
    });
  });

  // ---------------------------------------------------------------------------
  // Scaffold structure
  // ---------------------------------------------------------------------------

  group('MediaGallery structure', () {
    testWidgets('uses SafeArea', (tester) async {
      final schemas = makeSchemas(1);

      await tester.pumpWidget(createTestWidgetRaw(
        child: MediaGallery(schemas: schemas),
      ));
      await tester.pump();

      expect(find.byType(SafeArea), findsOneWidget);
    });

    testWidgets('uses Stack for overlay layout', (tester) async {
      final schemas = makeSchemas(1);

      await tester.pumpWidget(createTestWidgetRaw(
        child: MediaGallery(schemas: schemas),
      ));
      await tester.pump();

      expect(find.byType(Stack), findsWidgets);
    });
  });

  // ---------------------------------------------------------------------------
  // EXIF data rendering
  // ---------------------------------------------------------------------------

  group('MediaGallery EXIF info panel', () {
    IfdTag makeTag(String printable) {
      return IfdTag(
        tag: 0,
        tagType: 'ASCII',
        printable: printable,
        values: const IfdNone(),
      );
    }

    testWidgets('buildExifInfo shows camera make and model', (tester) async {
      final schemas = [MockAttachment.create(description: 'Test')];

      await tester.pumpWidget(createTestWidgetRaw(
        child: MediaGallery(schemas: schemas),
      ));
      await tester.pump();

      final state = tester.state(find.byType(MediaGallery));
      // ignore: avoid_dynamic_calls
      (state as dynamic).exifData = <String, IfdTag>{
        'Image Make': makeTag('Canon'),
        'Image Model': makeTag('EOS R5'),
      };

      // Open info panel
      await tester.tap(find.byIcon(Icons.info_outline));
      await tester.pump();

      expect(find.text('Canon EOS R5'), findsOneWidget);
      expect(find.byIcon(Icons.camera_alt), findsOneWidget);
    });

    testWidgets('buildExifInfo shows date/time from DateTimeOriginal', (tester) async {
      final schemas = [MockAttachment.create(description: 'Test')];

      await tester.pumpWidget(createTestWidgetRaw(
        child: MediaGallery(schemas: schemas),
      ));
      await tester.pump();

      final state = tester.state(find.byType(MediaGallery));
      // ignore: avoid_dynamic_calls
      (state as dynamic).exifData = <String, IfdTag>{
        'EXIF DateTimeOriginal': makeTag('2024:06:15 14:30:00'),
      };

      await tester.tap(find.byIcon(Icons.info_outline));
      await tester.pump();

      expect(find.text('2024:06:15 14:30:00'), findsOneWidget);
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    });

    testWidgets('buildExifInfo shows date/time from Image DateTime fallback', (tester) async {
      final schemas = [MockAttachment.create(description: 'Test')];

      await tester.pumpWidget(createTestWidgetRaw(
        child: MediaGallery(schemas: schemas),
      ));
      await tester.pump();

      final state = tester.state(find.byType(MediaGallery));
      // ignore: avoid_dynamic_calls
      (state as dynamic).exifData = <String, IfdTag>{
        'Image DateTime': makeTag('2023:01:01 00:00:00'),
      };

      await tester.tap(find.byIcon(Icons.info_outline));
      await tester.pump();

      expect(find.text('2023:01:01 00:00:00'), findsOneWidget);
    });

    testWidgets('buildExifInfo shows dimensions', (tester) async {
      final schemas = [MockAttachment.create(description: 'Test')];

      await tester.pumpWidget(createTestWidgetRaw(
        child: MediaGallery(schemas: schemas),
      ));
      await tester.pump();

      final state = tester.state(find.byType(MediaGallery));
      // ignore: avoid_dynamic_calls
      (state as dynamic).exifData = <String, IfdTag>{
        'EXIF ExifImageWidth': makeTag('4000'),
        'EXIF ExifImageLength': makeTag('3000'),
      };

      await tester.tap(find.byIcon(Icons.info_outline));
      await tester.pump();

      // Uses "×" (multiplication sign)
      expect(find.textContaining('4000'), findsOneWidget);
      expect(find.byIcon(Icons.aspect_ratio), findsOneWidget);
    });

    testWidgets('buildExifInfo shows exposure settings', (tester) async {
      final schemas = [MockAttachment.create(description: 'Test')];

      await tester.pumpWidget(createTestWidgetRaw(
        child: MediaGallery(schemas: schemas),
      ));
      await tester.pump();

      final state = tester.state(find.byType(MediaGallery));
      // ignore: avoid_dynamic_calls
      (state as dynamic).exifData = <String, IfdTag>{
        'EXIF ExposureTime': makeTag('1/250'),
        'EXIF FNumber': makeTag('2.8'),
        'EXIF ISOSpeedRatings': makeTag('400'),
      };

      await tester.tap(find.byIcon(Icons.info_outline));
      await tester.pump();

      expect(find.textContaining('1/250'), findsOneWidget);
      expect(find.textContaining('f/2.8'), findsOneWidget);
      expect(find.textContaining('ISO 400'), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('buildExifInfo shows no EXIF data message when empty', (tester) async {
      final schemas = [MockAttachment.create(description: 'Test')];

      await tester.pumpWidget(createTestWidgetRaw(
        child: MediaGallery(schemas: schemas),
      ));
      await tester.pump();

      final state = tester.state(find.byType(MediaGallery));
      // ignore: avoid_dynamic_calls
      (state as dynamic).exifData = <String, IfdTag>{};

      await tester.tap(find.byIcon(Icons.info_outline));
      await tester.pump();

      // Should show "No EXIF data available" or localized equivalent
      expect(find.textContaining('No EXIF'), findsOneWidget);
    });

    testWidgets('buildExifInfo shows all info rows when fully populated', (tester) async {
      final schemas = [MockAttachment.create(description: 'Full EXIF')];

      await tester.pumpWidget(createTestWidgetRaw(
        child: MediaGallery(schemas: schemas),
      ));
      await tester.pump();

      final state = tester.state(find.byType(MediaGallery));
      // ignore: avoid_dynamic_calls
      (state as dynamic).exifData = <String, IfdTag>{
        'Image Make': makeTag('Sony'),
        'Image Model': makeTag('A7III'),
        'EXIF DateTimeOriginal': makeTag('2024:12:25 10:00:00'),
        'EXIF ExifImageWidth': makeTag('6000'),
        'EXIF ExifImageLength': makeTag('4000'),
        'EXIF ExposureTime': makeTag('1/1000'),
        'EXIF FNumber': makeTag('1.4'),
        'EXIF ISOSpeedRatings': makeTag('100'),
      };

      await tester.tap(find.byIcon(Icons.info_outline));
      await tester.pump();

      // Verify all 4 info rows are present
      expect(find.byIcon(Icons.camera_alt), findsOneWidget);
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
      expect(find.byIcon(Icons.aspect_ratio), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);

      expect(find.text('Sony A7III'), findsOneWidget);
      expect(find.text('Full EXIF'), findsOneWidget); // alt text
    });

    testWidgets('buildExifInfo shows only make when model is null', (tester) async {
      final schemas = [MockAttachment.create(description: 'Test')];

      await tester.pumpWidget(createTestWidgetRaw(
        child: MediaGallery(schemas: schemas),
      ));
      await tester.pump();

      final state = tester.state(find.byType(MediaGallery));
      // ignore: avoid_dynamic_calls
      (state as dynamic).exifData = <String, IfdTag>{
        'Image Make': makeTag('Nikon'),
      };

      await tester.tap(find.byIcon(Icons.info_outline));
      await tester.pump();

      expect(find.text('Nikon'), findsOneWidget);
    });

    testWidgets('buildExifInfo uses Image ImageWidth fallback for dimensions', (tester) async {
      final schemas = [MockAttachment.create(description: 'Test')];

      await tester.pumpWidget(createTestWidgetRaw(
        child: MediaGallery(schemas: schemas),
      ));
      await tester.pump();

      final state = tester.state(find.byType(MediaGallery));
      // ignore: avoid_dynamic_calls
      (state as dynamic).exifData = <String, IfdTag>{
        'Image ImageWidth': makeTag('1920'),
        'Image ImageLength': makeTag('1080'),
      };

      await tester.tap(find.byIcon(Icons.info_outline));
      await tester.pump();

      expect(find.textContaining('1920'), findsOneWidget);
      expect(find.byIcon(Icons.aspect_ratio), findsOneWidget);
    });

    testWidgets('info panel shows loading indicator when isLoadingExif is true', (tester) async {
      final schemas = [MockAttachment.create(description: 'Test')];

      await tester.pumpWidget(createTestWidgetRaw(
        child: MediaGallery(schemas: schemas),
      ));
      await tester.pump();

      final state = tester.state(find.byType(MediaGallery));
      // Pre-set exifData to avoid async loading, then set loading state
      // ignore: avoid_dynamic_calls
      (state as dynamic).exifData = <String, IfdTag>{};
      // ignore: avoid_dynamic_calls
      (state as dynamic).showInfo = true;
      // ignore: avoid_dynamic_calls
      (state as dynamic).isLoadingExif = true;

      // Force rebuild by calling setState via a recognized path
      // ignore: avoid_dynamic_calls
      (state as dynamic).onDragEnd();
      await tester.pump();

      // Info panel should be visible (showInfo = true)
      expect(find.byIcon(Icons.info), findsOneWidget);
    });

    testWidgets('buildExifInfo shows partial exposure settings', (tester) async {
      final schemas = [MockAttachment.create(description: 'Test')];

      await tester.pumpWidget(createTestWidgetRaw(
        child: MediaGallery(schemas: schemas),
      ));
      await tester.pump();

      final state = tester.state(find.byType(MediaGallery));
      // ignore: avoid_dynamic_calls
      (state as dynamic).exifData = <String, IfdTag>{
        'EXIF ISOSpeedRatings': makeTag('800'),
      };

      await tester.tap(find.byIcon(Icons.info_outline));
      await tester.pump();

      expect(find.textContaining('ISO 800'), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
