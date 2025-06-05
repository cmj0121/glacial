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
  final List<TimelineType> types = TimelineType.values.where((type) => type.isPublicView).toList();

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
    final ServerSchema? schema = ref.watch(serverProvider);
    final String? accessToken = ref.watch(accessTokenProvider);
    final TimelineType initType = TimelineType.local;

    if (schema == null) {
      logger.w("No server selected, but it's required to show the timeline.");
      return const SizedBox.shrink();
    }

    controller.index = types.indexWhere((type) => type == initType);

    return SwipeTabView(
      tabController: controller,
      itemCount: types.length,
      tabBuilder: (context, index) {
        final TimelineType type = types[index];
        final bool isSelected = controller.index == index;
        final bool isActive = accessToken != null || type.supportAnonymous;
        final Color color = isActive ?
            (isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface) :
            Theme.of(context).disabledColor;

        return Tooltip(
          message: type.tooltip(context) ?? '',
          child: Icon(type.icon(active: isSelected),color: color),
        );
      },
      itemBuilder: (context, index) => Center(child: Text(types[index].name)),
      onTabTappable: (index) => accessToken != null || types[index].supportAnonymous,
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
