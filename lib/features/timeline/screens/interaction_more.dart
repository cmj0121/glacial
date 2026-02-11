// The interaction more button that shows the remains possible actions
import 'package:flutter/material.dart';

import 'package:glacial/features/models.dart';

import 'package:glacial/features/timeline/screens/interaction_item.dart';

class InteractionMore extends StatelessWidget {
  final StatusSchema schema;
  final AccessStatusSchema status;
  final List<StatusInteraction> actions;
  final ValueChanged<StatusSchema>? onReload;
  final VoidCallback? onDeleted;

  const InteractionMore({
    super.key,
    required this.schema,
    required this.status,
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
              status: status,
              action: action,
              isCompact: false,
              onPressed: () => Navigator.pop(context),
              onReload: onReload,
              onDeleted: onDeleted,
            ),
          );
        }).toList();
      },
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
