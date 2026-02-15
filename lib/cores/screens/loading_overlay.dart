// A loading overlay widget that shows a spinner on top of content.
import 'package:flutter/material.dart';

import 'package:glacial/cores/screens/animations.dart';

/// Shows a semi-transparent overlay with a centered spinner on top of [child].
///
/// Use this instead of replacing content with [ClockProgressIndicator] to keep
/// the app shell (sidebar, tabbar) visible during loading states.
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: ColoredBox(
              color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.7),
              child: const Center(child: ClockProgressIndicator()),
            ),
          ),
      ],
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
