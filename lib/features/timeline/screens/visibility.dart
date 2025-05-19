// The Status widget to show the toots from user.
import 'package:flutter/material.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/timeline/models/core.dart';

class StatusVisibility extends StatelessWidget {
  final VisibilityType type;
  final double size;

  const StatusVisibility({
    super.key,
    required this.type,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = Theme.of(context).colorScheme.secondary;

    return Tooltip(
      message: tooltip(context),
      child: Icon(type.icon, size: size, color: color),
    );
  }

  String tooltip(BuildContext context) {
    switch (type) {
      case VisibilityType.public:
        return AppLocalizations.of(context)?.txt_public ?? 'Public';
      case VisibilityType.unlisted:
        return AppLocalizations.of(context)?.txt_unlisted ?? 'Unlisted';
      case VisibilityType.private:
        return AppLocalizations.of(context)?.txt_private ?? 'Private';
      case VisibilityType.direct:
        return AppLocalizations.of(context)?.txt_direct ?? 'Direct';
    }
  }
}

// vim: set ts=2 sw=2 sts=2 et:
