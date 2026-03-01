// Widget tests for StatusHistory and StatusEdit components.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/screens.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  setupTestEnvironment();

  group('StatusHistory', () {
    testWidgets('renders with schema', (tester) async {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );
      final schema = MockStatus.create();

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: StatusHistory(schema: schema)),
          accessStatus: status,
        ));
        await tester.pump();
      });

      expect(find.byType(StatusHistory), findsOneWidget);
    });

    testWidgets('shows empty content initially', (tester) async {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );
      final schema = MockStatus.create();

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: StatusHistory(schema: schema)),
          accessStatus: status,
        ));
        await tester.pump();
      });

      // History is empty before load completes, so buildContent returns SizedBox.shrink
      expect(find.byType(SizedBox), findsWidgets);
      // No PageView should be present when history is empty
      expect(find.byType(PageView), findsNothing);
    });

    testWidgets('shows PageView and slider when history is injected', (tester) async {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );
      final schema = MockStatus.create();

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: StatusHistory(schema: schema)),
          accessStatus: status,
        ));
        await tester.pump();
      });

      // Inject mock history via state access
      final state = tester.state(find.byType(StatusHistory));
      final mockHistory = MockStatusEdit.createHistory(count: 3);
      (state as dynamic).history = mockHistory;
      (state as dynamic).selectedIndex = 2;
      (tester.element(find.byType(StatusHistory)) as StatefulElement)
          .markNeedsBuild();
      await tester.pump();

      // PageView should now be rendered
      expect(find.byType(PageView), findsOneWidget);
      // SfSlider should be visible for navigation
      expect(find.byType(SfSlider), findsOneWidget);
    });

    testWidgets('buildHistory renders StatusEdit for each entry', (tester) async {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );
      final schema = MockStatus.create();

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: StatusHistory(schema: schema)),
          accessStatus: status,
        ));
        await tester.pump();
      });

      // Inject history with 2 entries
      final state = tester.state(find.byType(StatusHistory));
      final mockHistory = MockStatusEdit.createHistory(count: 2);
      (state as dynamic).history = mockHistory;
      (state as dynamic).selectedIndex = 1;
      (tester.element(find.byType(StatusHistory)) as StatefulElement)
          .markNeedsBuild();
      await tester.pump();

      // StatusEdit widgets are generated per history entry inside PageView
      expect(find.byType(StatusEdit), findsWidgets);
    });

    testWidgets('two history entries show slider and both StatusEdit widgets', (tester) async {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );
      final schema = MockStatus.create();

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: StatusHistory(schema: schema)),
          accessStatus: status,
        ));
        await tester.pump();
      });

      // Inject 2 entries (SfSlider requires min != max, so count must be >= 2)
      final state = tester.state(find.byType(StatusHistory));
      final mockHistory = MockStatusEdit.createHistory(count: 2);
      (state as dynamic).history = mockHistory;
      (state as dynamic).selectedIndex = 1;
      (tester.element(find.byType(StatusHistory)) as StatefulElement)
          .markNeedsBuild();
      await tester.pump();

      expect(find.byType(SfSlider), findsOneWidget);
      expect(find.byType(StatusEdit), findsWidgets);
    });

    testWidgets('onDismiss sets isDisposed and calls pop', (tester) async {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );
      final schema = MockStatus.create();

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: StatusHistory(schema: schema)),
          accessStatus: status,
        ));
        await tester.pump();
      });

      final state = tester.state(find.byType(StatusHistory));
      // context.pop() throws AssertionError without GoRouter — catch it
      try {
        // ignore: avoid_dynamic_calls
        (state as dynamic).onDismiss();
      } catch (_) {
        // Expected — no GoRouter in test widget tree
      }
      await tester.pump();

      // After onDismiss, isDisposed should be true
      // ignore: avoid_dynamic_calls
      expect((state as dynamic).isDisposed, isTrue);
    });

    testWidgets('AccessibleDismissible wraps content', (tester) async {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );
      final schema = MockStatus.create();

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: StatusHistory(schema: schema)),
          accessStatus: status,
        ));
        await tester.pump();
      });

      expect(find.byType(AccessibleDismissible), findsOneWidget);
    });

    testWidgets('history content renders Row with Flexible and slider', (tester) async {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );
      final schema = MockStatus.create();

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: StatusHistory(schema: schema)),
          accessStatus: status,
        ));
        await tester.pump();
      });

      // Inject history
      final state = tester.state(find.byType(StatusHistory));
      final mockHistory = MockStatusEdit.createHistory(count: 3);
      (state as dynamic).history = mockHistory;
      (state as dynamic).selectedIndex = 0;
      (tester.element(find.byType(StatusHistory)) as StatefulElement)
          .markNeedsBuild();
      await tester.pump();

      // Row wraps PageView (in Flexible) and the slider
      expect(find.byType(Row), findsWidgets);
      expect(find.byType(Flexible), findsWidgets);
    });
  });

  group('StatusEdit', () {
    testWidgets('renders with schema', (tester) async {
      final schema = MockStatusEdit.create();

      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          body: SizedBox(
            height: 600,
            child: StatusEdit(schema: schema),
          ),
        ),
      ));
      await tester.pump();

      expect(find.byType(StatusEdit), findsOneWidget);
    });

    testWidgets('shows account info', (tester) async {
      final account = MockAccount.create(displayName: 'Edit Author');
      final schema = MockStatusEdit.create(account: account);

      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          body: SizedBox(
            height: 600,
            child: StatusEdit(schema: schema),
          ),
        ),
      ));
      await tester.pump();

      expect(find.byType(Account), findsOneWidget);
    });

    testWidgets('shows date', (tester) async {
      final date = DateTime(2023, 6, 15, 14, 30);
      final schema = MockStatusEdit.create(createdAt: date);

      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          body: SizedBox(
            height: 600,
            child: StatusEdit(schema: schema),
          ),
        ),
      ));
      await tester.pump();

      // The date is displayed as a local string
      expect(find.textContaining('2023'), findsOneWidget);
    });

    testWidgets('shows content via HtmlDone', (tester) async {
      final schema = MockStatusEdit.create(content: '<p>Edited content.</p>');

      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          body: SizedBox(
            height: 600,
            child: StatusEdit(schema: schema),
          ),
        ),
      ));
      await tester.pump();

      expect(find.byType(HtmlDone), findsOneWidget);
    });

    testWidgets('shows divider', (tester) async {
      final schema = MockStatusEdit.create();

      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          body: SizedBox(
            height: 600,
            child: StatusEdit(schema: schema),
          ),
        ),
      ));
      await tester.pump();

      expect(find.byType(Divider), findsOneWidget);
    });

    testWidgets('shows Poll widget', (tester) async {
      final schema = MockStatusEdit.create();

      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          body: SizedBox(
            height: 600,
            child: StatusEdit(schema: schema),
          ),
        ),
      ));
      await tester.pump();

      expect(find.byType(Poll), findsOneWidget);
    });

    testWidgets('shows Attachments widget', (tester) async {
      final schema = MockStatusEdit.create();

      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          body: SizedBox(
            height: 600,
            child: StatusEdit(schema: schema),
          ),
        ),
      ));
      await tester.pump();

      expect(find.byType(Attachments), findsOneWidget);
    });

    testWidgets('renders Column as top-level layout', (tester) async {
      final schema = MockStatusEdit.create();

      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          body: SizedBox(
            height: 600,
            child: StatusEdit(schema: schema),
          ),
        ),
      ));
      await tester.pump();

      // Column with crossAxisAlignment.start
      expect(find.byType(Column), findsWidgets);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
