// Accessibility helpers for semantic labels and screen reader support.
import 'package:flutter/material.dart';

/// A wrapper widget that adds semantic labels to any child widget.
/// Use this to improve accessibility for icons and interactive elements.
class SemanticIcon extends StatelessWidget {
  final Widget child;
  final String label;
  final bool excludeSemantics;

  const SemanticIcon({
    super.key,
    required this.child,
    required this.label,
    this.excludeSemantics = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      excludeSemantics: excludeSemantics,
      child: child,
    );
  }
}

/// A tooltip with improved accessibility that includes semantic information.
class AccessibleTooltip extends StatelessWidget {
  final String message;
  final Widget child;
  final String? semanticLabel;

  const AccessibleTooltip({
    super.key,
    required this.message,
    required this.child,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel ?? message,
      child: Tooltip(
        message: message,
        child: child,
      ),
    );
  }
}

/// A dismissible widget with semantic information for screen readers.
class AccessibleDismissible extends StatelessWidget {
  final Key dismissKey;
  final Widget child;
  final DismissDirection direction;
  final Future<bool?> Function(DismissDirection)? confirmDismiss;
  final void Function(DismissDirection)? onDismissed;
  final String? dismissLabel;

  const AccessibleDismissible({
    super.key,
    required this.dismissKey,
    required this.child,
    this.direction = DismissDirection.horizontal,
    this.confirmDismiss,
    this.onDismissed,
    this.dismissLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      onDismiss: dismissLabel != null ? () {} : null,
      hint: dismissLabel,
      child: Dismissible(
        key: dismissKey,
        direction: direction,
        confirmDismiss: confirmDismiss,
        onDismissed: onDismissed,
        child: child,
      ),
    );
  }
}

/// Extension to easily add semantic labels to Icon widgets.
extension IconAccessibility on Icon {
  Widget withSemantics(String label) {
    return Semantics(
      label: label,
      child: this,
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
