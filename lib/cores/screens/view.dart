// The miscellaneous widget library of the app.
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:glacial/core.dart';

// The interface for the slide tab to show the icon and the tooltip
abstract class SlideTab {
  IconData get icon;           // The main icon of the tab
  IconData? get activeIcon;    // The optional icon of tab when it is active

  String? tooltip(BuildContext context);         // The optional tooltip of the tab
}


// The sensitive view widget that hide the content and only show the icon
// when the content is not visible.
class SensitiveView extends StatefulWidget {
  final Widget child;
  final String? spoiler;

  const SensitiveView({
    super.key,
    required this.child,
    this.spoiler,
  });

  @override
  State<SensitiveView> createState() => _SensitiveViewState();
}

class _SensitiveViewState extends State<SensitiveView> {
  bool isVisible = false;

  @override
  Widget build(BuildContext context) {
    return widget.spoiler == null ? buildWithBlur() : buildWithSpoiler();
  }

  Widget buildWithSpoiler() {
    return InkWellDone(
      onTap: onTap,
      child: Column(
        children: [
          const SizedBox(height: 8),
    buildSpoiler(),
          Visibility(
            visible: isVisible,
            child: widget.child,
          ),
        ],
      ),
    );
  }

  Widget buildSpoiler() {
    final List<Widget> texts = widget.spoiler?.isNotEmpty == true ? [
      Text(widget.spoiler ?? ""),
      const SizedBox(height: 8),
    ] : [];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        border: Border.all(
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...texts,
            buildHint(),
          ],
        ),
      ),
    );
  }

  Widget buildHint() {
    return Text(
      (isVisible ? AppLocalizations.of(context)?.txt_show_less : AppLocalizations.of(context)?.txt_show_more) ?? "...",
      style: TextStyle(
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget buildWithBlur() {
    final double blur = isVisible ? 0 : 15;

    return InkWellDone(
      onTap: isVisible ? null : onTap,
      child: ClipRect(
        child: Stack(
          children: [
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
              child: widget.child,
            ),
            buildCover(),
          ],
        ),
      ),
    );
  }

  Widget buildCover() {
    if (isVisible) {
      return const SizedBox.shrink();
    }

    return Container(
      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Icon(
          Icons.visibility_off,
          color: Theme.of(context).colorScheme.onError,
          size: 32,
        ),
      ),
    );
  }

  void onTap() async {
    setState(() {
      isVisible = !isVisible;
    });
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

// The backable widget that can be used to show the back button and the optional
// title of the widget.
class BackableView extends StatelessWidget {
  final Widget child;
  final String? title;

  const BackableView({
    super.key,
    required this.child,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final TextStyle? titleStyle = Theme.of(context).textTheme.labelLarge;
    final Widget header = title == null ? const SizedBox.shrink() : Text(title!, style: titleStyle);

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_outlined),
              onPressed: () => context.pop(),
            ),
            Expanded(
              child: Center(child: header),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Flexible(child: child),
      ],
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
