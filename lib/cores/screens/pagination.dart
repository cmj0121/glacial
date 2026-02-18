// The paginated list mixin for screens with infinite scrolling.
import 'package:flutter/material.dart';

import 'package:glacial/cores/screens/animations.dart';
import 'package:glacial/l10n/app_localizations.dart';

/// Mixin for paginated list state management.
///
/// Provides common state variables and helper methods for screens that display
/// paginated lists with loading, refresh, and completion states.
///
/// Example usage:
/// ```dart
/// class _MyListState extends State<MyList> with PaginatedListMixin {
///   List<MyItem> items = [];
///
///   Future<void> onLoad() async {
///     if (shouldSkipLoad) return;
///     setLoading(true);
///
///     final newItems = await api.fetchItems(offset: items.length);
///     if (mounted) {
///       setState(() => items.addAll(newItems));
///       markLoadComplete(isEmpty: newItems.isEmpty);
///     }
///   }
///
///   Future<void> onRefresh() => refreshList(onLoad);
/// }
/// ```
mixin PaginatedListMixin<T extends StatefulWidget> on State<T> {
  bool _isRefresh = false;
  bool _isLoading = false;
  bool _isCompleted = false;
  bool _hasError = false;

  /// Whether the list is currently being refreshed (pull-to-refresh).
  bool get isRefresh => _isRefresh;

  /// Whether the list is currently loading more items.
  bool get isLoading => _isLoading;

  /// Whether all items have been loaded (no more pages).
  bool get isCompleted => _isCompleted;

  /// Whether the last load operation failed.
  bool get hasError => _hasError;

  /// Returns true if loading should be skipped (already loading or completed).
  bool get shouldSkipLoad => _isLoading || _isCompleted;

  /// Sets the loading state. Call this at the start of a load operation.
  void setLoading(bool value) {
    if (mounted) setState(() => _isLoading = value);
  }

  /// Marks the load operation as complete.
  /// [isEmpty] should be true if no new items were loaded, indicating end of list.
  void markLoadComplete({required bool isEmpty}) {
    if (mounted) {
      setState(() {
        _isRefresh = false;
        _isLoading = false;
        _isCompleted = isEmpty;
        _hasError = false;
      });
    }
  }

  /// Marks the load operation as failed. Call this when a load error occurs.
  void markLoadError() {
    if (mounted) {
      setState(() {
        _isRefresh = false;
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  /// Resets state for a refresh operation and calls the provided load function.
  /// Use this for pull-to-refresh functionality.
  Future<void> refreshList(Future<void> Function() loadFunction) async {
    setState(() {
      _isRefresh = true;
      _isLoading = false;
      _isCompleted = false;
      _hasError = false;
    });

    await loadFunction();
  }

  /// Resets all pagination state. Call this when the list needs to be cleared.
  void resetPagination() {
    _isRefresh = false;
    _isLoading = false;
    _isCompleted = false;
    _hasError = false;
  }

  /// Builds the loading indicator widget with a smooth fade transition.
  /// Shows ClockProgressIndicator when loading (but not during pull-to-refresh).
  Widget buildLoadingIndicator() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: (_isLoading && !_isRefresh)
          ? const ClockProgressIndicator(key: ValueKey('loading'))
          : const SizedBox.shrink(key: ValueKey('idle')),
    );
  }

  /// Builds an inline error indicator with a tap-to-retry action.
  Widget buildErrorIndicator(VoidCallback onRetry) {
    if (!_hasError) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: InkWell(
          onTap: () {
            setState(() => _hasError = false);
            onRetry();
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)?.btn_tap_retry ?? 'Tap to retry',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
