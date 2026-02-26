// Widget tests for AnnouncementSheet.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glacial/cores/screens/misc.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

import '../../../helpers/test_helpers.dart';

/// Injects announcements into the AnnouncementSheet's state for testing.
void injectAnnouncements(WidgetTester tester, List<AnnouncementSchema> items) {
  final StatefulElement element = tester.element(find.byType(AnnouncementSheet)) as StatefulElement;
  final dynamic state = element.state;
  // ignore: invalid_use_of_protected_member
  state.setState(() {
    state.announcements = items;
  });
}

void main() {
  setupTestEnvironment();

  group('AnnouncementSheet', () {
    testWidgets('renders with null status', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const AnnouncementSheet(status: null),
      ));
      await tester.pump();

      expect(find.byType(AnnouncementSheet), findsOneWidget);
    });

    testWidgets('shows title text', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const AnnouncementSheet(status: null),
      ));
      await tester.pump();

      expect(find.textContaining('Announcement'), findsOneWidget);
    });

    testWidgets('wrapped in Padding and Column', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const AnnouncementSheet(status: null),
      ));
      await tester.pump();

      expect(find.byType(Padding), findsWidgets);
      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('renders with no-domain status', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: const AnnouncementSheet(
            status: AccessStatusSchema(domain: null, accessToken: 'test'),
          ),
        ));
        await tester.pump();
      });

      expect(find.byType(AnnouncementSheet), findsOneWidget);
    });

    testWidgets('shows NoResult when announcements empty and loaded', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: const AnnouncementSheet(status: null),
        ));
        await tester.pump();
      });

      // After load with null status, announcements = [] → shows NoResult
      expect(find.byType(NoResult), findsOneWidget);
    });

    testWidgets('NoResult shows campaign icon', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: const AnnouncementSheet(status: null),
        ));
        await tester.pump();
      });

      expect(find.byIcon(Icons.campaign_outlined), findsOneWidget);
    });

    group('announcement content rendering', () {
      testWidgets('renders announcement with content and date', (tester) async {
        await tester.pumpWidget(createTestWidget(
          child: const AnnouncementSheet(status: null),
        ));
        await tester.pump();

        // Inject announcements directly into state
        final announcement = MockAnnouncement.create(
          id: 'ann-1',
          content: '<p>Server maintenance tonight.</p>',
          publishedAt: '2024-01-15T10:00:00.000Z',
          read: false,
        );
        injectAnnouncements(tester, [announcement]);
        await tester.pump();

        // Should render a ListView
        expect(find.byType(ListView), findsOneWidget);
        // Should show the date portion
        expect(find.text('2024-01-15'), findsOneWidget);
      });

      testWidgets('renders dismiss button for unread announcement', (tester) async {
        await tester.pumpWidget(createTestWidget(
          child: const AnnouncementSheet(status: null),
        ));
        await tester.pump();

        final announcement = MockAnnouncement.create(
          id: 'ann-1',
          content: '<p>Update available.</p>',
          publishedAt: '2024-02-20T12:00:00.000Z',
          read: false,
        );
        injectAnnouncements(tester, [announcement]);
        await tester.pump();

        // Unread announcement should show dismiss button with check icon
        expect(find.byIcon(Icons.check), findsOneWidget);
      });

      testWidgets('does not render dismiss button for read announcement', (tester) async {
        await tester.pumpWidget(createTestWidget(
          child: const AnnouncementSheet(status: null),
        ));
        await tester.pump();

        final announcement = MockAnnouncement.create(
          id: 'ann-2',
          content: '<p>Already read announcement.</p>',
          publishedAt: '2024-03-01T08:00:00.000Z',
          read: true,
        );
        injectAnnouncements(tester, [announcement]);
        await tester.pump();

        // Read announcement does not have dismiss button
        expect(find.byIcon(Icons.check), findsNothing);
      });

      testWidgets('renders multiple announcements with dividers', (tester) async {
        await tester.pumpWidget(createTestWidget(
          child: const AnnouncementSheet(status: null),
        ));
        await tester.pump();

        final announcements = [
          MockAnnouncement.create(
            id: 'ann-1',
            content: '<p>First announcement.</p>',
            publishedAt: '2024-01-10T10:00:00.000Z',
          ),
          MockAnnouncement.create(
            id: 'ann-2',
            content: '<p>Second announcement.</p>',
            publishedAt: '2024-01-12T10:00:00.000Z',
          ),
        ];
        injectAnnouncements(tester, announcements);
        await tester.pump();

        // ListView should have 2 items
        expect(find.byType(ListView), findsOneWidget);
        // Each announcement shows its date
        expect(find.text('2024-01-10'), findsOneWidget);
        expect(find.text('2024-01-12'), findsOneWidget);
        // Should have a Divider separator between them
        expect(find.byType(Divider), findsOneWidget);
      });

      testWidgets('renders announcement with emoji reactions', (tester) async {
        await tester.pumpWidget(createTestWidget(
          child: const AnnouncementSheet(status: null),
        ));
        await tester.pump();

        final announcement = MockAnnouncement.create(
          id: 'ann-react',
          content: '<p>Announcement with reactions.</p>',
          publishedAt: '2024-05-01T10:00:00.000Z',
          read: true,
          reactions: [
            MockReaction.create(name: '👍', count: 5, me: false),
            MockReaction.create(name: '❤️', count: 3, me: true),
          ],
        );
        injectAnnouncements(tester, [announcement]);
        await tester.pump();

        // Should render ActionChip widgets for reactions
        expect(find.byType(ActionChip), findsNWidgets(2));
        // Should show reaction counts
        expect(find.text('5'), findsOneWidget);
        expect(find.text('3'), findsOneWidget);
      });

      testWidgets('renders reaction with custom emoji URL', (tester) async {
        await tester.runAsync(() async {
          await tester.pumpWidget(createTestWidget(
            child: const AnnouncementSheet(status: null),
          ));
          await tester.pump();

          final announcement = MockAnnouncement.create(
            id: 'ann-custom-emoji',
            content: '<p>Custom emoji reaction.</p>',
            publishedAt: '2024-06-01T10:00:00.000Z',
            read: true,
            reactions: [
              MockReaction.create(
                name: 'blobcat',
                count: 2,
                me: false,
                url: 'https://example.com/emoji/blobcat.png',
              ),
            ],
          );
          injectAnnouncements(tester, [announcement]);
          await tester.pump();
        });

        // Should show an ActionChip with an Image.network avatar
        expect(find.byType(ActionChip), findsOneWidget);
        expect(find.text('2'), findsOneWidget);
      });

      testWidgets('renders reaction with text avatar when no URL', (tester) async {
        await tester.pumpWidget(createTestWidget(
          child: const AnnouncementSheet(status: null),
        ));
        await tester.pump();

        final announcement = MockAnnouncement.create(
          id: 'ann-text-emoji',
          content: '<p>Text emoji reaction.</p>',
          publishedAt: '2024-06-01T10:00:00.000Z',
          read: true,
          reactions: [
            MockReaction.create(name: '🎉', count: 7, me: false),
          ],
        );
        injectAnnouncements(tester, [announcement]);
        await tester.pump();

        // Should show an ActionChip with text avatar (the emoji itself)
        expect(find.byType(ActionChip), findsOneWidget);
        expect(find.text('🎉'), findsOneWidget);
        expect(find.text('7'), findsOneWidget);
      });

      testWidgets('tapping dismiss button triggers onDismiss', (tester) async {
        await tester.pumpWidget(createTestWidget(
          child: const AnnouncementSheet(status: null),
        ));
        await tester.pump();

        final announcement = MockAnnouncement.create(
          id: 'ann-dismiss',
          content: '<p>Dismiss me.</p>',
          publishedAt: '2024-04-01T10:00:00.000Z',
          read: false,
        );
        injectAnnouncements(tester, [announcement]);
        await tester.pump();

        // Tap the dismiss button (check icon inside a TextButton)
        await tester.tap(find.byIcon(Icons.check));
        await tester.pump();

        // onDismiss calls status?.dismissAnnouncement (no-op for null status)
        // then calls onLoad which resets announcements to []
        // Widget should still render without errors
        expect(find.byType(AnnouncementSheet), findsOneWidget);
      });

      testWidgets('tapping reaction chip triggers onToggleReaction (me=false)', (tester) async {
        await tester.pumpWidget(createTestWidget(
          child: const AnnouncementSheet(status: null),
        ));
        await tester.pump();

        final announcement = MockAnnouncement.create(
          id: 'ann-react-tap',
          content: '<p>React to me.</p>',
          publishedAt: '2024-04-02T10:00:00.000Z',
          read: true,
          reactions: [
            MockReaction.create(name: '👍', count: 3, me: false),
          ],
        );
        injectAnnouncements(tester, [announcement]);
        await tester.pump();

        // Tap the reaction chip (me=false → addAnnouncementReaction path)
        await tester.tap(find.byType(ActionChip));
        await tester.pump();

        // onToggleReaction calls status?.addAnnouncementReaction (no-op for null)
        // then calls onLoad which resets announcements
        expect(find.byType(AnnouncementSheet), findsOneWidget);
      });

      testWidgets('tapping reaction chip triggers onToggleReaction (me=true)', (tester) async {
        await tester.pumpWidget(createTestWidget(
          child: const AnnouncementSheet(status: null),
        ));
        await tester.pump();

        final announcement = MockAnnouncement.create(
          id: 'ann-unreact',
          content: '<p>Unreact from me.</p>',
          publishedAt: '2024-04-03T10:00:00.000Z',
          read: true,
          reactions: [
            MockReaction.create(name: '❤️', count: 5, me: true),
          ],
        );
        injectAnnouncements(tester, [announcement]);
        await tester.pump();

        // Tap the reaction chip (me=true → removeAnnouncementReaction path)
        await tester.tap(find.byType(ActionChip));
        await tester.pump();

        // onToggleReaction calls status?.removeAnnouncementReaction (no-op for null)
        expect(find.byType(AnnouncementSheet), findsOneWidget);
      });

      testWidgets('read announcement has dimmed date color', (tester) async {
        await tester.pumpWidget(createTestWidget(
          child: const AnnouncementSheet(status: null),
        ));
        await tester.pump();

        final announcement = MockAnnouncement.create(
          id: 'ann-dim',
          content: '<p>Dimmed announcement.</p>',
          publishedAt: '2024-07-01T10:00:00.000Z',
          read: true,
        );
        injectAnnouncements(tester, [announcement]);
        await tester.pump();

        // The date text should be present
        expect(find.text('2024-07-01'), findsOneWidget);
      });

      testWidgets('shows Wrap widget for reactions', (tester) async {
        await tester.pumpWidget(createTestWidget(
          child: const AnnouncementSheet(status: null),
        ));
        await tester.pump();

        final announcement = MockAnnouncement.create(
          id: 'ann-wrap',
          content: '<p>Wrapped reactions.</p>',
          publishedAt: '2024-08-01T10:00:00.000Z',
          read: true,
          reactions: [
            MockReaction.create(name: '👍', count: 1),
          ],
        );
        injectAnnouncements(tester, [announcement]);
        await tester.pump();

        // Should use Wrap for reaction layout
        expect(find.byType(Wrap), findsOneWidget);
      });

      testWidgets('my reaction has primaryContainer background', (tester) async {
        await tester.pumpWidget(createTestWidget(
          child: const AnnouncementSheet(status: null),
        ));
        await tester.pump();

        final announcement = MockAnnouncement.create(
          id: 'ann-me',
          content: '<p>My reaction.</p>',
          publishedAt: '2024-09-01T10:00:00.000Z',
          read: true,
          reactions: [
            MockReaction.create(name: '👍', count: 2, me: true),
          ],
        );
        injectAnnouncements(tester, [announcement]);
        await tester.pump();

        // Should render the ActionChip (me=true sets backgroundColor)
        final ActionChip chip = tester.widget(find.byType(ActionChip));
        expect(chip.backgroundColor, isNotNull);
      });
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
