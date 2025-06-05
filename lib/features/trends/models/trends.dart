// The Trends data schema.
import 'package:flutter/material.dart';

import 'package:glacial/core.dart';

// The type list for the timeline, based on the Mastodon API.
enum TrendsType {
  statuses,
  tags,
  links;

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

  IconData icon({bool active = false}) {
    switch (this) {
      case links:
        return active ? Icons.whatshot : Icons.whatshot_outlined;
      case statuses:
        return active ? Icons.chat_bubble : Icons.chat_bubble_outline;
      case tags:
        return active ? Icons.label : Icons.label_outline;
    }
  }
}

// vim: set ts=2 sw=2 sts=2 et:
