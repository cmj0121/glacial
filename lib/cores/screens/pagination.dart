// The paginated list mixin for screens with infinite scrolling.
import 'package:flutter/material.dart';

import 'package:glacial/cores/screens/animations.dart';

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

  /// Whether the list is currently being refreshed (pull-to-refresh).
  bool get isRefresh => _isRefresh;

  /// Whether the list is currently loading more items.
  bool get isLoading => _isLoading;

  /// Whether all items have been loaded (no more pages).
  bool get isCompleted => _isCompleted;

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
    });

    await loadFunction();
  }

  /// Resets all pagination state. Call this when the list needs to be cleared.
  void resetPagination() {
    _isRefresh = false;
    _isLoading = false;
    _isCompleted = false;
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
}

// vim: set ts=2 sw=2 sts=2 et:
