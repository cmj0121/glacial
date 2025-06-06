// The Status widget to show the toots from user.
import 'package:flutter/material.dart';

import 'package:glacial/features/timeline/models/core.dart';

// The icon of the status' visibility type.
class StatusVisibility extends StatelessWidget {
  final VisibilityType type;
  final double size;
  final bool isCompact;

  const StatusVisibility({
    super.key,
    required this.type,
    this.size = 16,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = Theme.of(context).dividerColor;

    if (isCompact) {
      return Tooltip(
        message: type.tooltip(context),
        child: Icon(type.icon(), size: size, color: color),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(type.icon(), size: size, color: color),
        const SizedBox(width: 8),
        Text(type.tooltip(context), style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: color,
          fontSize: size,
          fontWeight: FontWeight.bold,
        )),
      ],
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
