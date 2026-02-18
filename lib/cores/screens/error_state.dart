// Error handling widgets for consistent error display across the app.
import 'package:flutter/material.dart';

import 'package:glacial/l10n/app_localizations.dart';

/// A styled placeholder widget for failed image loads.
///
/// Replaces raw `Icon(Icons.error)` in CachedNetworkImage errorWidget callbacks
/// with a muted, theme-aware broken image icon.
class ImageErrorPlaceholder extends StatelessWidget {
  final double size;

  const ImageErrorPlaceholder({
    super.key,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        Icons.broken_image_outlined,
        size: size,
        color: Theme.of(context).colorScheme.outline,
      ),
    );
  }
}

/// A reusable error state widget with optional retry and secondary action.
///
/// Displays a centered icon, error message, and action buttons for recovering
/// from failed network loads or other error conditions.
class ErrorState extends StatelessWidget {
  final String? message;
  final IconData icon;
  final double iconSize;
  final VoidCallback? onRetry;
  final String? retryLabel;
  final VoidCallback? onSecondaryAction;
  final String? secondaryLabel;

  const ErrorState({
    super.key,
    this.message,
    this.icon = Icons.cloud_off_outlined,
    this.iconSize = 64,
    this.onRetry,
    this.retryLabel,
    this.onSecondaryAction,
    this.secondaryLabel,
  });

  @override
  Widget build(BuildContext context) {
    final String errorMessage = message
        ?? AppLocalizations.of(context)?.msg_network_error
        ?? 'Something went wrong. Please try again.';
    final String retry = retryLabel
        ?? AppLocalizations.of(context)?.btn_retry
        ?? 'Retry';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: iconSize, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(retry),
              ),
            ],
            if (onSecondaryAction != null && secondaryLabel != null) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: onSecondaryAction,
                child: Text(secondaryLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
