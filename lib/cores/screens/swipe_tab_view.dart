// The customized tab view that can be used to show the active and inactive
// tabs and slide the content to trigger the animation.
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/glacial/screens/home.dart';

class SwipeTabView extends StatefulWidget {
  final int itemCount;
  final IndexedWidgetBuilder tabBuilder;
  final IndexedWidgetBuilder itemBuilder;
  final bool Function(int)? onTabTappable;
  final TabController? tabController;
  final ValueChanged<int>? onDoubleTap;
  /// When true, registers this view's tab controller and cycler as
  /// the global shortcut target (GlacialHome.onTabSwitch etc.).
  /// Only shell-level tab views (timeline, trends, admin) should set
  /// this; sub-route tab views (profile, search, editor) must leave
  /// it false so they don't overwrite the shell's registration.
  final bool registerShortcuts;

  const SwipeTabView({
    super.key,
    required this.itemCount,
    required this.tabBuilder,
    required this.itemBuilder,
    this.onTabTappable,
    this.tabController,
    this.onDoubleTap,
    this.registerShortcuts = false,
  });

  @override
  State<SwipeTabView> createState() => _SwipeTabViewState();
}

class _SwipeTabViewState extends State<SwipeTabView> with TickerProviderStateMixin {
  static const Set<PointerDeviceKind> _dragDevices = {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.stylus,
    PointerDeviceKind.trackpad,
  };

  late final TabController tabController;
  late final PageController pageController;
  // Positive while one or more tab-driven page animations are in
  // flight. onPageChanged is suppressed so intermediate page indexes
  // don't reset the tab. Counter (not bool) because a rapid second
  // animateTo cancels the first, whose .then fires immediately.
  int _tabDrivingPage = 0;

  Map<int, Widget> cachedWidgets = {};

  @override
  void initState() {
    super.initState();

    final int initialIndex = widget.tabController?.index ?? 0;

    tabController = widget.tabController ?? TabController(
      length: widget.itemCount,
      initialIndex: initialIndex,
      vsync: this,
    );
    pageController = PageController(
      initialPage: visibleIndexes.indexOf(initialIndex),
    );

    tabController.addListener(_onTabControllerChange);
    if (widget.registerShortcuts) {
      GlacialHome.activeTabController = tabController;
      GlacialHome.activeVisibleIndexes = () => visibleIndexes;
      GlacialHome.onTabSwitch = _cycleTab;
    }
  }

  // Cycle tabs by [delta] among visibleIndexes, wrapping at both ends.
  // Uses direct index assignment (no animateTo) to avoid the
  // indexIsChanging listener cascade that races with LayoutBuilder
  // frame callbacks throughout the widget tree. The page animation is
  // driven directly here, guarded by _tabDrivingPage.
  void _cycleTab(int delta) {
    final List<int> visible = visibleIndexes;
    if (visible.isEmpty) return;
    final int curPos = visible.indexOf(tabController.index);
    if (curPos < 0) return;
    int nextPos = (curPos + delta) % visible.length;
    if (nextPos < 0) nextPos += visible.length;
    final int target = visible[nextPos];

    // Direct index assignment — fires listeners with indexIsChanging=false,
    // so _onTabControllerChange skips (no duplicate animateToPage), and
    // SwipeTabBar._onExternalTabChange rebuilds tab icons immediately.
    _tabDrivingPage++;
    tabController.index = target;
    pageController.animateToPage(
      nextPos,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    ).then((_) {
      if (mounted) _tabDrivingPage--;
    });
  }

  @override
  void dispose() {
    if (GlacialHome.activeTabController == tabController) {
      GlacialHome.activeTabController = null;
      GlacialHome.activeVisibleIndexes = null;
      GlacialHome.onTabSwitch = null;
    }
    tabController.removeListener(_onTabControllerChange);
    if (widget.tabController == null) {
      // If the tabController is not provided, dispose it to avoid memory leak.
      tabController.dispose();
    }
    pageController.dispose();
    super.dispose();
  }

  void _onTabControllerChange() {
    if (tabController.indexIsChanging) {
      _tabDrivingPage++;
      final int pageIndex = visibleIndexes.indexOf(tabController.index);
      pageController.animateToPage(
        pageIndex,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      ).then((_) => _tabDrivingPage--);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SwipeTabBar(
          controller: tabController,
          itemCount: widget.itemCount,
          tabBuilder: widget.tabBuilder,
          onTabTappable: widget.onTabTappable,
          onDoubleTap: widget.onDoubleTap != null
              ? () => widget.onDoubleTap!.call(tabController.index)
              : null,
        ),
        const SizedBox(height: 8),
        Flexible(child: buildContent()),
      ],
    );
  }

  // Build the customized PageView that controls which content to show
  // based on the selectable tab.
  Widget buildContent() {
    final int visibleCount = visibleIndexes.length;

    return NotificationListener(
      onNotification: (notification) {
        final double threshold = 150.0;

        if (notification is ScrollUpdateNotification && notification.dragDetails != null) {
          if (tabController.index == leftmostIndex && notification.metrics.pixels <= pageController.position.minScrollExtent - threshold) {
            // The leftmost page is reached, so we may trigger the context.pop()
            // to go back to the previous page.
            if (context.canPop()) {
              context.pop();
              return true;
            }
          }
        }

        return false;
      },
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: _dragDevices,
        ),
        child: PageView(
          controller: pageController,
          children: List.generate(visibleCount, (index) {
            final int realIndex = visibleIndexes[index];
            return widget.itemBuilder(context, realIndex);
          }),
          onPageChanged: (index) {
            // Skip when the tab controller is driving the page animation
            // (external tab switch or keyboard Tab shortcut). Without
            // this, intermediate pages fire during animateToPage and
            // reset the tab index to the wrong value.
            if (_tabDrivingPage > 0) return;
            final int realIndex = visibleIndexes[index];
            if (tabController.index == realIndex) return;
            setState(() => tabController.animateTo(realIndex));
          },
        ),
      ),
    );
  }

  // Get the leftmost index of the visible indexes.
  int get leftmostIndex => visibleIndexes.isNotEmpty ? visibleIndexes.first : 0;

  // Calculate which tabs are visible based on the onTabTappable callback, and then
  // store the index mapping to the visibleIndexes list.
  //
  // visibleIndexes[ PAGE INDEX ] = TAB INDEX
  List<int> get visibleIndexes {
    return List.generate(widget.itemCount, (index) => widget.onTabTappable?.call(index) ?? true)
        .asMap()
        .entries
        .map((entry) => entry.value ? entry.key : null)
        .whereType<int>()
        .toList();
  }
}

// vim: set ts=2 sw=2 sts=2 et:
