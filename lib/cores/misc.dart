// The miscellaneous utilities and constants for the Glacial app.
import 'dart:async';
import 'package:flutter/material.dart';

import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';

// The logger instance.
final Logger logger = Logger(printer: PrettyPrinter());

// The system-wide package info.
class Info {
  static PackageInfo? _packageInfo;

  static Future<void> init() async {
    _packageInfo = await PackageInfo.fromPlatform();
  }

  PackageInfo? get info => _packageInfo;
}

// The debounce helper to delay the function call and avoid triggering
// multiple times.
class Debouncer {
  final Duration duration;
  Timer? _timer;
  bool _locked = false;

  Debouncer({this.duration = const Duration(milliseconds: 250)});

  void call(Function() action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }

  void callOnce(Function() action) {
    if (_locked) return;

    action();
    _locked = true;

    _timer = Timer(duration, () => _locked = false);
  }

  void cancel() {
    _timer?.cancel();
  }
}

// Extracts the max_id from the next link if it exists.
String? getMaxIDFromNextLink(String? nextLink) {
  final links = nextLink?.split(',') ?? [];
  for (final link in links) {
    final match = RegExp(r'<([^>]+)>;\s*rel="([^"]+)"').firstMatch(link.trim());
    if (match != null && match.group(2) == 'next') {
      return Uri.parse(match.group(1) ?? '').queryParameters['max_id'];
    }
  }

  return null;
}

class GlobalController {
  // The global scroll-to-top controller callback
  static ScrollController? scrollToTop;
}

// vim: set ts=2 sw=2 sts=2 et:
