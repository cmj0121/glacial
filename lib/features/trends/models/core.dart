// The Trends data schema.
import 'package:flutter/material.dart';

import 'package:glacial/core.dart';

// The type list for the timeline, based on the Mastodon API.
enum TrendsType implements SlideTab {
  statuses,
  tags,
  links;

  @override
  String? tooltip(BuildContext context) {
    switch (this) {
      case TrendsType.links:
        return AppLocalizations.of(context)?.btn_trends_links ?? 'Links';
      case TrendsType.statuses:
        return AppLocalizations.of(context)?.btn_trends_statuses ?? 'Statuses';
      case TrendsType.tags:
        return AppLocalizations.of(context)?.btn_trends_tags ?? 'Tags';
    }
  }

  @override
  IconData get icon {
    switch (this) {
      case links:
        return Icons.whatshot_outlined;
      case statuses:
        return Icons.chat_outlined;
      case tags:
        return Icons.label_outline;
    }
  }

  @override
  IconData get activeIcon {
    switch (this) {
      case links:
        return Icons.whatshot;
      case statuses:
        return Icons.chat;
      case tags:
        return Icons.label;
    }
  }
}

// vim: set ts=2 sw=2 sts=2 et:
