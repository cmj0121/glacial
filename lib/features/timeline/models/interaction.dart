// The possible interactions with the status
import 'package:flutter/material.dart';

// The actions that can be performed on a status.
enum StatusInteraction {
  reply,
  reblog,
  favourite,
  bookmark,
  share,
  mute,
  block,
  delete;

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
      case mute:
        return Icons.volume_off_outlined;
      case block:
        return Icons.block_outlined;
      case delete:
        return Icons.delete_outline;
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
      case mute:
        return Icons.volume_off;
      case block:
        return Icons.block;
      case delete:
        return Icons.delete;
    }
  }

  bool get supportAnonymous {
    switch (this) {
      case share:
        return true;
      default:
        return false;
    }
  }

  bool get isDangerous {
    switch (this) {
      case mute:
      case block:
      case delete:
        return true;
      default:
        return false;
    }
  }
}

// vim: set ts=2 sw=2 sts=2 et:
