import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/cores/screens/animations.dart';
import 'package:glacial/cores/screens/blurhash_placeholder.dart';

import '../../helpers/test_helpers.dart';

void main() {
  setupTestEnvironment();

  group('BlurhashPlaceholder', () {
    testWidgets('valid blurhash shows BlurHash widget', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const SizedBox(
          width: 200,
          height: 200,
          child: BlurhashPlaceholder(blurhash: 'LEHV6nWB2yk8pyo0adR*.7kCMdnj'),
        ),
      ));
      await tester.pump();

      expect(find.byType(BlurHash), findsOneWidget);
      expect(find.byType(ClockProgressIndicator), findsNothing);
    });

    testWidgets('null blurhash falls back to ClockProgressIndicator', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const SizedBox(
          width: 200,
          height: 200,
          child: BlurhashPlaceholder(blurhash: null),
        ),
      ));
      await tester.pump();

      expect(find.byType(ClockProgressIndicator), findsOneWidget);
      expect(find.byType(BlurHash), findsNothing);
    });

    testWidgets('short blurhash (< 6 chars) falls back to ClockProgressIndicator', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const SizedBox(
          width: 200,
          height: 200,
          child: BlurhashPlaceholder(blurhash: 'abc'),
        ),
      ));
      await tester.pump();

      expect(find.byType(ClockProgressIndicator), findsOneWidget);
      expect(find.byType(BlurHash), findsNothing);
    });

    testWidgets('custom fit parameter passed through', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const SizedBox(
          width: 200,
          height: 200,
          child: BlurhashPlaceholder(
            blurhash: 'LEHV6nWB2yk8pyo0adR*.7kCMdnj',
            fit: BoxFit.contain,
          ),
        ),
      ));
      await tester.pump();

      final BlurHash blurHash = tester.widget(find.byType(BlurHash));
      expect(blurHash.imageFit, BoxFit.contain);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
