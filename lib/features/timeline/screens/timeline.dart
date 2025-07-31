// The Timeline widget in the current selected Mastodon server.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
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
    final AccessStatusSchema? status = ref.watch(accessStatusProvider);

    if (status == null || status.schema == null) {
      logger.w("No server selected, but it's required to show the timeline.");
      return const SizedBox.shrink();
    }

    return buildContent(context, status);
  }

  Widget buildContent(BuildContext context, AccessStatusSchema status) {
    final TimelineType initType = TimelineType.local;
    controller.index = types.indexWhere((type) => type == initType);

    return SwipeTabView(
      tabController: controller,
      itemCount: types.length,
      tabBuilder: (context, index) {
        final TimelineType type = types[index];
        final bool isSelected = controller.index == index;
        final bool isActivate = type.supportAnonymous;
        final Color color = isActivate ?
            isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface :
            Theme.of(context).disabledColor;

        return Tooltip(
          message: type.tooltip(context),
          child: Icon(type.icon(active: isSelected), color: color, size: tabSize),
        );
      },
      itemBuilder: (context, index) => Timeline(
         type: types[index],
         status: status,
         controller: scrollControllers[index],
      ),
      onTabTappable: (index) => types[index].supportAnonymous,
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

// The timeline widget that contains the status from the current selected Mastodon server.
class Timeline extends StatefulWidget {
  final TimelineType type;
  final AccessStatusSchema status;
  final ScrollController? controller;

  const Timeline({
    super.key,
    required this.type,
    required this.status,
    this.controller,
  });

  @override
  State<Timeline> createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  final double loadingThreshold = 180;
  late final ScrollController controller = widget.controller ?? ScrollController();

  bool isLoading = false;
  bool isCompleted = false;
  List<StatusSchema> statuses = [];

  @override
  void initState() {
    super.initState();
    controller.addListener(onScroll);

    onLoad();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          isLoading ? ClockProgressIndicator() : const SizedBox.shrink(),
          Flexible(child: buildContent()),
        ],
      ),
    );
  }

  // Build the list of the statuses and optionally header widget.
  Widget buildContent() {
    return const WIP();
  }

  // Detect the scroll event and load more statuses when the user scrolls to the
  // almost bottom of the list.
  void onScroll() async {
    if (controller.position.pixels >= controller.position.maxScrollExtent - loadingThreshold) {
      onLoad();
    }
  }

  // Clean-up and refresh the timeline when the user pulls down the list.
  Future<void> onRefresh() async {
    setState(() {
      isLoading = false;
      isCompleted = false;
    });

    await onLoad();
  }


  // Load the statuses from the current selected Mastodon server.
  Future<void> onLoad() async {
    if (isLoading || isCompleted) {
      return;
    }

    if (mounted) setState(() => isLoading = true);

    final String? maxId = statuses.isNotEmpty ? statuses.last.id : null;
    final List<StatusSchema> schemas = await widget.status.fetchTimeline(widget.type, maxId: maxId);

    if (mounted) {
      setState(() {
        isLoading = false;
        isCompleted = schemas.isEmpty;
        statuses.addAll(schemas);
      });
    }
  }
}

// vim: set ts=2 sw=2 sts=2 et:
