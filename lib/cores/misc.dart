// The shared library to access the package info.
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

// vim: set ts=2 sw=2 sts=2 et:
