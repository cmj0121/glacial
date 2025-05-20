// The data schema or represents the results of a search.
import 'package:flutter/material.dart';

import 'package:glacial/core.dart';

// The possible types of results that can be returned from the explorer.
enum ExplorerResultType implements SlideTab {
  account,
  status,
  hashtag;

  @override
  String? tooltip(BuildContext context) {
    return name;
  }

  @override
  IconData get icon {
    switch (this) {
      case account:
        return Icons.contact_page_outlined;
      case status:
        return Icons.message_outlined;
      case hashtag:
        return Icons.tag_outlined;
    }
  }

  @override
  IconData get activeIcon {
    switch (this) {
      case account:
        return Icons.contact_page;
      case status:
        return Icons.message;
      case hashtag:
        return Icons.tag;
    }
  }
}

// vim: set ts=2 sw=2 sts=2 et:
