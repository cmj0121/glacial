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

  String tooltip(BuildContext context) {
    return name;
  }

  IconData icon({bool active = false}) {
    switch (this) {
      case reply:
        return active ? Icons.turn_left : Icons.turn_left_outlined;
      case reblog:
        return active ? Icons.repeat : Icons.repeat_outlined;
      case favourite:
        return active ? Icons.star : Icons.star_outline_outlined;
      case bookmark:
        return active ? Icons.bookmark : Icons.bookmark_outline_outlined;
      case share:
        return active ? Icons.share : Icons.share_outlined;
      case mute:
        return active ? Icons.volume_off : Icons.volume_mute_outlined;
      case block:
        return active ? Icons.block : Icons.block_outlined;
      case delete:
        return active ? Icons.delete : Icons.delete_outline_outlined;
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
