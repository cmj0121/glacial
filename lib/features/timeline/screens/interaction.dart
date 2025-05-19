// The possible interactions of the timeline' status
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/timeline/models/core.dart';

// The interaction bar that shows the all the possible actions for the current
// status, and wraps the interaction more button if there are more actions
// than the available space.
class InteractionBar extends StatelessWidget {
  final StatusSchema schema;
  final double itemWidth;

  const InteractionBar({
    super.key,
    required this.schema,
    this.itemWidth = 68,
  });

  @override
  Widget build(BuildContext context) {
    final List<StatusInteraction> actions = StatusInteraction.values;

    return LayoutBuilder(
      builder: (context, constraints) {
        final int maxItems = min((constraints.maxWidth / itemWidth).floor(), actions.length);
        final bool needsMoreSpace = maxItems < actions.length;
        final List<StatusInteraction> visibleActions = actions.sublist(0, needsMoreSpace ? maxItems - 1 : maxItems)
            .where((action) => !action.isDangerous)
            .toList();
        final List<StatusInteraction> moreActions = actions.sublist(visibleActions.length);

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ... visibleActions.map((action) {
            return Interaction(
                schema: schema,
                action: action,
                maxWidth: itemWidth,
                isCompact: true,
              );
            }),
            InteractionMore(
              schema: schema,
              actions: moreActions,
              itemWidth: itemWidth,
            ),
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
  final double itemWidth;

  const InteractionMore({
    super.key,
    required this.schema,
    required this.actions,
    this.itemWidth = 68,
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
              maxWidth: itemWidth,
              isCompact: false,
              onPressed: () => Navigator.pop(context),
            ),
          );
        }).toList();
      },
    );
  }
}

// The interaction button that interacts with the current status, which
// may disable the button if the action is not supported for now.
class Interaction extends ConsumerStatefulWidget {
  final StatusSchema schema;
  final StatusInteraction action;
  final double maxWidth;
  final double iconSize;
  final bool isCompact;
  final VoidCallback? onPressed;

  const Interaction({
    super.key,
    required this.schema,
    required this.action,
    this.maxWidth = 68,
    this.iconSize = 24,
    this.isCompact = false,
    this.onPressed,
  });

  @override
  ConsumerState<Interaction> createState() => _InteractionState();
}

class _InteractionState extends ConsumerState<Interaction> {
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: widget.maxWidth,
      ),
      child: buildContent(),
    );
  }

  Widget buildContent() {
    final String? accessToken = ref.read(currentAccessTokenProvider);
    final bool isEnabled = accessToken != null || widget.action.supportAnonymous;
    final Color color = iconColor ?? Theme.of(context).colorScheme.secondary;
    final TextStyle? style = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: color,
      fontSize: 12,
      fontWeight: FontWeight.bold,
    );

    if (widget.isCompact) {
      return Tooltip(
        message: text,
        child: TextButton.icon(
          label: count != null ? Text("$count", style: style) : const SizedBox.shrink(),
          icon: Icon(icon, color: color, size: widget.iconSize),
          style: TextButton.styleFrom(
            foregroundColor: Colors.transparent,
            overlayColor: Colors.transparent,
          ),
          onPressed: isEnabled ? onPressed : null,
        ),
      );
    }

    return ListTile(
      leading: Icon(icon, color: color, size: widget.iconSize),
      title: Text(text, style: style),
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
    if (widget.action.isDangerous) {
      return Theme.of(context).colorScheme.error;
    }

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

  // Ge the action l10n text based on the action.
  String get text {
    switch (widget.action) {
      case StatusInteraction.reply:
        return AppLocalizations.of(context)?.btn_reply ?? "Reply";
      case StatusInteraction.reblog:
        return AppLocalizations.of(context)?.btn_reblog ?? "Reblog";
      case StatusInteraction.favourite:
        return AppLocalizations.of(context)?.btn_favourite ?? "Favourite";
      case StatusInteraction.bookmark:
        return AppLocalizations.of(context)?.btn_bookmark ?? "Bookmark";
      case StatusInteraction.share:
        return AppLocalizations.of(context)?.btn_share ?? "Share";
      case StatusInteraction.mute:
        return AppLocalizations.of(context)?.btn_mute ?? "Mute";
      case StatusInteraction.block:
        return AppLocalizations.of(context)?.btn_block ?? "Block";
      case StatusInteraction.delete:
        return AppLocalizations.of(context)?.btn_delete ?? "Delete";
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

    widget.onPressed?.call();
  }
}

// vim: set ts=2 sw=2 sts=2 et:
