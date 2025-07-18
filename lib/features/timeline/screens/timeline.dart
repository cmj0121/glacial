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
    final ServerSchema? schema = ref.read(serverProvider);
    final String? accessToken = ref.read(accessTokenProvider);
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
  final Widget? child;

  const Timeline({
    super.key,
    required this.schema,
    required this.type,
    this.keyword,
    this.account,
    this.controller,
    this.child,
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

    GlobalController.scrollToTop = controller;
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

  // Build the list of the statuses and optionally header widget.
  Widget buildContent() {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          widget.child ?? const SizedBox.shrink(),
          Expanded(child: buildStatuses()),
        ],
      ),

    );
  }

  // Build the list of the statuses in the current selected Mastodon server.
  Widget buildStatuses() {
    if (statuses.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListView.builder(
      controller: controller,
      shrinkWrap: true,
      itemCount: statuses.length,
      itemBuilder: (context, index) {
        final StatusSchema status = statuses[index];
        final Widget child = Status(
          key: ValueKey(status.id),
          schema: status.reblog ?? status,
          reblogFrom: status.reblog != null ? status.account : null,
          replyToAccountID: status.inReplyToAccountID,
          onDeleted: () => setState(() => statuses.removeAt(index)),
        );

        return Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.outline)),
          ),
          child: Padding(
            padding: EdgeInsets.only(right: 16),
            child: child,
          ),
        );
      },
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
      accountID: widget.account?.id,
      maxId: maxId,
      keyword: widget.keyword,
      currentUser: ref.read(accountProvider),
    );

    if (mounted == false) {
      return; // Widget is not mounted, do not update the state.
    }

    setState(() {
      isLoading = false;

      if (newStatuses.isEmpty) {
        isCompleted = true;
        return;
      }

      statuses.addAll(newStatuses);
    });
  }
}

// vim: set ts=2 sw=2 sts=2 et:
