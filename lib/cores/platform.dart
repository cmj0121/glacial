// Platform detection utilities for adaptive UI rendering.
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

/// Platform type enumeration for UI adaptation.
enum PlatformType {
  apple,   // iOS, macOS - use Liquid Glass
  android, // Android - use Material Design
  other,   // Web, Windows, Linux - fallback
}

/// Detects the current platform for UI adaptation.
///
/// Returns [PlatformType.apple] for iOS and macOS (Liquid Glass),
/// [PlatformType.android] for Android (Material Design),
/// and [PlatformType.other] for web and other platforms.
PlatformType get currentPlatform {
  if (kIsWeb) return PlatformType.other;

  if (Platform.isIOS || Platform.isMacOS) {
    return PlatformType.apple;
  } else if (Platform.isAndroid) {
    return PlatformType.android;
  }

  return PlatformType.other;
}

/// Returns true if the current platform should use Liquid Glass design.
bool get useLiquidGlass => currentPlatform == PlatformType.apple;

/// Returns true if the current platform should use Material Design.
bool get useMaterial => currentPlatform == PlatformType.android;

// vim: set ts=2 sw=2 sts=2 et:
