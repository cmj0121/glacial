// The miscellaneous widget library of the app.
import 'dart:math';

import 'package:flutter/material.dart';


// The InkWell wrapper that is no any animation and color.
class InkWellDone extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;

  const InkWellDone({
    super.key,
    required this.child,
    this.onTap,
    this.onDoubleTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      child: child,
    );
  }
}


// The clock-like progress indicator which shows the progress of the task.
class ClockProgressIndicator extends StatefulWidget {
  final double size;
  final double barHeight;
  final double barWidth;
  final Duration duration;
  final Color? color;

  const ClockProgressIndicator({
    super.key,
    this.size = 40.0,
    this.barHeight = 10.0,
    this.barWidth = 3.75,
    this.duration = const Duration(milliseconds: 650),
    this.color,
  });

  @override
  State<ClockProgressIndicator> createState() => _ClockProgressIndicatorState();
}

class _ClockProgressIndicatorState extends State<ClockProgressIndicator> with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final Animation<double> animation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();

    animation = Tween<double>(begin: 0, end: 1).animate(controller);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 18.0),
        child: buildContent(),
      ),
    );
  }

  Widget buildContent() {
    return SizedBox(
      width: widget.size * 2,
      height: widget.size * 2,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) => buildClockBar(),
      ),
    );
  }

  Widget buildClockBar() {
    final Color color = widget.color ?? Theme.of(context).colorScheme.secondary;

    return Stack(
      children: List.generate(12, (index) {
        final double angle = (2 * pi / 12) * index;
        final double radius = widget.size / 2;

        final double x = radius + radius * 0.8 * cos(angle);
        final double y = radius + radius * 0.8 * sin(angle);
        final double progress = ((animation.value * 12) - index) % 12 / 12;
        final Color barColor = color.withValues(alpha: progress);

        return Positioned(
          left: x - 2,
          top: y - 2,
          child: Transform.rotate(
            angle: angle + pi / 2,
            child: Container(
              width: widget.barWidth,
              height: widget.barHeight,
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(widget.barWidth / 2),
              ),
            ),
          ),
        );
      }),
    );
  }
}


// The customized tab view that can be used to show the active and inactive
// tabs and slide the content to trigger the animation.
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
  late final List<int> visibleIndexes;

  Map<int, Widget> cachedWidgets = {};

  @override
  void initState() {
    super.initState();

    // Calculate which tabs are visible based on the onTabTappable callback, and then
    // store the index mapping to the visibleIndexes list.
    //
    // visibleIndexes[ PAGE INDEX ] = TAB INDEX
    visibleIndexes = List.generate(widget.itemCount, (index) => widget.onTabTappable?.call(index) ?? true)
        .asMap()
        .entries
        .map((entry) => entry.value ? entry.key : null)
        .whereType<int>()
        .toList();

    final int initialIndex = widget.tabController?.index ?? 0;

    tabController = widget.tabController ?? TabController(
      length: widget.itemCount,
      initialIndex: initialIndex,
      vsync: this,
    );
    pageController = PageController(
      initialPage: visibleIndexes.indexOf(initialIndex),
    );

    tabController.addListener(() {
      if (tabController.indexIsChanging) {
        final int pageIndex = visibleIndexes.indexOf(tabController.index);
        pageController.jumpToPage(pageIndex);
      }
    });
  }

  @override
  void dispose() {
    if (widget.tabController == null) {
      // If the tabController is not provided, dispose it to avoid memory leak.
      tabController.dispose();
    }
    pageController.dispose();
    super.dispose();
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
        Flexible(child: buildContent()),
      ],
    );

    return content;
  }

  // Build the customized PageView that controls which content to show
  // based on the selectable tab.
  Widget buildContent() {
    final int visibleCount = visibleIndexes.length;

    return PageView(
      controller: pageController,
      children: List.generate(visibleCount, (index) {
        final int realIndex = visibleIndexes[index];
        return widget.itemBuilder(context, realIndex);
      }),
      onPageChanged: (index) => setState(() {
        final int realIndex = visibleIndexes[index];
        tabController.animateTo(realIndex);
      }),
    );
  }
}

// The customized tab view that can be used to show the active and inactive
// tabs and slide the content to trigger the animation.
//
// It can pass te TabController to the SwipeTabBar to trigger the animation
// to the selected tab.
class SwipeTabBar extends StatefulWidget {
  final int itemCount;
  final IndexedWidgetBuilder tabBuilder;
  final TabController? controller;
  final bool Function(int)? onTabTappable;
  final VoidCallback? onDoubleTap;

  const SwipeTabBar({
    super.key,
    required this.itemCount,
    required this.tabBuilder,
    this.controller,
    this.onTabTappable,
    this.onDoubleTap,
  });

  @override
  State<SwipeTabBar> createState() => _SwipeTabBarState();
}

class _SwipeTabBarState extends State<SwipeTabBar> with TickerProviderStateMixin {
  late final AnimationController controller;

  late Animation<double> animation;
  late int selectedIndex;

  @override
  void initState() {
    super.initState();

    selectedIndex = widget.controller?.index ?? 0;
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    animation = Tween<double>(begin: selectedIndex.toDouble(), end: 0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ),
    );

    // register the controller trigger tab change
    widget.controller?.addListener(() => onTabTap(widget.controller!.index));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double tabWidth = constraints.maxWidth / widget.itemCount;

        return Stack(
          children: [
            Positioned.fill(
              child: ColoredBox(
                color: Theme.of(context).colorScheme.surface,
              ),
            ),
            buildBar(),
            AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                return Positioned(
                  left: tabWidth * animation.value,
                  bottom: 0,
                  child: Container(
                    width: tabWidth,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              },
            ),
          ]
        );
      },
    );
  }

  Widget buildBar() {
    return Row(
      children: List.generate(widget.itemCount, (index) {
        final bool isClickable = widget.onTabTappable?.call(index) ?? true;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: InkWellDone(
              onTap: isClickable ? () => onTabTap(index) : null,
              onDoubleTap: widget.onDoubleTap,
              child: widget.tabBuilder(context, index),
            ),
          ),
        );
      }),
    );
  }

  // The callback when the active tab is tapped, and trigger the
  // animation for the selected tab, then call the PageView to jump to the
  // selected page.
  void onTabTap(int index) {
    if (index == selectedIndex) {
      // The tab is already selected, so do nothing.
      return;
    }

    // Trigger the animation for the selected tab and slide to the selected tab,
    // and set the related index to the controller.
    setState(() {
      animation = Tween<double>(begin: animation.value, end: index.toDouble()).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeInOut,
        ),
      );
      selectedIndex = index;
      controller.forward(from: 0);
    });
    widget.controller?.animateTo(index);
  }
}

// vim: set ts=2 sw=2 sts=2 et:
