// Widget tests for ConversationItem.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

import '../../helpers/test_helpers.dart';

void main() {
  setupTestEnvironment();

  group('ConversationItem', () {
    test('renders with single participant', () {
      final conversation = MockConversation.create(
        lastStatus: MockStatus.create(content: '<p>Hello world</p>'),
      );

      final widget = ConversationItem(schema: conversation);
      expect(widget.schema.accounts.length, 1);
      expect(widget.schema.accounts.first.displayName, 'Test User');
    });

    testWidgets('displays participant name', (WidgetTester tester) async {
      final conversation = MockConversation.create(
        accounts: [MockAccount.create(displayName: 'Alice')],
        lastStatus: MockStatus.create(content: '<p>Test message</p>'),
      );

      await tester.pumpWidget(createTestWidget(
        child: ConversationItem(schema: conversation),
      ));
      await tester.pump();

      expect(find.text('Alice'), findsOneWidget);
    });

    testWidgets('displays multiple participant names', (WidgetTester tester) async {
      final conversation = MockConversation.createGroup(participantCount: 2);

      await tester.pumpWidget(createTestWidget(
        child: ConversationItem(schema: conversation),
      ));
      await tester.pump();

      expect(find.textContaining('User 0'), findsOneWidget);
    });

    testWidgets('displays last message preview as plain text', (WidgetTester tester) async {
      final conversation = MockConversation.create(
        lastStatus: MockStatus.create(content: '<p>Hello <strong>world</strong></p>'),
      );

      await tester.pumpWidget(createTestWidget(
        child: ConversationItem(schema: conversation),
      ));
      await tester.pump();

      expect(find.textContaining('Hello world'), findsOneWidget);
    });

    testWidgets('displays date from last status', (WidgetTester tester) async {
      final conversation = MockConversation.create(
        lastStatus: MockStatus.create(
          content: '<p>Test</p>',
          createdAt: DateTime(2024, 6, 15),
        ),
      );

      await tester.pumpWidget(createTestWidget(
        child: ConversationItem(schema: conversation),
      ));
      await tester.pump();

      expect(find.textContaining('2024-06-15'), findsOneWidget);
    });

    testWidgets('shows unread badge when unread', (WidgetTester tester) async {
      final conversation = MockConversation.createUnread();

      await tester.pumpWidget(createTestWidget(
        child: ConversationItem(schema: conversation),
      ));
      await tester.pump();

      // The badge is a decorated Container with circle shape
      final Finder decoratedBadge = find.byWidgetPredicate(
        (widget) {
          if (widget is Container && widget.decoration is BoxDecoration) {
            final BoxDecoration decoration = widget.decoration! as BoxDecoration;
            return decoration.shape == BoxShape.circle;
          }
          return false;
        },
      );
      expect(decoratedBadge, findsOneWidget);
    });

    testWidgets('hides unread badge when read', (WidgetTester tester) async {
      final conversation = MockConversation.create(
        lastStatus: MockStatus.create(content: '<p>Read message</p>'),
        unread: false,
      );

      await tester.pumpWidget(createTestWidget(
        child: ConversationItem(schema: conversation),
      ));
      await tester.pump();

      final Finder decoratedBadge = find.byWidgetPredicate(
        (widget) {
          if (widget is Container && widget.decoration is BoxDecoration) {
            final BoxDecoration decoration = widget.decoration! as BoxDecoration;
            return decoration.shape == BoxShape.circle;
          }
          return false;
        },
      );
      expect(decoratedBadge, findsNothing);
    });

    testWidgets('uses bold text for unread participant name', (WidgetTester tester) async {
      final conversation = MockConversation.createUnread(
        accounts: [MockAccount.create(displayName: 'Alice')],
      );

      await tester.pumpWidget(createTestWidget(
        child: ConversationItem(schema: conversation),
      ));
      await tester.pump();

      final Text nameWidget = tester.widget<Text>(find.text('Alice'));
      expect(nameWidget.style?.fontWeight, FontWeight.bold);
    });

    testWidgets('uses normal weight text for read participant name', (WidgetTester tester) async {
      final conversation = MockConversation.create(
        accounts: [MockAccount.create(displayName: 'Alice')],
        lastStatus: MockStatus.create(content: '<p>Read</p>'),
        unread: false,
      );

      await tester.pumpWidget(createTestWidget(
        child: ConversationItem(schema: conversation),
      ));
      await tester.pump();

      final Text nameWidget = tester.widget<Text>(find.text('Alice'));
      expect(nameWidget.style?.fontWeight, FontWeight.normal);
    });

    testWidgets('handles conversation without lastStatus', (WidgetTester tester) async {
      final conversation = MockConversation.create(lastStatus: null);

      await tester.pumpWidget(createTestWidget(
        child: ConversationItem(schema: conversation),
      ));
      await tester.pump();

      expect(find.text('Test User'), findsOneWidget);
    });

    testWidgets('handles conversation with empty accounts', (WidgetTester tester) async {
      final conversation = ConversationSchema(
        id: 'conv-empty',
        accounts: [],
        unread: false,
      );

      await tester.pumpWidget(createTestWidget(
        child: ConversationItem(schema: conversation),
      ));
      await tester.pump();

      // Should render without crashing, SizedBox placeholder for avatar
      expect(find.byType(ConversationItem), findsOneWidget);
    });

    testWidgets('fires onTap callback when tapped', (WidgetTester tester) async {
      bool tapped = false;
      final conversation = MockConversation.create(
        lastStatus: MockStatus.create(content: '<p>Tap me</p>'),
      );

      await tester.pumpWidget(createTestWidget(
        child: ConversationItem(
          schema: conversation,
          onTap: () => tapped = true,
        ),
      ));
      await tester.pump();

      await tester.tap(find.byType(ConversationItem));
      expect(tapped, isTrue);
    });

    testWidgets('stacks avatars for multi-participant conversation', (WidgetTester tester) async {
      final conversation = MockConversation.createGroup(participantCount: 2);

      await tester.pumpWidget(createTestWidget(
        child: ConversationItem(schema: conversation),
      ));
      await tester.pump();

      // Should use a 48x48 SizedBox containing a Stack for multiple avatars
      final Finder stackedAvatars = find.descendant(
        of: find.byType(ConversationItem),
        matching: find.byWidgetPredicate(
          (w) => w is SizedBox && w.width == 48 && w.height == 48,
        ),
      );
      expect(stackedAvatars, findsOneWidget);
    });

    testWidgets('uses single avatar for single participant', (WidgetTester tester) async {
      final conversation = MockConversation.create(
        lastStatus: MockStatus.create(content: '<p>Solo</p>'),
      );

      await tester.pumpWidget(createTestWidget(
        child: ConversationItem(schema: conversation),
      ));
      await tester.pump();

      // Should NOT use a 48x48 SizedBox (that's for multi-participant)
      final Finder stackedAvatars = find.descendant(
        of: find.byType(ConversationItem),
        matching: find.byWidgetPredicate(
          (w) => w is SizedBox && w.width == 48 && w.height == 48,
        ),
      );
      expect(stackedAvatars, findsNothing);
    });

    testWidgets('has InkWell for tap interaction', (WidgetTester tester) async {
      final conversation = MockConversation.create();

      await tester.pumpWidget(createTestWidget(
        child: ConversationItem(schema: conversation),
      ));
      await tester.pump();

      final Finder inkWell = find.descendant(
        of: find.byType(ConversationItem),
        matching: find.byType(InkWell),
      );
      expect(inkWell, findsAtLeastNWidgets(1));
    });

    testWidgets('has bottom border divider', (WidgetTester tester) async {
      final conversation = MockConversation.create();

      await tester.pumpWidget(createTestWidget(
        child: ConversationItem(schema: conversation),
      ));
      await tester.pump();

      final Finder containerFinder = find.byWidgetPredicate(
        (widget) {
          if (widget is Container && widget.decoration is BoxDecoration) {
            final BoxDecoration decoration = widget.decoration! as BoxDecoration;
            return decoration.border is Border;
          }
          return false;
        },
      );
      expect(containerFinder, findsOneWidget);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
