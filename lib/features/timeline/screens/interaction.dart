// The possible interactions of the timeline' status
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/timeline/models/core.dart';

class InteractionBar extends StatelessWidget {
  final StatusSchema schema;

  const InteractionBar({
    super.key,
    required this.schema,
  });

  @override
  Widget build(BuildContext context) {
    final List<StatusInteraction> actions = StatusInteraction.values;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: actions.map((action) => Interaction(schema: schema, action: action)).toList(),
    );
  }
}

class Interaction extends ConsumerStatefulWidget {
  final StatusSchema schema;
  final StatusInteraction action;
  final double iconSize;

  const Interaction({
    super.key,
    required this.schema,
    required this.action,
    this.iconSize = 24,
  });

  @override
  ConsumerState<Interaction> createState() => _InteractionState();
}

class _InteractionState extends ConsumerState<Interaction> {
  @override
  Widget build(BuildContext context) {
    final String? accessToken = ref.read(currentAccessTokenProvider);
    final bool isEnabled = accessToken != null || widget.action.supportAnonymous;
    final Color color = iconColor ?? Theme.of(context).colorScheme.secondary;
    final TextStyle? style = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: color,
      fontSize: 12,
      fontWeight: FontWeight.bold,
    );

    return TextButton.icon(
      label: count != null ? Text("$count", style: style) : const SizedBox.shrink(),
      icon: Icon(icon, color: color, size: widget.iconSize),
      onPressed: isEnabled ? onPressed : null,
    );
  }

  // Get the icon baed on the action.
  IconData get icon {
    switch (widget.action) {
      case StatusInteraction.reblog:
        return (widget.schema.reblogged ?? false) ? widget.action.activeIcon : widget.action.icon;
      case StatusInteraction.favourite:
        return (widget.schema.favourited ?? false) ? widget.action.activeIcon : widget.action.icon;
      case StatusInteraction.bookmark:
        return (widget.schema.bookmarked ?? false) ? widget.action.activeIcon : widget.action.icon;
      default:
        return widget.action.icon;
    }
  }

  // Get the color of the icon based on the action and the status
  // interaction state.
  Color? get iconColor {
    switch (widget.action) {
      case StatusInteraction.reblog:
        return (widget.schema.reblogged ?? false) ? Theme.of(context).colorScheme.tertiary : null;
      case StatusInteraction.favourite:
        return (widget.schema.favourited ?? false) ? Theme.of(context).colorScheme.tertiary : null;
      case StatusInteraction.bookmark:
        return (widget.schema.bookmarked ?? false) ? Theme.of(context).colorScheme.tertiary : null;
      default:
        return null;
    }
  }

  // Get the count of interaction based on the action.
  int? get count {
    switch (widget.action) {
      case StatusInteraction.reply:
        return widget.schema.repliesCount;
      case StatusInteraction.reblog:
        return widget.schema.reblogsCount;
      case StatusInteraction.favourite:
        return widget.schema.favouritesCount;
      default:
        return null;
    }
  }

  // Interactive with the current status
  void onPressed() async {
    switch (widget.action) {
      case StatusInteraction.share:
        final String text = AppLocalizations.of(context)?.txt_copied_to_clipboard ?? "Copy to clipboard";

        Clipboard.setData(ClipboardData(text: widget.schema.uri));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(text),
          ),
        );
      default:
        logger.i('not implemented yet');
    }
  }
}


// vim: set ts=2 sw=2 sts=2 et:
