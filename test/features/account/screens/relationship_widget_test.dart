// Widget tests for Relationship widget — expanded coverage for popup menu,
// more-actions rendering, buildRequest, buildRelationship, state injection,
// and various relationship states.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

import '../../../helpers/test_helpers.dart';

// Use domain-null status so API calls short-circuit without HTTP.
AccessStatusSchema _noDomainAuth() {
  return const AccessStatusSchema(domain: null, accessToken: 'test');
}

void main() {
  setupTestEnvironment();

  group('Relationship', () {
    testWidgets('renders as a Row', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: Relationship(schema: MockAccount.create()),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();
      });

      expect(find.byType(Relationship), findsOneWidget);
      expect(find.byType(Row), findsWidgets);
    });

    testWidgets('shows more actions button', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: Relationship(schema: MockAccount.create()),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();
      });

      expect(find.byIcon(Icons.more_horiz), findsOneWidget);
    });

    test('is a ConsumerStatefulWidget', () {
      final widget = Relationship(schema: MockAccount.create());
      expect(widget, isA<ConsumerStatefulWidget>());
    });

    test('accepts required schema parameter', () {
      final account = MockAccount.create(id: 'rel-test', displayName: 'RelTest');
      final widget = Relationship(schema: account);
      expect(widget.schema.id, 'rel-test');
    });

    testWidgets('renders with no-domain status', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: Relationship(schema: MockAccount.create()),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();
      });

      expect(find.byType(Relationship), findsOneWidget);
    });

    testWidgets('shows stranger icon by default (no relationship loaded)', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: Relationship(schema: MockAccount.create()),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();
      });

      // When schema is null, relationship getter returns stranger
      expect(find.byIcon(RelationshipType.stranger.icon()), findsOneWidget);
    });

    testWidgets('relationship icon button has correct key', (tester) async {
      final account = MockAccount.create(id: 'key-test');

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: Relationship(schema: account),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();
      });

      // The key should be account.id + relationship name
      expect(find.byKey(const ValueKey('key-test-stranger')), findsOneWidget);
    });

    testWidgets('contains PopupMenuButton for more actions', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: Relationship(schema: MockAccount.create()),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();
      });

      expect(find.byType(PopupMenuButton<Object>), findsOneWidget);
    });

    testWidgets('popup menu opens and shows personal note item', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: Relationship(schema: MockAccount.create()),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();
      });

      // Tap more actions popup
      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();

      // Should show personal note option
      expect(find.text('Personal note'), findsOneWidget);
    });

    testWidgets('popup menu shows feature on profile option', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: Relationship(schema: MockAccount.create()),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();
      });

      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();

      // schema is null so endorsed is false -> shows "Feature on profile"
      expect(find.text('Feature on profile'), findsOneWidget);
    });

    testWidgets('popup menu shows note icon outlined when no note', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: Relationship(schema: MockAccount.create()),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();
      });

      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();

      // When no note, shows outlined icon
      expect(find.byIcon(Icons.sticky_note_2_outlined), findsOneWidget);
    });

    testWidgets('popup menu shows star_outline when not endorsed', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: Relationship(schema: MockAccount.create()),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();
      });

      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();

      // Not endorsed -> star_outline icon
      expect(find.byIcon(Icons.star_outline), findsOneWidget);
    });

    testWidgets('popup menu shows mute action', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: Relationship(schema: MockAccount.create()),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();
      });

      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();

      // When schema is null, muting is not true, so mute action is shown (unmute is removed)
      expect(find.byIcon(RelationshipType.mute.icon()), findsOneWidget);
    });

    testWidgets('popup menu shows block action', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: Relationship(schema: MockAccount.create()),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();
      });

      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();

      // When schema is null, blocking is not true, so block action is shown (unblock is removed)
      expect(find.byIcon(RelationshipType.block.icon()), findsOneWidget);
    });

    testWidgets('popup menu shows report action', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: Relationship(schema: MockAccount.create()),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();
      });

      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();

      // Report action is always shown
      expect(find.byIcon(RelationshipType.report.icon()), findsOneWidget);
    });

    testWidgets('popup menu shows divider between note/endorse and actions', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: Relationship(schema: MockAccount.create()),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();
      });

      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();

      expect(find.byType(PopupMenuDivider), findsOneWidget);
    });

    testWidgets('tapping personal note opens dialog with TextField', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: Relationship(schema: MockAccount.create()),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();
      });

      // Open popup
      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();

      // Tap personal note
      await tester.tap(find.text('Personal note'));
      await tester.pumpAndSettle();

      // Should open a dialog with a TextField for editing the note
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('note dialog has save button', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: Relationship(schema: MockAccount.create()),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();
      });

      // Open popup and tap note
      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Personal note'));
      await tester.pumpAndSettle();

      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('tapping mute action shows confirm dialog', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: Relationship(schema: MockAccount.create(displayName: 'MuteTarget')),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();
      });

      // Open popup
      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();

      // Find the mute ListTile text
      final muteFinder = find.byWidgetPredicate(
        (widget) => widget is ListTile && widget.title is Text &&
          (widget.title as Text).data != null &&
          (widget.title as Text).data!.contains('Mute'),
      );

      // Tap on mute action
      await tester.tap(muteFinder.first);
      await tester.pumpAndSettle();

      // Should show a confirm dialog since mute is dangerous
      expect(find.text('Confirm'), findsOneWidget);
    });

    testWidgets('tapping block action shows confirm dialog', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: Relationship(schema: MockAccount.create(displayName: 'BlockTarget')),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();
      });

      // Open popup
      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();

      // Find the block ListTile
      final blockFinder = find.byWidgetPredicate(
        (widget) => widget is ListTile && widget.title is Text &&
          (widget.title as Text).data != null &&
          (widget.title as Text).data!.contains('Block'),
      );
      await tester.tap(blockFinder.first);
      await tester.pumpAndSettle();

      // Should show confirm dialog
      expect(find.text('Confirm'), findsOneWidget);
    });

    testWidgets('confirm dialog for block shows block message', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: Relationship(schema: MockAccount.create(displayName: 'BlockTarget')),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();
      });

      // Open popup
      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();

      // Find and tap block
      final blockFinder = find.byWidgetPredicate(
        (widget) => widget is ListTile && widget.title is Text &&
          (widget.title as Text).data != null &&
          (widget.title as Text).data!.contains('Block'),
      );
      await tester.tap(blockFinder.first);
      await tester.pumpAndSettle();

      // Confirm dialog should display the block message
      expect(find.textContaining('BlockTarget'), findsWidgets);
    });

    testWidgets('buildRequest hidden by default (requestedBy is null)', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: Relationship(schema: MockAccount.create()),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();
      });

      // schema is null so requestedBy != true, follow request icon hidden
      expect(find.byIcon(Icons.mark_email_unread_sharp), findsNothing);
    });

    testWidgets('buildRequest shows when state has requestedBy', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: Relationship(schema: MockAccount.create()),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();

        // Inject requestedBy = true into the state
        final state = tester.state(find.byType(Relationship));
        (state as dynamic).schema = MockRelationship.create(requestedBy: true);
        (tester.element(find.byType(Relationship)) as StatefulElement).markNeedsBuild();
        await tester.pump();
      });

      expect(find.byIcon(Icons.mark_email_unread_sharp), findsOneWidget);
    });

    testWidgets('buildRelationship uses AnimatedSwitcher', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: Relationship(schema: MockAccount.create()),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();
      });

      expect(find.byType(AnimatedSwitcher), findsWidgets);
    });

    testWidgets('relationship button shows following icon when following', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: Relationship(schema: MockAccount.create()),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();

        // Inject following relationship
        final state = tester.state(find.byType(Relationship));
        (state as dynamic).schema = MockRelationship.create(following: true);
        (tester.element(find.byType(Relationship)) as StatefulElement).markNeedsBuild();
        await tester.pump();
      });

      expect(find.byIcon(RelationshipType.following.icon()), findsOneWidget);
    });

    testWidgets('relationship button shows followEachOther icon for mutual follow', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: Relationship(schema: MockAccount.create()),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();

        final state = tester.state(find.byType(Relationship));
        (state as dynamic).schema = MockRelationship.create(following: true, followedBy: true);
        (tester.element(find.byType(Relationship)) as StatefulElement).markNeedsBuild();
        await tester.pump();
      });

      expect(find.byIcon(RelationshipType.followEachOther.icon()), findsOneWidget);
    });

    testWidgets('relationship button shows blockedBy icon and is disabled', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: Relationship(schema: MockAccount.create()),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();

        final state = tester.state(find.byType(Relationship));
        (state as dynamic).schema = MockRelationship.create(blockedBy: true);
        (tester.element(find.byType(Relationship)) as StatefulElement).markNeedsBuild();
        await tester.pump();
      });

      expect(find.byIcon(RelationshipType.blockedBy.icon()), findsOneWidget);

      // The button should be disabled
      final iconButton = tester.widget<IconButton>(
        find.byKey(const ValueKey('123-blockedBy')),
      );
      expect(iconButton.onPressed, isNull);
    });

    testWidgets('relationship button shows unblock icon when blocking', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: Relationship(schema: MockAccount.create()),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();

        final state = tester.state(find.byType(Relationship));
        (state as dynamic).schema = MockRelationship.create(blocking: true);
        (tester.element(find.byType(Relationship)) as StatefulElement).markNeedsBuild();
        await tester.pump();
      });

      expect(find.byIcon(RelationshipType.unblock.icon()), findsOneWidget);
    });

    testWidgets('relationship button shows followRequest icon when requested', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: Relationship(schema: MockAccount.create()),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();

        final state = tester.state(find.byType(Relationship));
        (state as dynamic).schema = MockRelationship.create(requested: true);
        (tester.element(find.byType(Relationship)) as StatefulElement).markNeedsBuild();
        await tester.pump();
      });

      expect(find.byIcon(RelationshipType.followRequest.icon()), findsOneWidget);
    });

    testWidgets('relationship button shows followedBy icon', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: Relationship(schema: MockAccount.create()),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();

        final state = tester.state(find.byType(Relationship));
        (state as dynamic).schema = MockRelationship.create(followedBy: true);
        (tester.element(find.byType(Relationship)) as StatefulElement).markNeedsBuild();
        await tester.pump();
      });

      expect(find.byIcon(RelationshipType.followedBy.icon()), findsOneWidget);
    });

    testWidgets('popup menu with muted state shows unmute and filled note icon', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: Relationship(schema: MockAccount.create()),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();

        // Inject muting state inside runAsync (after onRefresh completes)
        final state = tester.state(find.byType(Relationship));
        (state as dynamic).schema = MockRelationship.create(
          muting: true,
          note: 'A personal note about this account',
          endorsed: true,
        );
        (tester.element(find.byType(Relationship)) as StatefulElement).markNeedsBuild();
        await tester.pump();
      });

      // Open popup
      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();

      // When muting == true, mute action is removed (shows unmute)
      expect(find.byIcon(RelationshipType.unmute.icon()), findsOneWidget);

      // When note is not empty, should show filled note icon
      expect(find.byIcon(Icons.sticky_note_2), findsOneWidget);

      // When endorsed, should show "Unfeature from profile" (localized string)
      expect(find.text('Unfeature from profile'), findsOneWidget);

      // When endorsed, should show filled star icon
      expect(find.byIcon(Icons.star), findsWidgets);
    });

    testWidgets('popup menu with blocking state shows unblock instead of block', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: Relationship(schema: MockAccount.create()),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();

        // Inject blocking state inside runAsync (after onRefresh completes)
        final state = tester.state(find.byType(Relationship));
        (state as dynamic).schema = MockRelationship.create(blocking: true);
        (tester.element(find.byType(Relationship)) as StatefulElement).markNeedsBuild();
        await tester.pump();
      });

      // Open popup
      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();

      // When blocking == true, block action is removed (shows unblock)
      expect(find.byIcon(RelationshipType.unblock.icon()), findsWidgets);
    });

    testWidgets('request icon has styled background', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: Relationship(schema: MockAccount.create()),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();

        final state = tester.state(find.byType(Relationship));
        (state as dynamic).schema = MockRelationship.create(requestedBy: true);
        (tester.element(find.byType(Relationship)) as StatefulElement).markNeedsBuild();
        await tester.pump();
      });

      // The request icon button should be wrapped in Padding
      expect(find.byType(Padding), findsWidgets);
      // And should have the mark_email_unread_sharp icon
      expect(find.byIcon(Icons.mark_email_unread_sharp), findsOneWidget);
    });

    testWidgets('relationship button is enabled for stranger', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: Relationship(schema: MockAccount.create()),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();
      });

      final iconButton = tester.widget<IconButton>(
        find.byKey(const ValueKey('123-stranger')),
      );
      expect(iconButton.onPressed, isNotNull);
    });

    testWidgets('relationship button is enabled for following', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: Relationship(schema: MockAccount.create()),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();

        final state = tester.state(find.byType(Relationship));
        (state as dynamic).schema = MockRelationship.create(following: true);
        (tester.element(find.byType(Relationship)) as StatefulElement).markNeedsBuild();
        await tester.pump();
      });

      final iconButton = tester.widget<IconButton>(
        find.byKey(const ValueKey('123-following')),
      );
      expect(iconButton.onPressed, isNotNull);
    });

    testWidgets('SlideTransition exists for animated transitions', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: Relationship(schema: MockAccount.create()),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();
      });

      expect(find.byType(SlideTransition), findsWidgets);
    });

    testWidgets('FadeTransition exists for animated transitions', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: Relationship(schema: MockAccount.create()),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();
      });

      expect(find.byType(FadeTransition), findsWidgets);
    });

    testWidgets('contains SizedBox spacers between elements', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: Relationship(schema: MockAccount.create()),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();
      });

      // Row has SizedBox(width: 8) spacers
      final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox))
        .where((s) => s.width == 8);
      expect(sizedBoxes.length, greaterThanOrEqualTo(2));
    });
  });

  group('RelationshipType', () {
    test('has following and stranger', () {
      expect(RelationshipType.values, contains(RelationshipType.following));
      expect(RelationshipType.values, contains(RelationshipType.stranger));
    });

    test('has block and unblock', () {
      expect(RelationshipType.values, contains(RelationshipType.block));
      expect(RelationshipType.values, contains(RelationshipType.unblock));
    });

    test('has mute and unmute', () {
      expect(RelationshipType.values, contains(RelationshipType.mute));
      expect(RelationshipType.values, contains(RelationshipType.unmute));
    });

    test('isMoreActions differentiates primary from secondary', () {
      expect(RelationshipType.following.isMoreActions, false);
      expect(RelationshipType.stranger.isMoreActions, false);
      expect(RelationshipType.block.isMoreActions, true);
      expect(RelationshipType.mute.isMoreActions, true);
    });

    test('each has icon', () {
      for (final type in RelationshipType.values) {
        expect(type.icon(), isA<IconData>());
      }
    });

    test('isDangerous is true for mute, block, report only', () {
      expect(RelationshipType.mute.isDangerous, isTrue);
      expect(RelationshipType.block.isDangerous, isTrue);
      expect(RelationshipType.report.isDangerous, isTrue);
      expect(RelationshipType.unmute.isDangerous, isFalse);
      expect(RelationshipType.unblock.isDangerous, isFalse);
      expect(RelationshipType.following.isDangerous, isFalse);
    });

    testWidgets('tooltip for mute includes account acct', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: Builder(
          builder: (context) {
            final account = MockAccount.create(username: 'alice');
            final tooltip = RelationshipType.mute.tooltip(context, account: account);
            expect(tooltip, contains('@alice'));
            return const SizedBox.shrink();
          },
        ),
      ));
      await tester.pump();
    });

    testWidgets('tooltip for block includes account acct', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: Builder(
          builder: (context) {
            final account = MockAccount.create(username: 'bob');
            final tooltip = RelationshipType.block.tooltip(context, account: account);
            expect(tooltip, contains('@bob'));
            return const SizedBox.shrink();
          },
        ),
      ));
      await tester.pump();
    });

    testWidgets('tooltip without account has empty acct', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: Builder(
          builder: (context) {
            final tooltip = RelationshipType.following.tooltip(context);
            expect(tooltip.isNotEmpty, isTrue);
            return const SizedBox.shrink();
          },
        ),
      ));
      await tester.pump();
    });
  });

  group('RelationshipSchema', () {
    test('fromJson parses all fields', () {
      final rel = MockRelationship.create();
      expect(rel.following, false);
      expect(rel.blocking, false);
      expect(rel.muting, false);
    });

    test('fromJson with following true', () {
      final rel = MockRelationship.create(following: true);
      expect(rel.following, true);
    });

    test('fromJson with blocking true', () {
      final rel = MockRelationship.create(blocking: true);
      expect(rel.blocking, true);
    });

    test('fromJson with muting true', () {
      final rel = MockRelationship.create(muting: true);
      expect(rel.muting, true);
    });

    test('type returns blockedBy when blockedBy is true', () {
      final rel = MockRelationship.create(blockedBy: true);
      expect(rel.type, RelationshipType.blockedBy);
    });

    test('type returns unblock when blocking is true', () {
      final rel = MockRelationship.create(blocking: true);
      expect(rel.type, RelationshipType.unblock);
    });

    test('type returns followRequest when requested is true', () {
      final rel = MockRelationship.create(requested: true);
      expect(rel.type, RelationshipType.followRequest);
    });

    test('type returns followEachOther for mutual follow', () {
      final rel = MockRelationship.create(following: true, followedBy: true);
      expect(rel.type, RelationshipType.followEachOther);
    });

    test('type returns following when only following', () {
      final rel = MockRelationship.create(following: true, followedBy: false);
      expect(rel.type, RelationshipType.following);
    });

    test('type returns followedBy when only followedBy', () {
      final rel = MockRelationship.create(following: false, followedBy: true);
      expect(rel.type, RelationshipType.followedBy);
    });

    test('type returns stranger for no relationship', () {
      final rel = MockRelationship.create();
      expect(rel.type, RelationshipType.stranger);
    });

    test('endorsed field is accessible', () {
      final rel = MockRelationship.create(endorsed: true);
      expect(rel.endorsed, isTrue);
    });

    test('note field is accessible', () {
      final rel = MockRelationship.create(note: 'test note');
      expect(rel.note, 'test note');
    });

    test('requestedBy field is accessible', () {
      final rel = MockRelationship.create(requestedBy: true);
      expect(rel.requestedBy, isTrue);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
