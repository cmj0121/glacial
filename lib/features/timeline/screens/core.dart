// The Timeline widget in the current selected Mastodon server.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';

// The timeline tab that shows the all possible timelines in the current
// selected Mastodon server.
class TimelineTab extends ConsumerStatefulWidget {
  const TimelineTab({super.key});

  @override
  ConsumerState<TimelineTab> createState() => _TimelineTabState();
}

class _TimelineTabState extends ConsumerState<TimelineTab> with TickerProviderStateMixin {
  // Exclude TimelineType.hashtag from the timeline tab as hashtag timelines are handled differently
  // or are not supported in the current implementation.
  final List<TimelineType> types = TimelineType.values;

  late final TabController controller;
  late List<ScrollController> scrollControllers = [];

  @override
  void initState() {
    super.initState();
    controller = TabController(
      length: types.length,
      initialIndex: 0,
      vsync: this,
    );
    scrollControllers = List.generate(types.length, (index) => ScrollController());
  }

  @override
  void dispose() {
    controller.dispose();
    for (final ScrollController scrollController in scrollControllers) {
      scrollController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TimelineType initType = TimelineType.home;

    controller.index = types.indexWhere((type) => type == initType);

    return SwipeTabView(
      tabController: controller,
      itemCount: types.length,
      tabBuilder: (context, index) {
        final TimelineType type = types[index];
        final bool isSelected = controller.index == index;
        final Color color = isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface;

        return Tooltip(
          message: type.tooltip(context),
          child: Icon(type.icon(active: isSelected), color: color, size: tabSize),
        );
      },
      itemBuilder: (context, index) => const WIP(),
      onDoubleTap: onDoubleTap,
    );
  }

  // Scroll to the top of the timeline when the user double taps on the tab.
  void onDoubleTap(int index) {
    scrollControllers[index].animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
