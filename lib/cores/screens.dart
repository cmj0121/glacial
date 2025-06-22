// The miscellaneous widget library of the app.
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';

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

// The customize HTML render
class HtmlDone extends StatelessWidget {
  final String html;
  final List<EmojiSchema> emojis;
  final OnTap? onLinkTap;

  const HtmlDone({
    super.key,
    required this.html,
    this.emojis = const [],
    this.onLinkTap,
  });

  @override
  Widget build(BuildContext context) {
    return Html(
      data: Storage().replaceEmojiToHTML(html, emojis: emojis),
      style: {
        'a': Style(
          color: Theme.of(context).colorScheme.secondary,
          textDecoration: TextDecoration.underline,
        ),
      },
      onLinkTap: onLinkTap,
    );
  }
}

// The hero media that show the media and show to full-screen when tap on it.
class MediaHero extends StatelessWidget {
  final Widget child;

  const MediaHero({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return InkWellDone(
      onTap: () {
        // Pop-up the media as full-screen and blur the background.
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (BuildContext context) {
              return Center(
                child: Hero(
                  tag: 'media-hero',
                  child: MediaViewer(child: child),
                ),
              );
            },
          ),
        );
      },
      child: child,
    );
  }
}

// The media viewer that can be used to show the media content in the app.
class MediaViewer extends StatelessWidget {
  final Widget child;

  const MediaViewer({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: const Key('media-viewer'),
      direction: DismissDirection.vertical,
      child: Stack(
        alignment: Alignment.topRight,
        fit: StackFit.expand,
        children: [
          FittedBox(
            fit: BoxFit.contain,
            child: InteractiveViewer(child: child),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurface),
              onPressed: () => context.pop()
            ),
          ),
        ],
      ),
      onDismissed: (direction) => context.pop(),
    );
  }
}

// The backable widget that can be used to show the back button and the optional
// title of the widget.
class BackableView extends StatelessWidget {
  final Widget child;
  final String? title;
  final List<Widget>? actions;

  const BackableView({
    super.key,
    required this.child,
    this.title,
    this.actions,
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

            ...buildActions(context),
          ],
        ),
        const SizedBox(height: 8),
        Flexible(
          child: Dismissible(
            key: UniqueKey(),
            direction: DismissDirection.startToEnd,
            onDismissed: (direction) => context.pop(),
            child: child,
          ),
        ),
      ],
    );
  }

  List<Widget> buildActions(BuildContext context) {
    if (actions == null || actions!.isEmpty) {
      return [];
    }

    return [
      const Spacer(),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: actions!,
      ),
    ];
  }
}

// The indent wrapper widget to show the indent of the content.
class Indent extends StatelessWidget {
  final int indent;
  final Widget child;
  final double size;

  const Indent({
    super.key,
    required this.indent,
    required this.child,
    this.size = 4,
  });

  @override
  Widget build(BuildContext context) {
    switch (indent) {
    case 0:
      return child;
    case 1:
      return buildContent(context);
    default:
      return Indent(indent: indent - 1, child: buildContent(context));
    }
  }

  Widget buildContent(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: size),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: Theme.of(context).dividerColor,
              width: size,
            ),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(left: size),
          child: child,
        ),
      ),
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
              onDoubleTap: isClickable ? widget.onDoubleTap : null,
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
      onDoubleTap: onTap,
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

// vim: set ts=2 sw=2 sts=2 et:
