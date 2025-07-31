// The possible interactions of the timeline' status
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';

// The interaction bar that shows the all the possible actions for the current
// status, and wraps the interaction more button if there are more actions
// than the available space.
class InteractionBar extends ConsumerWidget {
  final StatusSchema schema;
  final ValueChanged<StatusSchema>? onReload;
  final VoidCallback? onDeleted;

  const InteractionBar({
    super.key,
    required this.schema,
    this.onReload,
    this.onDeleted,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double itemWidth = 68.0;
    final List<StatusInteraction> actions = StatusInteraction.values;

    return LayoutBuilder(
      builder: (context, constraints) {
        final int builtinActionsCount = actions.where((action) => action.isBuiltIn).length;
        final int maxItems = min((constraints.maxWidth / itemWidth).floor(), builtinActionsCount);
        final List<StatusInteraction> visibleActions = actions.take(maxItems).toList();
        final List<StatusInteraction> remainingActions = actions.skip(maxItems).toList();

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ... visibleActions.map((action) => Interaction(
                schema: schema,
                action: action,
                onReload: onReload,
                onDeleted: onDeleted,
            )),
            InteractionMore(schema: schema, actions: remainingActions, onReload: onReload, onDeleted: onDeleted),
          ],
        );
      },
    );
  }
}

// The interaction more button that shows the remains possible actions
class InteractionMore extends StatelessWidget {
  final StatusSchema schema;
  final List<StatusInteraction> actions;
  final ValueChanged<StatusSchema>? onReload;
  final VoidCallback? onDeleted;

  const InteractionMore({
    super.key,
    required this.schema,
    required this.actions,
    this.onReload,
    this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) {
      return const SizedBox.shrink();
    }

    return PopupMenuButton(
      icon: const Icon(Icons.more_horiz),
      tooltip: '', // for disabling the tooltip
      itemBuilder: (context) {
        return actions.map((action) {
          return PopupMenuItem(
            value: action,
            child: Interaction(
              schema: schema,
              action: action,
              isCompact: false,
              onPressed: () => Navigator.pop(context),
              onDeleted: onDeleted,
            ),
          );
        }).toList();
      },
    );
  }
}

// The interaction button that interacts with the current status, which
// may disable the button if the action is not supported for now.
class Interaction extends StatefulWidget {
  final StatusSchema schema;
  final StatusInteraction action;
  final bool isCompact;
  final VoidCallback? onPressed;
  final ValueChanged<StatusSchema>? onReload;
  final VoidCallback? onDeleted;

  const Interaction({
    super.key,
    required this.schema,
    required this.action,
    this.isCompact = true,
    this.onPressed,
    this.onReload,
    this.onDeleted,
  });

  @override
  State<Interaction> createState() => _InteractionState();
}

class _InteractionState extends State<Interaction> {
  @override
  Widget build(BuildContext context) {
    return widget.isCompact ? buildCompactIcon() : buildFullButton(context);
  }

  // Build the compact icon for the interaction that only show the icon and the
  // count of the interaction.
  Widget buildCompactIcon() {
    return TextButton.icon(
      label: count == null ? const SizedBox.shrink() : Text(count.toString()),
      icon: Icon(icon, size: tabSize, color: color),
      style: TextButton.styleFrom(foregroundColor: color),
      onPressed: isActive ? onPressed : null,
    );
  }

  // Build the normal icon for the interaction that shows the icon and the
  // action text.
  Widget buildFullButton(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: tabSize),
      title: Text(widget.action.tooltip(context)),
      textColor: color,
      iconColor: color,
      onTap: isActive ? onPressed : null,
    );
  }

  // The action now is available or activated.
  bool get isActive {
    switch (widget.action) {
      case StatusInteraction.share:
        return true;
      default:
        return false;
    }
  }

  // Get the icon for the interaction, which may be active or not based on the
  // current status of the interaction.
  IconData get icon {
    return widget.action.icon(active: false); // Replace with actual logic to determine active state
  }

  // The total count of the interaction of the status, if applicable.
  int? get count {
    switch (widget.action) {
      case StatusInteraction.reply:
      case StatusInteraction.reblog:
      case StatusInteraction.favourite:
      case StatusInteraction.bookmark:
        return 0;
      default:
        return null; // No count for other actions
    }
  }

  // Get the icon color based on the type of the interaction.
  Color get color {
    if (!isActive) {
      return Theme.of(context).disabledColor; // Use disabled color if not active
    }

    switch (widget.action) {
      case StatusInteraction.mute:
      case StatusInteraction.block:
      case StatusInteraction.edit:
      case StatusInteraction.delete:
        return Theme.of(context).colorScheme.error;
      default:
        return Theme.of(context).colorScheme.onSurface;
    }
  }

  void onPressed() {
    switch (widget.action) {
      case StatusInteraction.reply:
      case StatusInteraction.reblog:
      case StatusInteraction.favourite:
      case StatusInteraction.bookmark:
      case StatusInteraction.edit:
        widget.onPressed?.call();
        break;
      case StatusInteraction.delete:
        widget.onDeleted?.call();
        break;
      case StatusInteraction.share:
        final String text = AppLocalizations.of(context)?.msg_copied_to_clipboard ?? "Copy to clipboard";

        Clipboard.setData(ClipboardData(text: widget.schema.uri));
        showSnackbar(context, text);
      default:
        break;
    }
  }
}

// vim: set ts=2 sw=2 sts=2 et:
