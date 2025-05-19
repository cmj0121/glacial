// The possible interactions with the status
import 'package:flutter/material.dart';

// The actions that can be performed on a status.
enum StatusInteraction {
  reply,
  reblog,
  favourite,
  bookmark,
  share,
  more;

  IconData get icon {
    switch (this) {
      case reply:
        return Icons.turn_left_outlined;
      case reblog:
        return Icons.repeat_outlined;
      case favourite:
        return Icons.star_outline_outlined;
      case bookmark:
        return Icons.bookmark_outline;
      case share:
        return Icons.share_outlined;
    case more:
      return Icons.more_horiz;
    }
  }

  IconData get activeIcon {
    switch (this) {
      case reply:
        return Icons.turn_left;
      case reblog:
        return Icons.repeat;
      case favourite:
        return Icons.star;
      case bookmark:
        return Icons.bookmark;
      case share:
        return Icons.share;
      case more:
        return Icons.more_horiz;
    }
  }

  bool get supportAnonymous {
    switch (this) {
      case share:
      case more:
        return true;
      default:
        return false;
    }
  }
}

// vim: set ts=2 sw=2 sts=2 et:
