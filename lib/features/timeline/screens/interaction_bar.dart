// The interaction bar that shows the all the possible actions for the current
// status, and wraps the interaction more button if there are more actions
// than the available space.
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pub_semver/pub_semver.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';

import 'package:glacial/features/timeline/screens/interaction_item.dart';
import 'package:glacial/features/timeline/screens/interaction_more.dart';

class InteractionBar extends ConsumerWidget {
  static final Version _minQuoteVersion = Version.parse('4.5.0');

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
    final AccessStatusSchema status = ref.read(accessStatusProvider) ?? AccessStatusSchema();
    final bool isSelfStatus = schema.account.id == status.account?.id;
    final Version serverVersion = Version.parse(status.server?.version ?? '0.0.0');
    final List<StatusInteraction> actions = StatusInteraction.values.where((a) {
      switch (a) {
        case StatusInteraction.quote:
          // Only 4.5.0+ supports quote interaction
          return serverVersion >= _minQuoteVersion;
        case StatusInteraction.pin:
        case StatusInteraction.edit:
        case StatusInteraction.policy:
        case StatusInteraction.delete:
          return isSelfStatus;
        case StatusInteraction.mute:
          return true; // Conversation mute is available for all posts
        case StatusInteraction.filter:
        case StatusInteraction.block:
        case StatusInteraction.report:
          return !isSelfStatus;
        default:
          return true; // All other actions are available
      }
    }).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final int builtinActionsCount = actions.where((action) => action.isBuiltIn).length;
        final int maxItems = min((constraints.maxWidth / itemWidth).floor() - 1, builtinActionsCount);
        final List<StatusInteraction> visibleActions = actions.take(maxItems).toList();
        final List<StatusInteraction> remainingActions = actions.skip(maxItems).toList();

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ... visibleActions.map((action) => Interaction(
                schema: schema,
                status: status,
                action: action,
                onReload: onReload,
                onDeleted: onDeleted,
            )),
            InteractionMore(
              schema: schema,
              status: status,
              actions: remainingActions,
              onReload: onReload,
              onDeleted: onDeleted,
            ),
          ],
        );
      },
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
