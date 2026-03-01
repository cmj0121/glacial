// Widget tests for Application component.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/features/models.dart';
import 'package:glacial/features/timeline/screens/application.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  setUpAll(() => setupTestEnvironment());

  group('Application', () {
    group('when null schema', () {
      testWidgets('returns SizedBox.shrink', (tester) async {
        await tester.pumpWidget(createTestWidget(
          child: const Application(schema: null),
        ));
        await tester.pumpAndSettle();

        expect(find.byType(Application), findsOneWidget);
        // SizedBox.shrink is rendered
        final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
        expect(sizedBox.width, 0.0);
        expect(sizedBox.height, 0.0);
      });
    });

    group('when schema provided', () {
      testWidgets('shows application name', (tester) async {
        const schema = ApplicationSchema(name: 'Glacial', website: 'https://glacial.app');

        await tester.pumpWidget(createTestWidget(
          child: const Application(schema: schema),
        ));
        await tester.pumpAndSettle();

        expect(find.text('Glacial'), findsOneWidget);
      });

      testWidgets('applies custom size', (tester) async {
        const schema = ApplicationSchema(name: 'TestApp');

        await tester.pumpWidget(createTestWidget(
          child: const Application(schema: schema, size: 14),
        ));
        await tester.pumpAndSettle();

        final text = tester.widget<Text>(find.text('TestApp'));
        expect(text.style?.fontSize, 14);
      });

      testWidgets('aligns to the right', (tester) async {
        const schema = ApplicationSchema(name: 'Glacial');

        await tester.pumpWidget(createTestWidget(
          child: const Application(schema: schema),
        ));
        await tester.pumpAndSettle();

        final align = tester.widget<Align>(find.byType(Align).first);
        expect(align.alignment, Alignment.centerRight);
      });

      testWidgets('wraps in InkWell', (tester) async {
        const schema = ApplicationSchema(name: 'Glacial', website: 'https://glacial.app');

        await tester.pumpWidget(createTestWidget(
          child: const Application(schema: schema),
        ));
        await tester.pumpAndSettle();

        expect(find.byType(InkWell), findsOneWidget);
      });

      testWidgets('InkWell has onTap when website is provided', (tester) async {
        const schema = ApplicationSchema(name: 'WebApp', website: 'https://example.com');
        await tester.pumpWidget(createTestWidget(
          child: const Application(schema: schema),
        ));
        await tester.pumpAndSettle();

        final InkWell inkWell = tester.widget<InkWell>(find.byType(InkWell));
        expect(inkWell.onTap, isNotNull);
      });

      testWidgets('InkWell has null onTap when website is null', (tester) async {
        const schema = ApplicationSchema(name: 'NoWebApp');
        await tester.pumpWidget(createTestWidget(
          child: const Application(schema: schema),
        ));
        await tester.pumpAndSettle();

        final InkWell inkWell = tester.widget<InkWell>(find.byType(InkWell));
        expect(inkWell.onTap, isNull);
      });

      testWidgets('tapping InkWell triggers url launch', (tester) async {
        // Mock the url_launcher platform channel
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/url_launcher_macos'),
          (MethodCall methodCall) async => true,
        );
        addTearDown(() {
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/url_launcher_macos'),
            null,
          );
        });

        const schema = ApplicationSchema(name: 'WebApp', website: 'https://example.com');
        await tester.pumpWidget(createTestWidget(
          child: const Application(schema: schema),
        ));
        await tester.pumpAndSettle();

        // Tap the InkWell to trigger the onTap callback
        await tester.tap(find.byType(InkWell));
        await tester.pump();

        // The tap triggers the launchUrl call — no error expected
        expect(find.byType(Application), findsOneWidget);
      });
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
