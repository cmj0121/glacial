// Global keyboard shortcuts wrapper for the shell. Uses a
// HardwareKeyboard handler so single-key shortcuts are detected
// app-wide on desktop regardless of which widget currently owns focus
// (mirrors Mastodon web's document-level listener). Key events are
// ignored while a text field owns focus so typing in composers, search
// boxes, etc. is never hijacked.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:glacial/cores/routes.dart';
import 'package:glacial/cores/screens/glass_sheets.dart';
import 'package:glacial/cores/storage.dart';
import 'package:glacial/features/glacial/screens/home.dart';
import 'package:glacial/features/timeline/models/interaction.dart';
import 'package:glacial/l10n/app_localizations.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class AppShortcuts extends ConsumerStatefulWidget {
  final Widget child;

  const AppShortcuts({super.key, required this.child});

  @override
  ConsumerState<AppShortcuts> createState() => _AppShortcutsState();
}

class _AppShortcutsState extends ConsumerState<AppShortcuts> {
  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handleKey);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKey);
    super.dispose();
  }

  // Paths on which the compose form is rendered. Routes inside the
  // ShellRoute swap V2HomeShell's child rather than pushing over it,
  // so ModalRoute.isCurrent stays true — we need an explicit path check.
  static const Set<String> _composePaths = <String>{
    '/home/post',
    '/home/post/quote',
    '/home/post/draft',
    '/home/post/shared',
    '/home/edit',
  };

  bool _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) return false;
    if (!mounted) return false;
    final bool isTopmost = ModalRoute.of(context)?.isCurrent ?? false;
    final bool onComposeRoute = _composePaths.contains(
      GoRouter.of(context).state.uri.path,
    );

    // Esc stays active everywhere: blur text input / close sheet, and
    // on a compose route it also pops back to the previous screen.
    if (event.physicalKey == PhysicalKeyboardKey.escape) {
      _handleEscape(onComposeRoute: onComposeRoute);
      return true;
    }

    if (!isTopmost || onComposeRoute) return false;
    if (_textInputHasFocus) return false;

    final keyboard = HardwareKeyboard.instance;
    // Don't swallow OS-level chords like Cmd+A, Ctrl+C, etc.
    if (keyboard.isMetaPressed || keyboard.isControlPressed || keyboard.isAltPressed) {
      return false;
    }
    final bool shift = keyboard.isShiftPressed;

    for (final b in _bindings) {
      if (b.physical == event.physicalKey && b.shift == shift) {
        b.run(this);
        return true;
      }
    }
    return false;
  }

  void _handleEscape({bool onComposeRoute = false}) {
    GlacialHome.onCloseSearch?.call();
    final FocusNode? primary = FocusManager.instance.primaryFocus;
    final bool hadTextFocus = primary?.context?.widget is EditableText;
    primary?.unfocus();
    // If the user was typing, one Esc blurs; a second Esc closes the
    // composer. If nothing was focused and we're on a compose route,
    // pop straight away.
    if (!hadTextFocus && onComposeRoute && context.canPop()) {
      context.pop();
    }
  }

  // Skip shortcuts while a text field owns focus so typing in composers,
  // search boxes, etc. is never hijacked.
  bool get _textInputHasFocus {
    final FocusNode? primary = FocusManager.instance.primaryFocus;
    if (primary == null) return false;
    final BuildContext? ctx = primary.context;
    if (ctx == null) return false;
    return ctx.widget is EditableText;
  }

  static final List<_Binding> _bindings = <_Binding>[
    _Binding(PhysicalKeyboardKey.slash, shift: true, run: (s) => s._showHelpSheet()),
    _Binding(PhysicalKeyboardKey.slash, run: (s) => GlacialHome.onFocusSearch?.call()),
    _Binding(PhysicalKeyboardKey.period, run: (s) => s._refreshAndScrollTop()),
    _Binding(PhysicalKeyboardKey.keyJ, run: (s) => s._moveFocus(1)),
    _Binding(PhysicalKeyboardKey.arrowDown, run: (s) => s._moveFocus(1)),
    _Binding(PhysicalKeyboardKey.keyK, run: (s) => s._moveFocus(-1)),
    _Binding(PhysicalKeyboardKey.arrowUp, run: (s) => s._moveFocus(-1)),
    _Binding(PhysicalKeyboardKey.tab, run: (s) => s._switchTab(1)),
    _Binding(PhysicalKeyboardKey.tab, shift: true, run: (s) => s._switchTab(-1)),
    _Binding(PhysicalKeyboardKey.arrowRight, run: (s) => s._switchTab(1)),
    _Binding(PhysicalKeyboardKey.arrowLeft, run: (s) => s._switchTab(-1)),
    _Binding(PhysicalKeyboardKey.keyN, run: (s) => s._composeNewPost()),
    _Binding(PhysicalKeyboardKey.keyO, run: (s) => s._openFocusedStatus()),
    _Binding(PhysicalKeyboardKey.enter, run: (s) => s._openFocusedStatus()),
    _Binding(PhysicalKeyboardKey.numpadEnter, run: (s) => s._openFocusedStatus()),
    _Binding(PhysicalKeyboardKey.keyF, run: (s) => s._interactFocused(StatusInteraction.favourite)),
    _Binding(PhysicalKeyboardKey.keyB, run: (s) => s._interactFocused(StatusInteraction.reblog)),
    _Binding(PhysicalKeyboardKey.keyR, run: (s) => s._replyToFocused()),
    _Binding(PhysicalKeyboardKey.keyE, run: (s) => s._interactFocused(StatusInteraction.bookmark)),
  ];

  void _replyToFocused() {
    final int? idx = GlacialHome.focusedStatusIndex.value;
    final statuses = GlacialHome.getStatuses?.call();
    if (idx == null || statuses == null || idx < 0 || idx >= statuses.length) return;
    final bool isSignedIn = ref.read(accessStatusProvider)?.accessToken?.isNotEmpty == true;
    if (!isSignedIn) return;
    context.push(RoutePath.post.path, extra: statuses[idx]);
  }

  void _interactFocused(StatusInteraction action) {
    final int? idx = GlacialHome.focusedStatusIndex.value;
    if (idx == null) return;
    GlacialHome.onInteractStatus?.call(idx, action);
  }

  void _openFocusedStatus() {
    final int? idx = GlacialHome.focusedStatusIndex.value;
    final statuses = GlacialHome.getStatuses?.call();
    if (idx == null || statuses == null || idx < 0 || idx >= statuses.length) return;
    context.push(RoutePath.status.path, extra: statuses[idx]);
  }

  void _composeNewPost() {
    final bool isSignedIn = ref.read(accessStatusProvider)?.accessToken?.isNotEmpty == true;
    if (!isSignedIn) return;
    context.push(RoutePath.post.path);
  }

  void _switchTab(int delta) {
    final cycler = GlacialHome.onTabSwitch;
    if (cycler == null) return;
    cycler(delta);
    GlacialHome.focusedStatusIndex.value = null;
  }

  void _moveFocus(int delta) {
    final statuses = GlacialHome.getStatuses?.call();
    if (statuses == null || statuses.isEmpty) return;

    final int current = GlacialHome.focusedStatusIndex.value ?? -1;
    final int next = (current < 0 ? 0 : current + delta)
        .clamp(0, statuses.length - 1);
    if (next == current) return;

    // Pause viewport-based auto-focus until the scroll animation
    // completes so rapid j/k presses advance past N -> N+1 -> N+2 cleanly
    // instead of being reset to the previously-dominant post mid-scroll.
    GlacialHome.suppressAutoFocusUntil =
        DateTime.now().add(const Duration(milliseconds: 350));
    GlacialHome.focusedStatusIndex.value = next;

    final ItemScrollController? scroll = GlacialHome.itemScrollToTop;
    if (scroll?.isAttached == true) {
      scroll!.scrollTo(
        index: next,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        alignment: 0.1,
      );
    }
  }

  Future<void> _refreshAndScrollTop() async {
    final ItemScrollController? scroll = GlacialHome.itemScrollToTop;
    if (scroll?.isAttached == true) {
      await scroll!.scrollTo(
        index: 0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
    await GlacialHome.onRefresh?.call();
  }

  void _showHelpSheet() {
    showAdaptiveGlassSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _ShortcutHelpSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Suppress Flutter's default Tab/Shift+Tab focus traversal so Tab is
    // reserved for tab-view cycling in this shell. The Tab switching
    // itself is handled by the HardwareKeyboard handler above.
    return Actions(
      actions: <Type, Action<Intent>>{
        NextFocusIntent: _NoopAction<NextFocusIntent>(),
        PreviousFocusIntent: _NoopAction<PreviousFocusIntent>(),
      },
      child: widget.child,
    );
  }
}

class _NoopAction<T extends Intent> extends Action<T> {
  @override
  Object? invoke(T intent) => null;
}

/// Static binding row for the app-wide key handler. Uses the physical
/// key so bindings stay stable regardless of keyboard layout or the
/// shifted character (e.g. Shift+/ produces logical `question` on
/// macOS but physical `slash`).
class _Binding {
  final PhysicalKeyboardKey physical;
  final bool shift;
  final void Function(_AppShortcutsState state) run;
  const _Binding(this.physical, {this.shift = false, required this.run});
}

/// Shortcut rows grouped by purpose so the cheatsheet is scannable.
const List<_ShortcutSection> _shortcutSections = <_ShortcutSection>[
  _ShortcutSection(_SectionLabel.navigation, <_ShortcutRow>[
    _ShortcutRow(keys: <String>['j'], labelKey: _HelpLabel.nextPost),
    _ShortcutRow(keys: <String>['k'], labelKey: _HelpLabel.prevPost),
    _ShortcutRow(keys: <String>['Tab'], labelKey: _HelpLabel.nextTab),
    _ShortcutRow(keys: <String>['Shift', 'Tab'], labelKey: _HelpLabel.prevTab),
    _ShortcutRow(keys: <String>['o'], labelKey: _HelpLabel.openStatus),
    _ShortcutRow(keys: <String>['/'], labelKey: _HelpLabel.focusSearch),
  ]),
  _ShortcutSection(_SectionLabel.actions, <_ShortcutRow>[
    _ShortcutRow(keys: <String>['n'], labelKey: _HelpLabel.composePost),
    _ShortcutRow(keys: <String>['r'], labelKey: _HelpLabel.reply),
    _ShortcutRow(keys: <String>['f'], labelKey: _HelpLabel.favourite),
    _ShortcutRow(keys: <String>['b'], labelKey: _HelpLabel.boost),
    _ShortcutRow(keys: <String>['e'], labelKey: _HelpLabel.bookmark),
  ]),
  _ShortcutSection(_SectionLabel.general, <_ShortcutRow>[
    _ShortcutRow(keys: <String>['.'], labelKey: _HelpLabel.refresh),
    _ShortcutRow(keys: <String>['?'], labelKey: _HelpLabel.help),
    _ShortcutRow(keys: <String>['Esc'], labelKey: _HelpLabel.escape),
  ]),
];

class _ShortcutHelpSheet extends StatelessWidget {
  const _ShortcutHelpSheet();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations? l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final String title = l10n?.txt_shortcuts_title ?? 'Keyboard shortcuts';

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            )),
            const SizedBox(height: 4),
            Container(
              width: 32,
              height: 2,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
            const SizedBox(height: 20),
            for (int i = 0; i < _shortcutSections.length; i++) ...[
              if (i > 0) const SizedBox(height: 20),
              _buildSection(context, _shortcutSections[i], l10n),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, _ShortcutSection section, AppLocalizations? l10n) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          section.label.resolve(l10n),
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        ...section.rows.map((row) => _buildRow(context, row, l10n)),
      ],
    );
  }

  Widget _buildRow(BuildContext context, _ShortcutRow row, AppLocalizations? l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          for (final key in row.keys) ...[
            _KeyCap(text: key),
            const SizedBox(width: 6),
          ],
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              row.labelKey.resolve(l10n),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShortcutSection {
  final _SectionLabel label;
  final List<_ShortcutRow> rows;
  const _ShortcutSection(this.label, this.rows);
}

enum _SectionLabel {
  navigation,
  actions,
  general;

  String resolve(AppLocalizations? l10n) {
    switch (this) {
      case _SectionLabel.navigation:
        return l10n?.txt_shortcut_section_navigation ?? 'NAVIGATION';
      case _SectionLabel.actions:
        return l10n?.txt_shortcut_section_actions ?? 'ACTIONS';
      case _SectionLabel.general:
        return l10n?.txt_shortcut_section_general ?? 'GENERAL';
    }
  }
}

class _KeyCap extends StatelessWidget {
  final String text;
  const _KeyCap({required this.text});

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontFamily: 'monospace',
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _ShortcutRow {
  final List<String> keys;
  final _HelpLabel labelKey;
  const _ShortcutRow({required this.keys, required this.labelKey});
}

enum _HelpLabel {
  help,
  refresh,
  nextPost,
  prevPost,
  nextTab,
  prevTab,
  focusSearch,
  composePost,
  openStatus,
  favourite,
  boost,
  reply,
  bookmark,
  escape;

  String resolve(AppLocalizations? l10n) {
    switch (this) {
      case _HelpLabel.help:
        return l10n?.txt_shortcut_help ?? 'Show keyboard shortcuts';
      case _HelpLabel.refresh:
        return l10n?.txt_shortcut_refresh ?? 'Refresh and scroll to top';
      case _HelpLabel.nextPost:
        return l10n?.txt_shortcut_next_post ?? 'Next post';
      case _HelpLabel.prevPost:
        return l10n?.txt_shortcut_prev_post ?? 'Previous post';
      case _HelpLabel.nextTab:
        return l10n?.txt_shortcut_next_tab ?? 'Next tab';
      case _HelpLabel.prevTab:
        return l10n?.txt_shortcut_prev_tab ?? 'Previous tab';
      case _HelpLabel.focusSearch:
        return l10n?.txt_shortcut_focus_search ?? 'Focus search';
      case _HelpLabel.composePost:
        return l10n?.txt_shortcut_compose_post ?? 'Compose new post';
      case _HelpLabel.openStatus:
        return l10n?.txt_shortcut_open_status ?? 'Open focused post';
      case _HelpLabel.favourite:
        return l10n?.txt_shortcut_favourite ?? 'Favourite focused post';
      case _HelpLabel.boost:
        return l10n?.txt_shortcut_boost ?? 'Boost focused post';
      case _HelpLabel.reply:
        return l10n?.txt_shortcut_reply ?? 'Reply to focused post';
      case _HelpLabel.bookmark:
        return l10n?.txt_shortcut_bookmark ?? 'Bookmark focused post';
      case _HelpLabel.escape:
        return l10n?.txt_shortcut_escape ?? 'Close search or blur input';
    }
  }
}

// vim: set ts=2 sw=2 sts=2 et:
