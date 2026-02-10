// Widget tests for Attachments component.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/features/timeline/screens/attachment.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  setUpAll(() => setupTestEnvironment());

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
}

// vim: set ts=2 sw=2 sts=2 et:
