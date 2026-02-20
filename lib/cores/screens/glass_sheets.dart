// Adaptive sheets and dialogs with glassmorphism support.
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:glacial/cores/platform.dart';
import 'package:glacial/cores/screens/glass_style.dart';
import 'package:glacial/l10n/app_localizations.dart';

/// Shows an adaptive modal bottom sheet with glassmorphism on Apple
/// platforms and a Material bottom sheet on Android/other platforms.
Future<T?> showAdaptiveGlassSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isDismissible = true,
  bool enableDrag = true,
  bool isScrollControlled = false,
}) {
  if (useLiquidGlass) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: GlassStyle.blurSigma,
            sigmaY: GlassStyle.blurSigma,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface
                  .withValues(alpha: GlassStyle.opacity),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              border: Border.all(
                color: Colors.white.withValues(alpha: GlassStyle.borderOpacity),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Flexible(child: builder(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  return showModalBottomSheet<T>(
    context: context,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    isScrollControlled: isScrollControlled,
    builder: builder,
  );
}

/// Shows an adaptive dialog with glassmorphism on Apple platforms
/// and a Material AlertDialog on Android/other platforms.
Future<T?> showAdaptiveGlassDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  String? title,
  List<Widget>? actions,
  bool barrierDismissible = true,
}) {
  if (useLiquidGlass) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: GlassStyle.blurSigma,
              sigmaY: GlassStyle.blurSigma,
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface
                    .withValues(alpha: GlassStyle.opacity),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: GlassStyle.borderOpacity),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null) ...[
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                  ],
                  builder(context),
                  if (actions != null) ...[
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: actions,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (context) => AlertDialog(
      title: title != null ? Text(title) : null,
      content: builder(context),
      actions: actions,
    ),
  );
}

/// Shows a confirmation dialog with cancel/confirm buttons.
/// Returns `true` if the user confirms, `false` otherwise.
Future<bool> showConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  String? confirmLabel,
}) async {
  final result = await showAdaptiveGlassDialog<bool>(
    context: context,
    title: title,
    barrierDismissible: false,
    builder: (context) => Text(message),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(false),
        child: Text(AppLocalizations.of(context)?.btn_close ?? 'Cancel'),
      ),
      ElevatedButton(
        onPressed: () {
          HapticFeedback.mediumImpact();
          Navigator.of(context).pop(true);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.error,
          foregroundColor: Theme.of(context).colorScheme.onError,
        ),
        child: Text(confirmLabel ?? AppLocalizations.of(context)?.btn_confirm ?? 'Confirm'),
      ),
    ],
  );
  return result ?? false;
}

// vim: set ts=2 sw=2 sts=2 et:
