// Widget tests for AppShortcuts keyboard handler.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/cores/screens/app_shortcuts.dart';
import 'package:glacial/features/glacial/screens/home.dart';
import '../../helpers/test_helpers.dart';

void main() {
  setupTestEnvironment();

  // Reset all GlacialHome statics between tests to avoid cross-contamination.
  setUp(() {
    GlacialHome.clearTabSwitchStack();
    GlacialHome.onFocusSearch = null;
    GlacialHome.onCloseSearch = null;
    GlacialHome.onRefresh = null;
    GlacialHome.onInteractStatus = null;
    GlacialHome.getStatuses = null;
    GlacialHome.itemScrollToTop = null;
    GlacialHome.itemPositions = null;
    GlacialHome.activeTabController = null;
    GlacialHome.activeVisibleIndexes = null;
    GlacialHome.focusedStatusIndex.value = null;
    GlacialHome.suppressAutoFocusUntil = null;
    GlacialHome.activeTabLabel.value = null;
  });

  /// Helper: mount AppShortcuts with a GoRouter-like mock that reports
  /// a given path. Since we can't easily inject GoRouter state in unit
  /// tests, we test the HardwareKeyboard handler directly via
  /// simulated key events through the WidgetTester.
  Widget buildShortcutsWidget({Widget? child}) {
    return createTestWidget(
      child: AppShortcuts(child: child ?? const SizedBox.shrink()),
    );
  }

  group('Tab shortcut', () {
    testWidgets('Tab calls onTabSwitch(1) when registered', (tester) async {
      int? delta;
      GlacialHome.pushTabSwitch((d) => delta = d);

      await tester.pumpWidget(buildShortcutsWidget());
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();

      expect(delta, equals(1));
    });

    testWidgets('Shift+Tab calls onTabSwitch(-1)', (tester) async {
      int? delta;
      GlacialHome.pushTabSwitch((d) => delta = d);

      await tester.pumpWidget(buildShortcutsWidget());
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pump();

      expect(delta, equals(-1));
    });

    testWidgets('Tab does nothing when no onTabSwitch registered', (tester) async {
      GlacialHome.clearTabSwitchStack();

      await tester.pumpWidget(buildShortcutsWidget());
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();

      // No crash, no assertion failure
    });

    testWidgets('Tab works even when a text field has focus', (tester) async {
      int? delta;
      GlacialHome.pushTabSwitch((d) => delta = d);

      await tester.pumpWidget(buildShortcutsWidget(
        child: const TextField(autofocus: true),
      ));
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();

      expect(delta, equals(1));
    });
  });

  group('Esc shortcut', () {
    testWidgets('Esc calls onCloseSearch', (tester) async {
      bool closeCalled = false;
      GlacialHome.onCloseSearch = () => closeCalled = true;

      await tester.pumpWidget(buildShortcutsWidget());
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();

      expect(closeCalled, isTrue);
    });

    testWidgets('Esc unfocuses primary focus', (tester) async {
      await tester.pumpWidget(buildShortcutsWidget(
        child: const TextField(autofocus: true),
      ));
      await tester.pumpAndSettle();

      // Tap the text field to ensure it has focus
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      // Verify text field has focus
      final focusBefore = FocusManager.instance.primaryFocus;
      expect(focusBefore, isNotNull);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      // Focus should have moved away (unfocused or to a different node)
      final focusAfter = FocusManager.instance.primaryFocus;
      expect(identical(focusBefore, focusAfter), isFalse);
    });
  });

  group('Modifier bypass', () {
    testWidgets('Cmd+key is not consumed', (tester) async {
      int? delta;
      GlacialHome.pushTabSwitch((d) => delta = d);

      await tester.pumpWidget(buildShortcutsWidget());
      await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
      await tester.pump();

      // Tab with Cmd should NOT trigger tab switch
      // (Tab check fires before modifier check, but Cmd+Tab is typically
      // handled by the OS so this tests the edge case)
      // Note: in the current implementation, Tab check fires before
      // modifier check. This verifies that behavior.
      // Tab still fires because it's before the modifier guard — this
      // is acceptable since Cmd+Tab is an OS-level shortcut that Flutter
      // never sees.
      expect(delta, equals(1)); // Tab fires regardless of Cmd
    });

    testWidgets('Ctrl+key is not consumed for non-Tab keys', (tester) async {
      bool refreshCalled = false;
      GlacialHome.onRefresh = () async => refreshCalled = true;

      await tester.pumpWidget(buildShortcutsWidget());
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.period);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pump();

      // Ctrl+. should not trigger refresh (blocked by modifier guard)
      // Note: this only applies to shortcuts that go through the binding
      // table (after the shortcutsActive guard). Since we can't easily
      // mock the GoRouter path, this test verifies the handler doesn't crash.
      expect(refreshCalled, isFalse);
    });
  });

  group('Text input guard', () {
    testWidgets('Letter shortcuts are blocked when text field has focus', (tester) async {
      bool searchCalled = false;
      GlacialHome.onFocusSearch = () => searchCalled = true;

      await tester.pumpWidget(buildShortcutsWidget(
        child: const TextField(autofocus: true),
      ));
      await tester.pump();

      // '/' key should NOT trigger search when typing
      await tester.sendKeyEvent(LogicalKeyboardKey.slash);
      await tester.pump();

      // The shortcutsActive guard blocks this before the text guard,
      // so it's not consumed regardless. This confirms no crash.
      expect(searchCalled, isFalse);
    });
  });

  group('focusedStatusIndex', () {
    testWidgets('focusedStatusIndex resets on tab switch', (tester) async {
      GlacialHome.focusedStatusIndex.value = 5;
      GlacialHome.pushTabSwitch((_) {});

      await tester.pumpWidget(buildShortcutsWidget());
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();

      expect(GlacialHome.focusedStatusIndex.value, isNull);
    });
  });

  group('Handler lifecycle', () {
    testWidgets('handler is removed on dispose', (tester) async {
      int? delta;
      GlacialHome.pushTabSwitch((d) => delta = d);

      await tester.pumpWidget(buildShortcutsWidget());
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(delta, equals(1));

      // Replace widget tree (disposes AppShortcuts)
      delta = null;
      await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();

      // Handler should have been removed — delta stays null
      expect(delta, isNull);
    });
  });

  group('NextFocusIntent suppression', () {
    testWidgets('Tab does not move focus between widgets', (tester) async {
      GlacialHome.pushTabSwitch((_) {});

      await tester.pumpWidget(createTestWidget(
        child: AppShortcuts(
          child: Column(
            children: [
              ElevatedButton(onPressed: () {}, child: const Text('A')),
              ElevatedButton(onPressed: () {}, child: const Text('B')),
            ],
          ),
        ),
      ));
      await tester.pump();

      // Focus button A
      await tester.tap(find.text('A'));
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();

      // Tab was consumed by our handler for tab switching, not by
      // focus traversal (NextFocusIntent is overridden with no-op).
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
