// Widget tests for Attachments component.
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:glacial/features/models.dart';
import 'package:glacial/features/timeline/screens/attachment.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  setUpAll(() {
    setupTestEnvironment();
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async => Directory.systemTemp.path,
    );
  });

  group('Attachments', () {
    group('when empty list', () {
      testWidgets('returns SizedBox.shrink', (tester) async {
        await tester.pumpWidget(createTestWidget(
          child: const Attachments(schemas: []),
        ));
        await tester.pump();

        expect(find.byType(Attachments), findsOneWidget);
        final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
        expect(sizedBox.width, 0.0);
        expect(sizedBox.height, 0.0);
      });
    });

    group('when attachments provided', () {
      testWidgets('single attachment renders', (tester) async {
        final attachment = MockAttachment.create();

        await tester.pumpWidget(createTestWidget(
          child: Attachments(schemas: [attachment]),
        ));
        await tester.pump();

        expect(find.byType(Attachments), findsOneWidget);
        expect(find.byType(Attachment), findsOneWidget);
      });

      testWidgets('multiple attachments render in Row', (tester) async {
        final attachments = [
          MockAttachment.create(id: 'att-1'),
          MockAttachment.create(id: 'att-2'),
        ];

        await tester.pumpWidget(createTestWidget(
          child: Attachments(schemas: attachments),
        ));
        await tester.pump();

        expect(find.byType(Attachments), findsOneWidget);
        expect(find.byType(Row), findsWidgets);
        expect(find.byType(Expanded), findsNWidgets(2));
      });

      testWidgets('three attachments render three Expanded children', (tester) async {
        final attachments = [
          MockAttachment.create(id: 'att-1'),
          MockAttachment.create(id: 'att-2'),
          MockAttachment.create(id: 'att-3'),
        ];

        await tester.pumpWidget(createTestWidget(
          child: Attachments(schemas: attachments),
        ));
        await tester.pump();

        expect(find.byType(Expanded), findsNWidgets(3));
      });
    });

    group('constraints', () {
      testWidgets('uses ConstrainedBox with default maxHeight', (tester) async {
        final attachment = MockAttachment.create();

        await tester.pumpWidget(createTestWidget(
          child: Attachments(schemas: [attachment]),
        ));
        await tester.pump();

        final finder = find.descendant(
          of: find.byType(Attachments),
          matching: find.byType(ConstrainedBox),
        );
        final constrained = tester.widget<ConstrainedBox>(finder.first);
        expect(constrained.constraints.maxHeight, 400);
      });

      testWidgets('uses custom maxHeight', (tester) async {
        final attachment = MockAttachment.create();

        await tester.pumpWidget(createTestWidget(
          child: Attachments(schemas: [attachment], maxHeight: 200),
        ));
        await tester.pump();

        final finder = find.descendant(
          of: find.byType(Attachments),
          matching: find.byType(ConstrainedBox),
        );
        final constrained = tester.widget<ConstrainedBox>(finder.first);
        expect(constrained.constraints.maxHeight, 200);
      });
    });
  });

  group('Attachment', () {
    // Wrap Attachment in a SizedBox to provide bounded constraints
    // since OverflowBox needs a bounded parent.
    Widget wrapAttachment(AttachmentSchema schema) {
      return SizedBox(
        width: 300,
        height: 300,
        child: Attachment(schema: schema),
      );
    }

    testWidgets('shows CachedNetworkImage for image type', (tester) async {
      final attachment = MockAttachment.create(type: MediaType.image);

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: wrapAttachment(attachment),
        ));
        await tester.pump();
      });

      expect(find.byType(Attachment), findsOneWidget);
      expect(find.byType(CachedNetworkImage), findsOneWidget);
    });

    testWidgets('shows MediaPlayer for gifv type (looping MP4)', (tester) async {
      final attachment = MockAttachment.create(
        type: MediaType.gifv,
        url: 'https://example.com/media/anim.mp4',
      );

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: wrapAttachment(attachment),
        ));
        await tester.pump();
      });

      expect(find.byType(Attachment), findsOneWidget);
      expect(find.byType(MediaPlayer), findsOneWidget);
    });

    testWidgets('shows MediaPlayer for video type', (tester) async {
      final attachment = MockAttachment.create(
        type: MediaType.video,
        url: 'https://example.com/media/video.mp4',
      );

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: wrapAttachment(attachment),
        ));
        await tester.pump();
      });

      expect(find.byType(Attachment), findsOneWidget);
      expect(find.byType(MediaPlayer), findsOneWidget);
    });

    testWidgets('shows MediaPlayer with music icon for audio type', (tester) async {
      final attachment = MockAttachment.create(
        type: MediaType.audio,
        url: 'https://example.com/media/audio.mp3',
      );

      // No runAsync/pump so MediaPlayer stays in loading state showing cover.
      await tester.pumpWidget(createTestWidget(
        child: wrapAttachment(attachment),
      ));

      expect(find.byType(Attachment), findsOneWidget);
      expect(find.byType(MediaPlayer), findsOneWidget);
      expect(find.byIcon(Icons.music_note_rounded), findsOneWidget);
    });

    testWidgets('shows SizedBox.shrink for unknown type', (tester) async {
      final attachment = MockAttachment.create(type: MediaType.unknown);

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: wrapAttachment(attachment),
        ));
        await tester.pump();
      });

      expect(find.byType(Attachment), findsOneWidget);
      // The unknown type should render SizedBox.shrink inside the Attachment
      final sizedBoxFinder = find.descendant(
        of: find.byType(Attachment),
        matching: find.byType(SizedBox),
      );
      expect(sizedBoxFinder, findsWidgets);
    });

    testWidgets('uses ClipRRect wrapper', (tester) async {
      final attachment = MockAttachment.create();

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: wrapAttachment(attachment),
        ));
        await tester.pump();
      });

      final clipFinder = find.descendant(
        of: find.byType(Attachment),
        matching: find.byType(ClipRRect),
      );
      expect(clipFinder, findsOneWidget);
    });

    testWidgets('uses OverflowBox wrapper', (tester) async {
      final attachment = MockAttachment.create();

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: wrapAttachment(attachment),
        ));
        await tester.pump();
      });

      final overflowFinder = find.descendant(
        of: find.byType(Attachment),
        matching: find.byType(OverflowBox),
      );
      expect(overflowFinder, findsOneWidget);
    });
  });

  group('MediaPlayer', () {
    testWidgets('renders with url', (tester) async {
      final url = Uri.parse('https://example.com/media/video.mp4');

      await tester.pumpWidget(createTestWidget(
        child: SizedBox(
          width: 300,
          height: 300,
          child: MediaPlayer(url: url),
        ),
      ));
      await tester.pump();

      expect(find.byType(MediaPlayer), findsOneWidget);
    });

    testWidgets('renders with cover widget in loading state', (tester) async {
      final url = Uri.parse('https://example.com/media/audio.mp3');
      const cover = Icon(Icons.music_note_rounded, size: 64);

      // No pump() after pumpWidget so controller stays in loading state.
      await tester.pumpWidget(createTestWidget(
        child: SizedBox(
          width: 300,
          height: 300,
          child: MediaPlayer(url: url, cover: cover),
        ),
      ));

      expect(find.byType(MediaPlayer), findsOneWidget);
      expect(find.byIcon(Icons.music_note_rounded), findsOneWidget);
    });

    testWidgets('shows shimmer while loading without previewUrl', (tester) async {
      final url = Uri.parse('https://example.com/media/video.mp4');

      // Pump without runAsync so the controller stays in init state.
      await tester.pumpWidget(createTestWidget(
        child: SizedBox(
          width: 300,
          height: 300,
          child: MediaPlayer(url: url),
        ),
      ));

      // While the video controller initializes, a loading shimmer is shown.
      expect(find.byType(MediaPlayer), findsOneWidget);
      // The loading state renders a 50x50 SizedBox
      final sizedBoxFinder = find.descendant(
        of: find.byType(MediaPlayer),
        matching: find.byWidgetPredicate((w) =>
          w is SizedBox && w.width == 50 && w.height == 50,
        ),
      );
      expect(sizedBoxFinder, findsOneWidget);
    });

    testWidgets('shows preview image while loading when previewUrl provided', (tester) async {
      final url = Uri.parse('https://example.com/media/video.mp4');

      // Pump without runAsync so the controller stays in init state.
      await tester.pumpWidget(createTestWidget(
        child: SizedBox(
          width: 300,
          height: 300,
          child: MediaPlayer(
            url: url,
            previewUrl: 'https://example.com/media/preview.png',
          ),
        ),
      ));

      expect(find.byType(MediaPlayer), findsOneWidget);
      // Should show CachedNetworkImage for the preview and CircularProgressIndicator
      expect(find.byType(CachedNetworkImage), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('accepts autoPlay parameter', (tester) async {
      final url = Uri.parse('https://example.com/media/video.mp4');

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: SizedBox(
            width: 300,
            height: 300,
            child: MediaPlayer(url: url, autoPlay: true),
          ),
        ));
        await tester.pump();
      });

      expect(find.byType(MediaPlayer), findsOneWidget);
    });

    testWidgets('accepts showControls parameter', (tester) async {
      final url = Uri.parse('https://example.com/media/video.mp4');

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: SizedBox(
            width: 300,
            height: 300,
            child: MediaPlayer(url: url, showControls: false),
          ),
        ));
        await tester.pump();
      });

      expect(find.byType(MediaPlayer), findsOneWidget);
    });

    test('MediaPlayer has correct default parameter values', () {
      final url = Uri.parse('https://example.com/media/video.mp4');
      final player = MediaPlayer(url: url);
      expect(player.autoPlay, false);
      expect(player.showControls, true);
      expect(player.cover, isNull);
      expect(player.previewUrl, isNull);
      expect(player.blurhash, isNull);
    });

    testWidgets('shows error UI when initialization fails', (tester) async {
      final url = Uri.parse('https://example.com/media/video.mp4');

      // Use pump() to allow initialize() to fail and trigger error state.
      await tester.pumpWidget(createTestWidget(
        child: SizedBox(
          width: 300,
          height: 300,
          child: MediaPlayer(url: url),
        ),
      ));
      await tester.pump();

      expect(find.byType(MediaPlayer), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
      expect(find.text('Video failed to load'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('retry button re-initializes the controller', (tester) async {
      final url = Uri.parse('https://example.com/media/video.mp4');

      await tester.pumpWidget(createTestWidget(
        child: SizedBox(
          width: 300,
          height: 300,
          child: MediaPlayer(url: url),
        ),
      ));
      await tester.pump();

      // Verify error state is showing
      expect(find.byIcon(Icons.error_outline), findsOneWidget);

      // Tap the retry button
      await tester.tap(find.text('Retry'));
      await tester.pump();

      // After retry, the controller re-initializes and fails again in tests.
      // The widget should still be present (either loading or error state).
      expect(find.byType(MediaPlayer), findsOneWidget);
    });
  });

  group('Attachment autoPlayVideo preference', () {
    Widget wrapAttachment(AttachmentSchema schema) {
      return SizedBox(
        width: 300,
        height: 300,
        child: Attachment(schema: schema),
      );
    }

    testWidgets('gifv uses autoPlay true when preference is true', (tester) async {
      final attachment = MockAttachment.create(
        type: MediaType.gifv,
        url: 'https://example.com/media/anim.mp4',
      );

      await tester.pumpWidget(createTestWidget(
        preference: const SystemPreferenceSchema(autoPlayVideo: true),
        child: wrapAttachment(attachment),
      ));

      // Find the MediaPlayer created by Attachment
      final mediaPlayer = tester.widget<MediaPlayer>(find.byType(MediaPlayer));
      expect(mediaPlayer.autoPlay, true);
    });

    testWidgets('gifv uses autoPlay false when preference is false', (tester) async {
      final attachment = MockAttachment.create(
        type: MediaType.gifv,
        url: 'https://example.com/media/anim.mp4',
      );

      await tester.pumpWidget(createTestWidget(
        preference: const SystemPreferenceSchema(autoPlayVideo: false),
        child: wrapAttachment(attachment),
      ));

      final mediaPlayer = tester.widget<MediaPlayer>(find.byType(MediaPlayer));
      expect(mediaPlayer.autoPlay, false);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
