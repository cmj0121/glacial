// Visibility control widgets for status content (sensitive/spoiler).
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:glacial/core.dart';

/// Default icon size for visibility widgets.
const double _iconSize = 16.0;

/// Widget that blurs sensitive content until user taps to reveal.
class SensitiveView extends StatefulWidget {
  final Widget child;
  final bool isSensitive;

  const SensitiveView({
    super.key,
    required this.child,
    this.isSensitive = false,
  });

  @override
  State<SensitiveView> createState() => _SensitiveViewState();
}

class _SensitiveViewState extends State<SensitiveView> {
  late bool isSensitiveVisible = widget.isSensitive;

  @override
  Widget build(BuildContext context) {
    return InkWellDone(
      onTap: isSensitiveVisible ? () => setState(() => isSensitiveVisible = !isSensitiveVisible) : null,
      child: isSensitiveVisible ? buildContent() : widget.child,
    );
  }

  Widget buildContent() {
    return Stack(
        alignment: Alignment.topCenter,
        children: [
          widget.child,
          Positioned.fill(child: buildCover()),
        ],
    );
  }

  Widget buildCover() {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
          alignment: Alignment.center,
          child: Icon(Icons.visibility_off_outlined, size: _iconSize, color: Theme.of(context).disabledColor),
        ),
      ),
    );
  }
}

/// Widget that hides spoiler content behind a toggle button.
class SpoilerView extends StatefulWidget {
  final String? spoiler;
  final Widget child;

  const SpoilerView({
    super.key,
    this.spoiler,
    required this.child,
  });

  @override
  State<SpoilerView> createState() => _SpoilerViewState();
}

class _SpoilerViewState extends State<SpoilerView> {
  bool isVisible = false;

  @override
  Widget build(BuildContext context) {
    return widget.spoiler?.isNotEmpty == true ? buildContent() : widget.child;
  }

  Widget buildContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          InkWellDone(
            onDoubleTap: () => setState(() => isVisible = !isVisible),
            child: buildSpoiler(),
          ),
          Visibility(
            visible: isVisible,
            child: widget.child,
          ),
        ],
      ),
    );
  }

  Widget buildSpoiler() {
    final String text = isVisible
        ? AppLocalizations.of(context)?.txt_show_less ?? "Show less"
        : AppLocalizations.of(context)?.txt_show_more ?? "Show more";

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        border: Border.all(width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.spoiler ?? ""),
            const SizedBox(height: 8),
            Text(text, style: TextStyle(color: Theme.of(context).colorScheme.primary)),
          ],
        ),
      ),
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
