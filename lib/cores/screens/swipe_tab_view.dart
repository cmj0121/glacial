// The customized tab view that can be used to show the active and inactive
// tabs and slide the content to trigger the animation.
import 'package:flutter/material.dart';

import 'package:glacial/core.dart';

class SwipeTabView extends StatefulWidget {
  final int itemCount;
  final IndexedWidgetBuilder tabBuilder;
  final IndexedWidgetBuilder itemBuilder;
  final bool Function(int)? onTabTappable;
  final TabController? tabController;
  final ValueChanged<int>? onDoubleTap;

  const SwipeTabView({
    super.key,
    required this.itemCount,
    required this.tabBuilder,
    required this.itemBuilder,
    this.onTabTappable,
    this.tabController,
    this.onDoubleTap,
  });

  @override
  State<SwipeTabView> createState() => _SwipeTabViewState();
}

class _SwipeTabViewState extends State<SwipeTabView> with TickerProviderStateMixin {
  late final TabController tabController;
  late final PageController pageController;

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
  }

  @override
  void dispose() {
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
      final int pageIndex = visibleIndexes.indexOf(tabController.index);
      pageController.jumpToPage(pageIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SwipeTabBar(
          controller: tabController,
          itemCount: widget.itemCount,
          tabBuilder: widget.tabBuilder,
          onTabTappable: widget.onTabTappable,
          onDoubleTap: () => widget.onDoubleTap?.call(tabController.index),
        ),
        const SizedBox(height: 8),
        Flexible(child: buildContent()),
      ],
    );

    return content;
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
      child: PageView(
        controller: pageController,
        children: List.generate(visibleCount, (index) {
          final int realIndex = visibleIndexes[index];
          return widget.itemBuilder(context, realIndex);
        }),
        onPageChanged: (index) => setState(() {
          final int realIndex = visibleIndexes[index];
          tabController.animateTo(realIndex);
        }),
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
