// Global keyboard shortcuts wrapper for the GlacialHome shell.
//
// Uses a `HardwareKeyboard` handler so single-key shortcuts are detected
// app-wide on desktop regardless of which widget currently owns focus
// (mirrors Mastodon web's document-level listener). Key events are
// ignored while a text field owns focus so typing in composers, search
// boxes, etc. is never hijacked.
//
// Each shortcut commit adds one entry to `_buildBindings()` and one row
// to the `?` cheatsheet.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:glacial/cores/misc.dart';
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

  bool _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) return false;
    if (_textInputHasFocus) return false;
    if (!mounted) return false;

    final bool shift = HardwareKeyboard.instance.isShiftPressed;
    final bool meta = HardwareKeyboard.instance.isMetaPressed;
    final bool ctrl = HardwareKeyboard.instance.isControlPressed;
    final bool alt = HardwareKeyboard.instance.isAltPressed;
    logger.d('[shortcut] phys=${event.physicalKey.debugName} '
        'logical=${event.logicalKey.debugName} shift=$shift '
        'meta=$meta ctrl=$ctrl alt=$alt');
    // Don't swallow OS-level chords like Cmd+A, Ctrl+C, etc.
    if (meta || ctrl || alt) return false;

    final match = _bindings.firstWhere(
      (b) => b.physical == event.physicalKey && b.shift == shift,
      orElse: () => _NullBinding.instance,
    );
    if (identical(match, _NullBinding.instance)) return false;
    match.run(this);
    return true;
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
    final List<dynamic>? statuses = GlacialHome.getStatuses?.call();
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
    final List<dynamic>? statuses = GlacialHome.getStatuses?.call();
    if (idx == null || statuses == null || idx < 0 || idx >= statuses.length) return;
    context.push(RoutePath.status.path, extra: statuses[idx]);
  }

  void _composeNewPost() {
    final bool isSignedIn = ref.read(accessStatusProvider)?.accessToken?.isNotEmpty == true;
    if (!isSignedIn) return;
    context.push(RoutePath.post.path);
  }

  void _switchTab(int delta) {
    final TabController? controller = GlacialHome.activeTabController;
    final List<int>? visible = GlacialHome.activeVisibleIndexes?.call();
    if (controller == null || visible == null || visible.isEmpty) return;

    final int current = controller.index;
    final int pos = visible.indexOf(current);
    if (pos < 0) return;
    final int nextPos = (pos + delta) % visible.length;
    final int wrapped = nextPos < 0 ? nextPos + visible.length : nextPos;
    controller.animateTo(visible[wrapped]);
    GlacialHome.focusedStatusIndex.value = null;
  }

  void _moveFocus(int delta) {
    final List<dynamic>? statuses = GlacialHome.getStatuses?.call();
    if (statuses == null || statuses.isEmpty) return;

    final int current = GlacialHome.focusedStatusIndex.value ?? -1;
    int next;
    if (current < 0) {
      // First press selects the first visible item (or 0 as a fallback).
      final positions = GlacialHome.itemPositions?.itemPositions.value;
      next = (positions != null && positions.isNotEmpty)
          ? positions.first.index
          : 0;
    } else {
      next = current + delta;
    }
    next = next.clamp(0, statuses.length - 1);
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
    return widget.child;
  }
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

class _NullBinding extends _Binding {
  static final _NullBinding instance = _NullBinding();
  _NullBinding() : super(PhysicalKeyboardKey.escape, run: _noop);
  static void _noop(_AppShortcutsState _) {}
}

/// Rows rendered in the `?` cheatsheet. Each shortcut commit appends to
/// this list alongside its binding.
const List<_ShortcutRow> _shortcutRows = <_ShortcutRow>[
  _ShortcutRow(keys: <String>['?'], labelKey: _HelpLabel.help),
  _ShortcutRow(keys: <String>['.'], labelKey: _HelpLabel.refresh),
  _ShortcutRow(keys: <String>['j'], labelKey: _HelpLabel.nextPost),
  _ShortcutRow(keys: <String>['k'], labelKey: _HelpLabel.prevPost),
  _ShortcutRow(keys: <String>['Tab'], labelKey: _HelpLabel.nextTab),
  _ShortcutRow(keys: <String>['Shift', 'Tab'], labelKey: _HelpLabel.prevTab),
  _ShortcutRow(keys: <String>['/'], labelKey: _HelpLabel.focusSearch),
  _ShortcutRow(keys: <String>['n'], labelKey: _HelpLabel.composePost),
  _ShortcutRow(keys: <String>['o'], labelKey: _HelpLabel.openStatus),
  _ShortcutRow(keys: <String>['f'], labelKey: _HelpLabel.favourite),
  _ShortcutRow(keys: <String>['b'], labelKey: _HelpLabel.boost),
  _ShortcutRow(keys: <String>['r'], labelKey: _HelpLabel.reply),
  _ShortcutRow(keys: <String>['e'], labelKey: _HelpLabel.bookmark),
];

class _ShortcutHelpSheet extends StatelessWidget {
  const _ShortcutHelpSheet();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations? l10n = AppLocalizations.of(context);
    final String title = l10n?.txt_shortcuts_title ?? 'Keyboard shortcuts';

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ..._shortcutRows.map((row) => _buildRow(context, row)),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(BuildContext context, _ShortcutRow row) {
    final AppLocalizations? l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          for (final key in row.keys) ...[
            _KeyCap(text: key),
            const SizedBox(width: 6),
          ],
          const SizedBox(width: 8),
          Expanded(child: Text(row.labelKey.resolve(l10n))),
        ],
      ),
    );
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
  bookmark;

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
    }
  }
}

// vim: set ts=2 sw=2 sts=2 et:
