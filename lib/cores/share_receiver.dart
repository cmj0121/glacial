// The share receiver service that handles incoming shared content from other apps.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';

export 'package:receive_sharing_intent/receive_sharing_intent.dart' show SharedMediaFile, SharedMediaType;

class ShareReceiver {
  static StreamSubscription<List<SharedMediaFile>>? _subscription;
  static SharedContentSchema? _pendingContent;
  static GlobalKey<NavigatorState>? _navigatorKey;

  /// Initialize the share receiver with a navigator key for routing.
  static void init(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;

    // Listen for shares while the app is running (warm launch).
    _subscription = ReceiveSharingIntent.instance.getMediaStream().listen(
      (List<SharedMediaFile> files) {
        final SharedContentSchema? content = parseSharedMedia(files);
        if (content != null && content.hasContent) {
          navigateToComposer(content);
        }
      },
      onError: (error) {
        logger.w("Share receiver stream error: $error");
      },
    );

    // Check for shares that launched the app (cold launch).
    ReceiveSharingIntent.instance.getInitialMedia().then((List<SharedMediaFile> files) {
      final SharedContentSchema? content = parseSharedMedia(files);
      if (content != null && content.hasContent) {
        _pendingContent = content;
      }
    });
  }

  /// Dispose the share receiver and cancel the stream subscription.
  static void dispose() {
    _subscription?.cancel();
    _subscription = null;
    _navigatorKey = null;
    _pendingContent = null;
  }

  /// Consume and return any pending shared content from a cold launch.
  /// Returns null if there is no pending content. Content is cleared after consumption.
  static SharedContentSchema? consumePendingContent() {
    final SharedContentSchema? content = _pendingContent;
    _pendingContent = null;
    return content;
  }

  /// Parse shared media files into a SharedContentSchema.
  @visibleForTesting
  static SharedContentSchema? parseSharedMedia(List<SharedMediaFile> files) {
    if (files.isEmpty) return null;

    String? text;
    final List<String> imagePaths = [];

    for (final SharedMediaFile file in files) {
      switch (file.type) {
        case SharedMediaType.text:
        case SharedMediaType.url:
          text = (text == null) ? file.path : '$text\n${file.path}';
          break;
        case SharedMediaType.image:
          imagePaths.add(file.path);
          break;
        default:
          break;
      }
    }

    return SharedContentSchema(text: text, imagePaths: imagePaths);
  }

  /// Navigate to the composer with the shared content.
  @visibleForTesting
  static void navigateToComposer(SharedContentSchema content) {
    final BuildContext? context = _navigatorKey?.currentContext;
    if (context == null) return;

    GoRouter.of(context).push(RoutePath.postShared.path, extra: content);
  }
}

// vim: set ts=2 sw=2 sts=2 et:
