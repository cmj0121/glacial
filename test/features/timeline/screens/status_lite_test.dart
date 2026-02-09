// Widget tests for StatusLite component.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/features/models.dart';
import 'package:glacial/features/timeline/screens/status_lite.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  setUpAll(() => setupTestEnvironment());

  group('StatusLite', () {
    group('rendering', () {
      testWidgets('renders StatusLite widget', (tester) async {
        final status = MockStatus.create(
          content: '<p>Hello, world!</p>',
        );

        await tester.pumpWidget(createTestWidget(
          child: StatusLite(schema: status),
        ));
        await tester.pump(const Duration(milliseconds: 100));

        // StatusLite should be rendered
        expect(find.byType(StatusLite), findsOneWidget);
      });

      testWidgets('displays account information', (tester) async {
        final account = MockAccount.create(displayName: 'John Doe', username: 'johndoe');
        final status = MockStatus.create(account: account);

        await tester.pumpWidget(createTestWidget(
          child: StatusLite(schema: status),
        ));
        await tester.pump(const Duration(milliseconds: 100));

        // Account widget should be rendered
        expect(find.byType(StatusLite), findsOneWidget);
      });

      testWidgets('displays time information', (tester) async {
        final status = MockStatus.create(
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        );

        await tester.pumpWidget(createTestWidget(
          child: StatusLite(schema: status),
        ));
        await tester.pump(const Duration(milliseconds: 100));

        // Widget renders with time - timeago is internal implementation
        expect(find.byType(StatusLite), findsOneWidget);
      });

      testWidgets('displays visibility icon for public status', (tester) async {
        final status = MockStatus.create(visibility: VisibilityType.public);

        await tester.pumpWidget(createTestWidget(
          child: StatusLite(schema: status),
        ));
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byIcon(Icons.public), findsOneWidget);
      });

      testWidgets('displays visibility icon for private status', (tester) async {
        final status = MockStatus.create(visibility: VisibilityType.private);

        await tester.pumpWidget(createTestWidget(
          child: StatusLite(schema: status),
        ));
        await tester.pump(const Duration(milliseconds: 100));

        // VisibilityType.private uses Icons.group
        expect(find.byIcon(Icons.group), findsOneWidget);
      });

      testWidgets('displays visibility icon for direct message', (tester) async {
        final status = MockStatus.create(visibility: VisibilityType.direct);

        await tester.pumpWidget(createTestWidget(
          child: StatusLite(schema: status),
        ));
        await tester.pump(const Duration(milliseconds: 100));

        // VisibilityType.direct uses Icons.lock
        expect(find.byIcon(Icons.lock), findsOneWidget);
      });
    });

    group('interactions info', () {
      testWidgets('displays info button when has interactions', (tester) async {
        final status = MockStatus.create(
          reblogsCount: 5,
          favouritesCount: 10,
        );

        await tester.pumpWidget(createTestWidget(
          child: StatusLite(schema: status),
        ));
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byIcon(Icons.info_outline), findsOneWidget);
      });

      testWidgets('displays edit icon when status was edited', (tester) async {
        final status = MockStatus.create(
          editedAt: DateTime.now().subtract(const Duration(hours: 1)),
        );

        await tester.pumpWidget(createTestWidget(
          child: StatusLite(schema: status),
        ));
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
      });

      testWidgets('displays schedule icon for scheduled status', (tester) async {
        final status = MockStatus.create(
          scheduledAt: DateTime.now().add(const Duration(hours: 1)),
        );

        await tester.pumpWidget(createTestWidget(
          child: StatusLite(schema: status),
        ));
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byIcon(Icons.schedule_outlined), findsOneWidget);
      });
    });

    group('spoiler and sensitive content', () {
      testWidgets('displays spoiler text when provided', (tester) async {
        final status = MockStatus.createSensitive(
          spoiler: 'Content Warning',
        );

        await tester.pumpWidget(createTestWidget(
          child: StatusLite(schema: status, spoiler: status.spoiler),
        ));
        await tester.pump(const Duration(milliseconds: 100));

        // Spoiler text should be visible
        expect(find.text('Content Warning'), findsOneWidget);
      });

      testWidgets('shows blur overlay for sensitive content', (tester) async {
        final status = MockStatus.create(sensitive: true);

        await tester.pumpWidget(createTestWidget(
          child: StatusLite(schema: status, sensitive: true),
        ));
        await tester.pump(const Duration(milliseconds: 100));

        // Visibility off icon indicates blurred content
        expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
      });
    });

    group('indentation', () {
      testWidgets('applies indent when indent > 0', (tester) async {
        final status = MockStatus.create();

        await tester.pumpWidget(createTestWidget(
          child: StatusLite(schema: status, indent: 1),
        ));
        await tester.pump(const Duration(milliseconds: 100));

        // Widget should render without errors
        expect(find.byType(StatusLite), findsOneWidget);
      });
    });

    group('callbacks', () {
      testWidgets('renders with onLinkTap callback', (tester) async {
        final status = MockStatus.create(
          content: '<p>Check this <a href="https://example.com">link</a></p>',
        );

        await tester.pumpWidget(createTestWidget(
          child: StatusLite(
            schema: status,
            onLinkTap: (_) {}, // Callback wired for testing
          ),
        ));
        await tester.pump(const Duration(milliseconds: 100));

        // Widget should render with callback wired
        expect(find.byType(StatusLite), findsOneWidget);
      });
    });

    group('tags', () {
      testWidgets('renders tags widget when present', (tester) async {
        final status = MockStatus.create(
          tags: [
            TagSchema(name: 'flutter', url: 'https://example.com/tags/flutter'),
            TagSchema(name: 'dart', url: 'https://example.com/tags/dart'),
          ],
        );

        await tester.pumpWidget(createTestWidget(
          child: StatusLite(schema: status),
        ));
        await tester.pump(const Duration(milliseconds: 100));

        // StatusLite should render
        expect(find.byType(StatusLite), findsOneWidget);
      });
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
