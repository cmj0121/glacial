// The miscellaneous widget library of the app.
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:glacial/core.dart';

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

// The interface for the slide tab to show the icon and the tooltip
abstract class SlideTab {
  IconData get icon;           // The main icon of the tab
  IconData? get activeIcon;    // The optional icon of tab when it is active

  String? tooltip(BuildContext context);         // The optional tooltip of the tab
}

// The value change callback for the tab view to get the value of the tab
typedef ValueCallback<T> = T Function(int index);

// The tab view is used to display that tab may be deactivated and shows
// the slide tab view.
class SlideTabView extends StatefulWidget {
  final List<SlideTab> tabs;
  final IndexedWidgetBuilder itemBuilder;
  final ValueCallback<bool>? tabBuilder;
  final TabController? controller;

  const SlideTabView({
    super.key,
    required this.tabs,
    required this.itemBuilder,
    this.tabBuilder,
    this.controller,
  });

  @override
  State<SlideTabView> createState() => _SlideTabViewState();
}

class _SlideTabViewState extends State<SlideTabView> with SingleTickerProviderStateMixin {
  late final TabController controller;

  @override
  void initState() {
    super.initState();
    controller = widget.controller ?? TabController(length: widget.tabs.length, vsync: this);

    if (widget.tabBuilder != null) {
      for (int i = 0; i < widget.tabs.length; i++) {
        final bool isActive = widget.tabBuilder?.call(i) ?? true;
        if (isActive) {
          controller.index = i;
          break;
        }
      }
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      // only dispose the controller if it is not passed from outside
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: buildContent(),
    );
  }

  // Build the main content including the tab button and the content
  Widget buildContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildHeader(),
        Flexible(
          child: ClipRRect(
            child: buildSlidableContent(),
          ),
        ),
      ],
    );
  }

  Widget buildSlidableContent() {
    return Dismissible(
      key: ValueKey<String>('SlideTabView-content-${controller.index}'),
      onDismissed: (direction) {
        final int offset = direction == DismissDirection.startToEnd ? 1 : -1;
        int index = (controller.index + offset) % widget.tabs.length;

        while (widget.tabBuilder?.call(index) == false) {
          index = (index + offset) % widget.tabs.length;
        }

        setState(() {
          controller.animateTo(index);
        });
      },
      child: Container(
        key: ValueKey<String>('SlideTabView-content-${controller.index}'),
        child: widget.itemBuilder(context, controller.index),
      ),
    );
  }

  // Build the header of the button-like tab bar
  Widget buildHeader() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(widget.tabs.length, (index) {
              final SlideTab tab = widget.tabs[index];

              return Expanded(child: buildTab(tab));
            }),
          ),
        );
      },
    );

  }

  // Build the tab button in the SlideTabView
  Widget buildTab(SlideTab tab) {
    final int index = widget.tabs.indexOf(tab);
    final bool isSelected = controller.index == widget.tabs.indexOf(tab);
    final bool isActive = widget.tabBuilder?.call(index) ?? true;

    final IconData icon = isSelected ? tab.activeIcon ?? tab.icon : tab.icon;
    final Color? fgColor = isSelected ? Theme.of(context).colorScheme.primary : null;
    final Color? bgColor = isSelected ? Theme.of(context).colorScheme.onSecondary : null;

    return GestureDetector(
      onTap: isActive ? () => onSelect(index) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border(
            bottom: BorderSide(
              color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).dividerColor,
              width: 3,
            ),
          ),
        ),
        width: double.infinity,
        child: Icon(icon, color: isActive ? fgColor : Theme.of(context).disabledColor),
      ),
    );
  }

  void onSelect(int index) {
    final SlideTab tab = widget.tabs[index];
    setState(() {
      controller.animateTo(widget.tabs.indexOf(tab));
    });
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
    this.size = 10,
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
              width: 2,
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
        showDialog(
          context: context,
          builder: (context) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: buildHero(context),
            );
          },
        );
      },
      child: child,
    );
  }

  // The hero-like media with full-screen and blur the background.
  Widget buildHero(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: InkWellDone(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.transparent,
              ),
            ),
          ),
          Center(
            child: InteractiveViewer(
              child: child,
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
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

// vim: set ts=2 sw=2 sts=2 et:
