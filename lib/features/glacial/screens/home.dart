// Global shell hooks for keyboard shortcuts and timeline state.
//
// These statics are accessed by AppShortcuts, SwipeTabView,
// Timeline, and other widgets to coordinate shell-level features
// without threading callbacks through the widget tree.
import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'package:glacial/features/models.dart';

class GlacialHome {
  GlacialHome._();

  // Scroll-to-top controller for the active list.
  static ItemScrollController? itemScrollToTop;
  static ItemPositionsListener? itemPositions;
  static List<StatusSchema> Function()? getStatuses;
  static TabController? activeTabController;
  static List<int> Function()? activeVisibleIndexes;

  // Stack of tab-switch cyclers — the most recently mounted SwipeTabView
  // is on top. Dispose pops, restoring the previous view's cycler.
  static final List<void Function(int delta)> _tabSwitchStack = [];
  static void Function(int delta)? get onTabSwitch =>
      _tabSwitchStack.isNotEmpty ? _tabSwitchStack.last : null;
  static void pushTabSwitch(void Function(int delta) cycler) => _tabSwitchStack.add(cycler);
  static void popTabSwitch(void Function(int delta) cycler) => _tabSwitchStack.remove(cycler);
  /// Test-only: clear the tab switch stack between tests.
  static void clearTabSwitchStack() => _tabSwitchStack.clear();

  static VoidCallback? onFocusSearch;
  // Collapse/clear the search bar when Esc is pressed.
  static VoidCallback? onCloseSearch;
  static Future<void> Function()? onRefresh;
  // Toggle a reblog/favourite/bookmark interaction on the status at index.
  static Future<void> Function(int index, StatusInteraction action)? onInteractStatus;

  // Index of the status currently focused by keyboard navigation (j/k).
  // null means no selection; timelines observe this to render a highlight.
  static final ValueNotifier<int?> focusedStatusIndex = ValueNotifier<int?>(null);
  // When set, viewport-based auto-focus is suppressed until this instant
  // so j/k moves aren't stomped by the in-flight scroll animation.
  static DateTime? suppressAutoFocusUntil;

  // Label of the active sub-tab (e.g. "Home", "Public") — shown
  // in the app bar as a subtitle next to the route title.
  static final ValueNotifier<String?> activeTabLabel = ValueNotifier<String?>(null);
}

// vim: set ts=2 sw=2 sts=2 et:
