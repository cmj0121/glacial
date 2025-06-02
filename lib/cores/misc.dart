// The miscellaneous utilities and constants for the Glacial app.
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


// vim: set ts=2 sw=2 sts=2 et:
