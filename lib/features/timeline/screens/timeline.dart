// The Timeline widget in the current selected Mastodon server.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

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
    final TimelineType initType = accessToken == null ? TimelineType.local : TimelineType.home;

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
          message: type.tooltip(context),
          child: Icon(type.icon(active: isSelected), color: color, size: 32),
        );
      },
      itemBuilder: (context, index) => Timeline(
        schema: schema,
        type: types[index],
        controller: scrollControllers[index],
      ),
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

// The timeline widget that contains the status from the current selected
// Mastodon server.
class Timeline extends ConsumerStatefulWidget {
  final ServerSchema schema;
  final TimelineType type;
  final String? keyword;
  final AccountSchema? account;
  final ScrollController? controller;

  const Timeline({
    super.key,
    required this.schema,
    required this.type,
    this.keyword,
    this.account,
    this.controller,
  });

  @override
  ConsumerState<Timeline> createState() => _TimelineState();
}

class _TimelineState extends ConsumerState<Timeline> {
  late final ScrollController controller = widget.controller ?? ScrollController();
  final Storage storage = Storage();
  final double loadingThreshold = 180;

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
  void dispose() {
    controller.removeListener(onScroll);
    if (widget.controller == null) {
      controller.dispose();
    }
    super.dispose();
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

  // Build the list of the statuses in the current selected Mastodon server and
  // timeline type.
  Widget buildContent() {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        controller: controller,
        shrinkWrap: true,
        itemCount: statuses.length,
        itemBuilder: (context, index) {
          final StatusSchema status = statuses[index];
          return Padding(
            padding: EdgeInsets.only(right: 16),
            child: Status(
              schema: status.reblog ?? status,
              reblogFrom: status.reblog != null ? status.account : null,
              replyToAccountID: status.inReplyToAccountID,
              onDeleted: () => onDeleted(index),
            ),
          );
        },
      ),
    );
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
      statuses.clear();
    });
    await onLoad();
  }

  // Load the statuses from the current selected Mastodon server.
  Future<void> onLoad() async {
    if (isLoading || isCompleted) {
      return;
    }

    setState(() => isLoading = true);
    final String? maxId = statuses.isNotEmpty ? statuses.last.id : null;
    final List<StatusSchema> newStatuses = await widget.schema.fetchTimeline(
      widget.type,
      accessToken: ref.read(accessTokenProvider),
      maxId: maxId,
    );

    setState(() {
      isLoading = false;

      if (newStatuses.isEmpty) {
        isCompleted = true;
        return;
      }

      statuses.addAll(newStatuses);
    });
  }

  // Reload the timeline when the status is deleted.
  void onDeleted(int index) async {
    setState(() => statuses.removeAt(index));
  }
}

// vim: set ts=2 sw=2 sts=2 et:
