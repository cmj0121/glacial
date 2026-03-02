// Widget tests for Attachments component.
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:glacial/features/timeline/models/core.dart';
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

    testWidgets('shows CachedNetworkImage for gifv type', (tester) async {
      final attachment = MockAttachment.create(type: MediaType.gifv);

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: wrapAttachment(attachment),
        ));
        await tester.pump();
      });

      expect(find.byType(Attachment), findsOneWidget);
      expect(find.byType(CachedNetworkImage), findsOneWidget);
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

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: wrapAttachment(attachment),
        ));
        await tester.pump();
      });

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

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: SizedBox(
            width: 300,
            height: 300,
            child: MediaPlayer(url: url),
          ),
        ));
        await tester.pump();
      });

      expect(find.byType(MediaPlayer), findsOneWidget);
    });

    testWidgets('renders with cover widget', (tester) async {
      final url = Uri.parse('https://example.com/media/audio.mp3');
      const cover = Icon(Icons.music_note_rounded, size: 64);

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: SizedBox(
            width: 300,
            height: 300,
            child: MediaPlayer(url: url, cover: cover),
          ),
        ));
        await tester.pump();
      });

      expect(find.byType(MediaPlayer), findsOneWidget);
      expect(find.byIcon(Icons.music_note_rounded), findsOneWidget);
    });

    testWidgets('shows shimmer while loading', (tester) async {
      final url = Uri.parse('https://example.com/media/video.mp4');

      // Pump without runAsync so the FutureBuilder stays in waiting state.
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
  });
}

// vim: set ts=2 sw=2 sts=2 et:
