// Visibility of this status
import 'package:flutter/material.dart';

enum VisibilityType {
  public,       // Visible to everyone, shown in public timelines.
  unlisted,     // Visible to public, but not included in public timelines.
  private,      // Visible to followers only, and to any mentioned users.
  direct;       // Visible only to mentioned users.

  String tooltip(BuildContext context) {
    return name;
  }

  IconData icon({bool active = false}) {
    switch (this) {
      case public:
        return Icons.public;
      case unlisted:
        return Icons.nightlight_outlined;
      case private:
        return Icons.group;
      case direct:
        return Icons.lock;
    }
  }

  factory VisibilityType.fromString(String value) {
    switch (value) {
      case 'public':
        return public;
      case 'unlisted':
        return unlisted;
      case 'private':
        return private;
      case 'direct':
        return direct;
      default:
        throw ArgumentError('Invalid visibility type: $value');
    }
  }
}

// vim: set ts=2 sw=2 sts=2 et:
