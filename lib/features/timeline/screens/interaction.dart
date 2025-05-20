// The possible interactions of the timeline' status
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/glacial/models/server.dart';
import 'package:glacial/features/timeline/models/core.dart';

// The interaction bar that shows the all the possible actions for the current
// status, and wraps the interaction more button if there are more actions
// than the available space.
class InteractionBar extends ConsumerWidget {
  final StatusSchema schema;
  final double itemWidth;
  final ValueChanged<StatusSchema>? onReload;
  final VoidCallback? onDeleted;

  const InteractionBar({
    super.key,
    required this.schema,
    this.itemWidth = 68,
    this.onReload,
    this.onDeleted,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AccountSchema? account = ref.read(currentUserProvider);
    final List<StatusInteraction> actions = StatusInteraction.values.where((v) {
      return v != StatusInteraction.delete || (schema.account.id == account?.id);
    }).toList();

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
                isCompact: true,
                onReload: onReload,
                onDeleted: onDeleted,
              );
            }),
            InteractionMore(
              schema: schema,
              actions: moreActions,
              onReload: onReload,
              onDeleted: onDeleted,
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
class Interaction extends ConsumerStatefulWidget {
  final StatusSchema schema;
  final StatusInteraction action;
  final double iconSize;
  final bool isCompact;
  final VoidCallback? onPressed;
  final ValueChanged<StatusSchema>? onReload;
  final VoidCallback? onDeleted;

  const Interaction({
    super.key,
    required this.schema,
    required this.action,
    this.iconSize = 24,
    this.isCompact = false,
    this.onPressed,
    this.onReload,
    this.onDeleted,
  });

  @override
  ConsumerState<Interaction> createState() => _InteractionState();
}

class _InteractionState extends ConsumerState<Interaction> {
  @override
  Widget build(BuildContext context) {
    final String? accessToken = ref.read(currentAccessTokenProvider);
    final bool isEnabled = accessToken != null || widget.action.supportAnonymous;

    return widget.isCompact ? buildCompactIcon(isEnabled) : buildNormalIcon(isEnabled);
  }

  // Build the compact icon for the interaction that only show the icon and the
  // count of the interaction.
  Widget buildCompactIcon(bool isEnabled) {
    final Widget counter = count == null ? const SizedBox.shrink() : Text("$count");

    return Tooltip(
      message: text,
      child: TextButton.icon(
        label: counter,
        icon: Icon(icon, size: widget.iconSize),
        style: TextButton.styleFrom(
          foregroundColor: isEnabled ? iconColor : null,
        ),
        onPressed: isEnabled ? onPressed : null,
      ),
    );
  }

  // Build the normal icon for the interaction that shows the icon and the
  // action text.
  Widget buildNormalIcon(bool isEnabled) {
    return ListTile(
      leading: Icon(icon, size: widget.iconSize),
      title: Text(text),
      textColor: iconColor,
      iconColor: iconColor,
      onTap: isEnabled ? onPressed : null,
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
  Color get iconColor {
    Color? color;

    if (widget.action.isDangerous) {
      return Theme.of(context).colorScheme.error;
    }

    switch (widget.action) {
      case StatusInteraction.reblog:
        color = (widget.schema.reblogged ?? false) ? Theme.of(context).colorScheme.tertiary : null;
        break;
      case StatusInteraction.favourite:
        color = (widget.schema.favourited ?? false) ? Theme.of(context).colorScheme.tertiary : null;
        break;
      case StatusInteraction.bookmark:
        color = (widget.schema.bookmarked ?? false) ? Theme.of(context).colorScheme.tertiary : null;
        break;
      default:
        break;
    }

    return color ?? Theme.of(context).colorScheme.onSurface;
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
    final ServerSchema? server = ref.read(currentServerProvider);
    final String? accessToken = ref.read(currentAccessTokenProvider);
    InteractIt? fn;

    switch (widget.action) {
      case StatusInteraction.reblog:
        fn = widget.schema.reblogged == true ? widget.schema.unreblogIt : widget.schema.reblogIt;
        break;
      case StatusInteraction.favourite:
        fn = widget.schema.favourited == true ? widget.schema.unfavouriteIt : widget.schema.favouriteIt;
        break;
      case StatusInteraction.bookmark:
        fn = widget.schema.bookmarked == true ? widget.schema.unbookmarkIt : widget.schema.bookmarkIt;
        break;
      case StatusInteraction.share:
        final String text = AppLocalizations.of(context)?.txt_copied_to_clipboard ?? "Copy to clipboard";

        Clipboard.setData(ClipboardData(text: widget.schema.uri));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(text),
          ),
        );
        break;
      case StatusInteraction.delete:
        widget.onDeleted?.call();
        break;
      default:
        fn = null;
        break;
    }

    if (fn != null && server != null && accessToken != null) {
      final StatusSchema schema = await fn(domain: server.domain, accessToken: accessToken);
      widget.onReload?.call(schema);
    }

    widget.onPressed?.call();
  }
}

// vim: set ts=2 sw=2 sts=2 et:
