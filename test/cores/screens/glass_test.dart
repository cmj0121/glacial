// Widget tests for Adaptive Glass components.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/cores/platform.dart';
import 'package:glacial/cores/screens/glass.dart';

import '../../helpers/test_helpers.dart';

void main() {
  setUpAll(() => setupTestEnvironment());

  group('GlassStyle', () {
    test('has correct blur sigma', () {
      expect(GlassStyle.blurSigma, 20.0);
    });

    test('has correct opacity', () {
      expect(GlassStyle.opacity, 0.7);
    });

    test('has correct border opacity', () {
      expect(GlassStyle.borderOpacity, 0.2);
    });

    test('has correct border radius', () {
      expect(GlassStyle.borderRadius, 16.0);
    });
  });

  group('AdaptiveGlassContainer', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const AdaptiveGlassContainer(
          child: Text('Test Child'),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Test Child'), findsOneWidget);
    });

    testWidgets('applies width constraint', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const AdaptiveGlassContainer(
          width: 100,
          child: Text('Width Test'),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(AdaptiveGlassContainer), findsOneWidget);
    });

    testWidgets('applies height constraint', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const AdaptiveGlassContainer(
          height: 100,
          child: Text('Height Test'),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(AdaptiveGlassContainer), findsOneWidget);
    });

    testWidgets('applies padding', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const AdaptiveGlassContainer(
          padding: EdgeInsets.all(16),
          child: Text('Padding Test'),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(AdaptiveGlassContainer), findsOneWidget);
    });

    testWidgets('applies margin', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const AdaptiveGlassContainer(
          margin: EdgeInsets.all(8),
          child: Text('Margin Test'),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(AdaptiveGlassContainer), findsOneWidget);
    });

    testWidgets('uses ClipRRect for rounded corners', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const AdaptiveGlassContainer(
          child: Text('Clip Test'),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(ClipRRect), findsOneWidget);
    });

    testWidgets('uses BackdropFilter for blur effect', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const AdaptiveGlassContainer(
          child: Text('Blur Test'),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('accepts custom border radius', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const AdaptiveGlassContainer(
          borderRadius: BorderRadius.all(Radius.circular(24)),
          child: Text('Border Radius Test'),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(AdaptiveGlassContainer), findsOneWidget);
    });

    testWidgets('accepts custom color', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const AdaptiveGlassContainer(
          color: Colors.blue,
          child: Text('Color Test'),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(AdaptiveGlassContainer), findsOneWidget);
    });

    testWidgets('wraps child in Container', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const AdaptiveGlassContainer(
          child: Text('Container Test'),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(Container), findsWidgets);
    });
  });

  group('AdaptiveGlassCard', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const AdaptiveGlassCard(
          child: Text('Card Child'),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Card Child'), findsOneWidget);
    });

    testWidgets('applies padding', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const AdaptiveGlassCard(
          padding: EdgeInsets.all(16),
          child: Text('Padding Test'),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(AdaptiveGlassCard), findsOneWidget);
    });

    testWidgets('applies margin', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const AdaptiveGlassCard(
          margin: EdgeInsets.all(8),
          child: Text('Margin Test'),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(AdaptiveGlassCard), findsOneWidget);
    });

    testWidgets('triggers onTap callback when tapped', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(createTestWidget(
        child: AdaptiveGlassCard(
          onTap: () => tapped = true,
          child: const Text('Tap Me'),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Tap Me'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('uses ClipRRect for rounded corners', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const AdaptiveGlassCard(
          child: Text('Clip Test'),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(ClipRRect), findsOneWidget);
    });

    testWidgets('uses BackdropFilter for blur effect', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const AdaptiveGlassCard(
          child: Text('Blur Test'),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('uses Material for ink effects', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const AdaptiveGlassCard(
          child: Text('Material Test'),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(Material), findsWidgets);
    });

    testWidgets('uses InkWell for tap handling', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const AdaptiveGlassCard(
          child: Text('InkWell Test'),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(InkWell), findsOneWidget);
    });
  });

  group('AdaptiveGlassButton', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const AdaptiveGlassButton(
          child: Text('Button Text'),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Button Text'), findsOneWidget);
    });

    testWidgets('triggers onPressed callback when pressed', (tester) async {
      bool pressed = false;

      await tester.pumpWidget(createTestWidget(
        child: AdaptiveGlassButton(
          onPressed: () => pressed = true,
          child: const Text('Press Me'),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Press Me'));
      await tester.pump();

      expect(pressed, isTrue);
    });

    testWidgets('uses ClipRRect for rounded corners', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const AdaptiveGlassButton(
          child: Text('Clip Test'),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(ClipRRect), findsOneWidget);
    });

    testWidgets('uses BackdropFilter for blur effect', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const AdaptiveGlassButton(
          child: Text('Blur Test'),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('uses filled style when filled is true', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const AdaptiveGlassButton(
          filled: true,
          child: Text('Filled Button'),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Filled Button'), findsOneWidget);
    });

    testWidgets('applies custom padding', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const AdaptiveGlassButton(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Text('Padded Button'),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(AdaptiveGlassButton), findsOneWidget);
    });
  });

  group('AdaptiveGlassIconButton', () {
    testWidgets('renders icon', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const AdaptiveGlassIconButton(
          icon: Icons.settings,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('triggers onPressed callback when pressed', (tester) async {
      bool pressed = false;

      await tester.pumpWidget(createTestWidget(
        child: AdaptiveGlassIconButton(
          icon: Icons.add,
          onPressed: () => pressed = true,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(pressed, isTrue);
    });

    testWidgets('applies custom size', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const AdaptiveGlassIconButton(
          icon: Icons.home,
          size: 32,
        ),
      ));
      await tester.pumpAndSettle();

      final icon = tester.widget<Icon>(find.byIcon(Icons.home));
      expect(icon.size, 32);
    });

    testWidgets('applies custom color', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const AdaptiveGlassIconButton(
          icon: Icons.star,
          color: Colors.yellow,
        ),
      ));
      await tester.pumpAndSettle();

      final icon = tester.widget<Icon>(find.byIcon(Icons.star));
      expect(icon.color, Colors.yellow);
    });

    testWidgets('shows tooltip when provided', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const AdaptiveGlassIconButton(
          icon: Icons.info,
          tooltip: 'Info Button',
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(Tooltip), findsOneWidget);
    });

    testWidgets('uses ClipOval for circular shape', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const AdaptiveGlassIconButton(
          icon: Icons.check,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(ClipOval), findsOneWidget);
    });

    testWidgets('uses BackdropFilter for blur effect', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const AdaptiveGlassIconButton(
          icon: Icons.close,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(BackdropFilter), findsOneWidget);
    });
  });

  group('AdaptiveGlassBottomBar', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const AdaptiveGlassBottomBar(
          child: Text('Bottom Bar Content'),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Bottom Bar Content'), findsOneWidget);
    });

    testWidgets('applies padding', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const AdaptiveGlassBottomBar(
          padding: EdgeInsets.all(16),
          child: Text('Padded Content'),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(AdaptiveGlassBottomBar), findsOneWidget);
    });

    testWidgets('uses ClipRect for clipping', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const AdaptiveGlassBottomBar(
          child: Text('Clip Test'),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(ClipRect), findsWidgets);
    });

    testWidgets('uses BackdropFilter for blur effect', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const AdaptiveGlassBottomBar(
          child: Text('Blur Test'),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('uses SafeArea', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const AdaptiveGlassBottomBar(
          child: Text('Safe Area Test'),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(SafeArea), findsWidgets);
    });
  });

  group('AdaptiveGlassTabBar', () {
    testWidgets('renders tabs', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const AdaptiveGlassTabBar(
          tabs: [Text('Tab 1'), Text('Tab 2'), Text('Tab 3')],
          selectedIndex: 0,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Tab 1'), findsOneWidget);
      expect(find.text('Tab 2'), findsOneWidget);
      expect(find.text('Tab 3'), findsOneWidget);
    });

    testWidgets('highlights selected tab', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const AdaptiveGlassTabBar(
          tabs: [Text('First'), Text('Second')],
          selectedIndex: 1,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Second'), findsOneWidget);
    });

    testWidgets('triggers onTabSelected callback', (tester) async {
      int? selectedTab;

      await tester.pumpWidget(createTestWidget(
        child: AdaptiveGlassTabBar(
          tabs: const [Text('A'), Text('B')],
          selectedIndex: 0,
          onTabSelected: (index) => selectedTab = index,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('B'));
      await tester.pump();

      expect(selectedTab, 1);
    });

    testWidgets('uses ClipRect for clipping', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const AdaptiveGlassTabBar(
          tabs: [Text('Tab')],
          selectedIndex: 0,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(ClipRect), findsWidgets);
    });

    testWidgets('uses BackdropFilter for blur effect', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const AdaptiveGlassTabBar(
          tabs: [Text('Tab')],
          selectedIndex: 0,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('uses Row for tab layout', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const AdaptiveGlassTabBar(
          tabs: [Text('Tab 1'), Text('Tab 2')],
          selectedIndex: 0,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(Row), findsWidgets);
    });

    testWidgets('uses InkWell for tab tap handling', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const AdaptiveGlassTabBar(
          tabs: [Text('Tab 1'), Text('Tab 2')],
          selectedIndex: 0,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(InkWell), findsWidgets);
    });
  });
  group('showConfirmDialog', () {
    testWidgets('returns true when confirm button is tapped', (tester) async {
      late bool result;

      await tester.pumpWidget(createTestWidget(
        child: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              result = await showConfirmDialog(
                context: context,
                title: 'Delete',
                message: 'Are you sure?',
              );
            },
            child: const Text('Open Dialog'),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Are you sure?'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);

      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      expect(result, isTrue);
    });

    testWidgets('returns false when cancel button is tapped', (tester) async {
      late bool result;

      await tester.pumpWidget(createTestWidget(
        child: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              result = await showConfirmDialog(
                context: context,
                title: 'Delete',
                message: 'Are you sure?',
              );
            },
            child: const Text('Open Dialog'),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      expect(result, isFalse);
    });

    testWidgets('shows custom confirmLabel on confirm button', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showConfirmDialog(
              context: context,
              title: 'Action',
              message: 'Proceed?',
              confirmLabel: 'Do It',
            ),
            child: const Text('Open Dialog'),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Do It'), findsOneWidget);
      expect(find.text('Confirm'), findsNothing);
    });
  });

  group('showAdaptiveGlassSheet', () {
    testWidgets('shows a modal bottom sheet', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showAdaptiveGlassSheet(
              context: context,
              builder: (context) => const Text('Sheet Content'),
            ),
            child: const Text('Open Sheet'),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Sheet Content'), findsOneWidget);
    });

    testWidgets('sheet is dismissible by default', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showAdaptiveGlassSheet(
              context: context,
              builder: (context) => const SizedBox(height: 100, child: Text('Dismiss Me')),
            ),
            child: const Text('Open Sheet'),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Dismiss Me'), findsOneWidget);
    });

    testWidgets('sheet uses ClipRRect for rounded corners on glass platform', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showAdaptiveGlassSheet(
              context: context,
              builder: (context) => const Text('Glass Sheet'),
            ),
            child: const Text('Open Sheet'),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      expect(find.byType(ClipRRect), findsWidgets);
    });

    testWidgets('sheet uses BackdropFilter on glass platform', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showAdaptiveGlassSheet(
              context: context,
              builder: (context) => const Text('Blur Sheet'),
            ),
            child: const Text('Open Sheet'),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      expect(find.byType(BackdropFilter), findsWidgets);
    });

    testWidgets('sheet supports scroll controlled mode', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showAdaptiveGlassSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) => const SizedBox(height: 200, child: Text('Scroll Sheet')),
            ),
            child: const Text('Open Sheet'),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Scroll Sheet'), findsOneWidget);
    });
  });

  group('showAdaptiveGlassDialog', () {
    testWidgets('shows a dialog with builder content', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showAdaptiveGlassDialog(
              context: context,
              builder: (context) => const Text('Dialog Content'),
            ),
            child: const Text('Open Dialog'),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Dialog Content'), findsOneWidget);
    });

    testWidgets('shows title when provided', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showAdaptiveGlassDialog(
              context: context,
              title: 'Dialog Title',
              builder: (context) => const Text('Body'),
            ),
            child: const Text('Open Dialog'),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Dialog Title'), findsOneWidget);
      expect(find.text('Body'), findsOneWidget);
    });

    testWidgets('shows actions when provided', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showAdaptiveGlassDialog(
              context: context,
              builder: (context) => const Text('Body'),
              actions: [
                TextButton(
                  onPressed: () {},
                  child: const Text('Action 1'),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('Action 2'),
                ),
              ],
            ),
            child: const Text('Open Dialog'),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Action 1'), findsOneWidget);
      expect(find.text('Action 2'), findsOneWidget);
    });

    testWidgets('uses ClipRRect and BackdropFilter on glass platform', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showAdaptiveGlassDialog(
              context: context,
              builder: (context) => const Text('Glass Dialog'),
            ),
            child: const Text('Open Dialog'),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.byType(ClipRRect), findsWidgets);
      expect(find.byType(BackdropFilter), findsWidgets);
    });

    testWidgets('dialog without title omits title widget', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showAdaptiveGlassDialog(
              context: context,
              builder: (context) => const Text('No Title Body'),
            ),
            child: const Text('Open Dialog'),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('No Title Body'), findsOneWidget);
    });

    testWidgets('dialog without actions omits actions row', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showAdaptiveGlassDialog(
              context: context,
              title: 'Simple Dialog',
              builder: (context) => const Text('Simple Body'),
            ),
            child: const Text('Open Dialog'),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Simple Dialog'), findsOneWidget);
      expect(find.text('Simple Body'), findsOneWidget);
    });
  });

  group('showConfirmDialog edge cases', () {
    testWidgets('returns false when dismissed without tapping', (tester) async {
      late bool result;

      await tester.pumpWidget(createTestWidget(
        child: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              result = await showConfirmDialog(
                context: context,
                title: 'Test',
                message: 'Confirm?',
              );
            },
            child: const Text('Open Dialog'),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // The dialog has barrierDismissible: false, so we must tap cancel
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      expect(result, isFalse);
    });
  });

  // ── Material fallback tests (platformOverride = android) ──────────

  group('AdaptiveGlassContainer Material fallback', () {
    setUp(() => platformOverride = PlatformType.android);
    tearDown(() => platformOverride = null);

    testWidgets('renders Container without BackdropFilter on Android', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const AdaptiveGlassContainer(
          width: 100,
          height: 50,
          padding: EdgeInsets.all(8),
          margin: EdgeInsets.all(4),
          child: Text('Material Container'),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Material Container'), findsOneWidget);
      expect(find.byType(BackdropFilter), findsNothing);
      expect(find.byType(ClipRRect), findsNothing);
    });
  });

  group('AdaptiveGlassCard Material fallback', () {
    setUp(() => platformOverride = PlatformType.android);
    tearDown(() => platformOverride = null);

    testWidgets('renders Card with InkWell on Android', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(createTestWidget(
        child: AdaptiveGlassCard(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(12),
          onTap: () => tapped = true,
          child: const Text('Material Card'),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Material Card'), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(BackdropFilter), findsNothing);

      await tester.tap(find.text('Material Card'));
      await tester.pump();
      expect(tapped, isTrue);
    });
  });

  group('AdaptiveGlassButton Material fallback', () {
    setUp(() => platformOverride = PlatformType.android);
    tearDown(() => platformOverride = null);

    testWidgets('renders FilledButton when filled on Android', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: AdaptiveGlassButton(
          filled: true,
          onPressed: () {},
          child: const Text('Filled'),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(FilledButton), findsOneWidget);
      expect(find.byType(BackdropFilter), findsNothing);
    });

    testWidgets('renders TextButton when not filled on Android', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: AdaptiveGlassButton(
          onPressed: () {},
          child: const Text('Text'),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(TextButton), findsOneWidget);
      expect(find.byType(BackdropFilter), findsNothing);
    });
  });

  group('AdaptiveGlassIconButton Material fallback', () {
    setUp(() => platformOverride = PlatformType.android);
    tearDown(() => platformOverride = null);

    testWidgets('renders IconButton on Android', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: AdaptiveGlassIconButton(
          icon: Icons.settings,
          onPressed: () {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(IconButton), findsOneWidget);
      expect(find.byType(BackdropFilter), findsNothing);
      expect(find.byType(ClipOval), findsNothing);
    });
  });

  group('AdaptiveGlassBottomBar Material fallback', () {
    setUp(() => platformOverride = PlatformType.android);
    tearDown(() => platformOverride = null);

    testWidgets('renders BottomAppBar on Android', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const AdaptiveGlassBottomBar(
          padding: EdgeInsets.all(8),
          child: Text('Bottom Bar'),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Bottom Bar'), findsOneWidget);
      expect(find.byType(BottomAppBar), findsOneWidget);
      expect(find.byType(BackdropFilter), findsNothing);
    });
  });

  group('AdaptiveGlassAppBar Material fallback', () {
    setUp(() => platformOverride = PlatformType.android);
    tearDown(() => platformOverride = null);

    testWidgets('renders AppBar on Android', (tester) async {
      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          appBar: AdaptiveGlassAppBar(
            title: const Text('Title'),
            actions: [IconButton(icon: const Icon(Icons.add), onPressed: () {})],
            backgroundColor: Colors.blue,
          ),
          body: const Text('Body'),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Title'), findsOneWidget);
      expect(find.byType(BackdropFilter), findsNothing);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
