// Global keyboard shortcuts wrapper for the GlacialHome shell.
//
// Wraps its child in a `Focus` + `CallbackShortcuts` chain so single-key
// shortcuts work across all shell tabs. Key events are ignored while a
// text field (or any widget requesting raw keyboard input) owns focus.
//
// Each shortcut commit adds one entry to `_buildBindings()` and one row
// to the `?` cheatsheet.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:glacial/cores/screens/glass_sheets.dart';
import 'package:glacial/l10n/app_localizations.dart';

class AppShortcuts extends StatefulWidget {
  final Widget child;

  const AppShortcuts({super.key, required this.child});

  @override
  State<AppShortcuts> createState() => _AppShortcutsState();
}

class _AppShortcutsState extends State<AppShortcuts> {
  final FocusNode _focusNode = FocusNode(debugLabel: 'AppShortcuts');

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
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

  Map<ShortcutActivator, VoidCallback> _buildBindings() {
    return <ShortcutActivator, VoidCallback>{
      const SingleActivator(LogicalKeyboardKey.slash, shift: true): () {
        if (_textInputHasFocus) return;
        _showHelpSheet();
      },
    };
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
    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      child: CallbackShortcuts(
        bindings: _buildBindings(),
        child: widget.child,
      ),
    );
  }
}

/// Rows rendered in the `?` cheatsheet. Each shortcut commit appends to
/// this list alongside its binding.
const List<_ShortcutRow> _shortcutRows = <_ShortcutRow>[
  _ShortcutRow(keys: <String>['?'], labelKey: _HelpLabel.help),
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
  help;

  String resolve(AppLocalizations? l10n) {
    switch (this) {
      case _HelpLabel.help:
        return l10n?.txt_shortcut_help ?? 'Show keyboard shortcuts';
    }
  }
}

// vim: set ts=2 sw=2 sts=2 et:
