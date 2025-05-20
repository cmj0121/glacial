// The shared library to access the package info.
import 'dart:async';

import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';

// The system-wide package info.
class Info {
  static PackageInfo? _packageInfo;

  static Future<void> init() async {
    _packageInfo = await PackageInfo.fromPlatform();
  }

  PackageInfo? get info => _packageInfo;
}

// The logger instance.
final Logger logger = Logger(printer: PrettyPrinter());


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

// vim: set ts=2 sw=2 sts=2 et:
