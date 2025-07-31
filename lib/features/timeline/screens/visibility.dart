// The Status widget to show the toots from user.
import 'package:flutter/material.dart';

import 'package:glacial/features/models.dart';

// The icon of the status' visibility type.
class StatusVisibility extends StatelessWidget {
  final VisibilityType type;
  final double size;

  const StatusVisibility({
    super.key,
    required this.type,
    this.size = 16,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = Theme.of(context).colorScheme.onSurfaceVariant;

    return Tooltip(
      message: type.tooltip(context),
      child: Icon(type.icon(), size: size, color: color),
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
