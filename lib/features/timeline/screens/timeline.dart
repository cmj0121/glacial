// The Timeline widget in the current selected Mastodon server.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

// The timeline tab that shows the all possible timelines in the current
// selected Mastodon server.
class TimelineTab extends ConsumerStatefulWidget {
  final TimelineType initialType;

  const TimelineTab({
    super.key,
    this.initialType = TimelineType.local,
  });

  @override
  ConsumerState<TimelineTab> createState() => _TimelineTabState();
}

class _TimelineTabState extends ConsumerState<TimelineTab> with TickerProviderStateMixin {
  // Exclude TimelineType.hashtag from the timeline tab as hashtag timelines are handled differently
  // or are not supported in the current implementation.
  final List<TimelineType> types = TimelineType.values.where((type) => type.inTimelineTab).toList();

  late final TabController controller;

  @override
  void initState() {
    super.initState();
    controller = TabController(
      length: types.length,
      initialIndex: 0,
      vsync: this,
    );

    controller.index = types.indexWhere((type) => type == widget.initialType);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AccessStatusSchema? status = ref.read(accessStatusProvider);

    if (status == null || status.domain == null) {
      logger.w("No server selected, but it's required to show the timeline.");
      return const SizedBox.shrink();
    }

    return buildContent(context, status);
  }

  Widget buildContent(BuildContext context, AccessStatusSchema status) {
    final bool isSignIn = status.accessToken?.isNotEmpty == true;
    final SystemPreferenceSchema? pref = ref.watch(preferenceProvider);

    return SwipeTabView(
      key: ValueKey('${status.domain}_timeline}'),
      tabController: controller,
      itemCount: types.length,
      tabBuilder: (context, index) {
        final TimelineType type = types[index];
        final bool isSelected = controller.index == index;
        final bool isActivate = isSignIn || type.supportAnonymous;
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
        pref: pref,
        onDeleted: () => context.pop(),
      ),
      onTabTappable: (index) => isSignIn || types[index].supportAnonymous,
    );
  }
}

// The timeline widget that contains the status from the current selected Mastodon server.
class Timeline extends StatefulWidget {
  final TimelineType type;
  final AccessStatusSchema status;
  final SystemPreferenceSchema? pref;
  final AccountSchema? account;
  final String? hashtag;
  final String? listId;
  final VoidCallback? onDeleted;

  const Timeline({
    super.key,
    required this.type,
    required this.status,
    this.pref,
    this.account,
    this.hashtag,
    this.listId,
    this.onDeleted,
  });

  @override
  State<Timeline> createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  final double loadingThreshold = 180;
  late final ItemScrollController itemScrollController = ItemScrollController();
  late final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();

  bool isRefresh = false;
  bool isLoading = false;
  bool isCompleted = false;
  Timer? timer;

  List<StatusSchema> unreaded = [];
  List<StatusSchema> statuses = [];

  @override
  void initState() {
    super.initState();

    itemPositionsListener.itemPositions.addListener(() {
      final List<ItemPosition> positions = itemPositionsListener.itemPositions.value.toList();
      final int? lastIndex = positions.isNotEmpty ? positions.last.index : null;

      if (lastIndex != null && lastIndex > statuses.length - 5) onLoad();
    });

    GlacialHome.itemScrollToTop = itemScrollController;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final Duration? refreshInterval = widget.pref?.refreshInterval;

      if (refreshInterval != null && refreshInterval.inSeconds > 0) {
        final int interval = refreshInterval.inSeconds;

        timer = Timer.periodic(Duration(seconds: interval), (Timer timer) async {
          onLoadUnreaded();
        });
      }

      onLoad();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isCompleted && !isLoading && statuses.isEmpty) {
      final String message = AppLocalizations.of(context)?.txt_no_result ?? "No results found";
      return NoResult(message: message, icon: Icons.coffee);
    }

    return Align(
      alignment: Alignment.topCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          (isLoading && !isRefresh) ? ClockProgressIndicator() : const SizedBox.shrink(),
          buildUnreadedBanner(),
          Flexible(child: buildContent()),
        ],
      ),
    );
  }

  // Build the unreaded count widget and the list of statuses.
  Widget buildUnreadedBanner() {
    final TextStyle? style = Theme.of(context).textTheme.labelLarge;

    if (unreaded.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        icon: const Icon(Icons.mark_email_unread, size: tabSize),
        label: Text("#${unreaded.length} Unreaded Statuses", style: style),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
        ),
        onPressed: onClickUnreaded,
      ),
    );
  }

  // Build the list of the statuses and optionally header widget.
  Widget buildContent() {
    if (statuses.isEmpty) {
      return const SizedBox.shrink();
    }

    return CustomMaterialIndicator(
      onRefresh: onRefresh,
      indicatorBuilder: (_, __) => const ClockProgressIndicator(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: ScrollablePositionedList.builder(
          itemScrollController: itemScrollController,
          itemPositionsListener: itemPositionsListener,
          shrinkWrap: true,
          itemCount: statuses.length,
          itemBuilder: (context, index) {
            final StatusSchema status = statuses[index];
            final Widget child = Status(
              key: ValueKey('status_${status.id}'),
              schema: status,
              onDeleted: () {
                setState(() => statuses.removeAt(index));
                widget.onDeleted?.call();
              }
            );

            return Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.outline)),
              ),
              child: child,
            );
          },
        ),
      ),
    );
  }

  // Show the unreaded statuses when the user taps on the unreaded banner and keep the current
  // scroll position.
  void onClickUnreaded() async {
    final List<ItemPosition> positions = itemPositionsListener.itemPositions.value.toList();
    final int oldIndex = unreaded.length + positions.first.index;

    setState(() {
      statuses = [...unreaded, ...statuses];
      unreaded.clear();
    });

    // Scroll to the old position after the new statuses are added.
    WidgetsBinding.instance.addPostFrameCallback((_) => itemScrollController.jumpTo(index: oldIndex));
  }

  // Clean-up and refresh the timeline when the user pulls down the list.
  Future<void> onRefresh() async {
    setState(() {
      isRefresh = true;
      isLoading = false;
      isCompleted = false;
      unreaded.clear();
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
    final List<StatusSchema> schemas = await widget.status.fetchTimeline(
      widget.type,
      account: widget.type == TimelineType.schedule ? widget.status.account : widget.account,
      tag: widget.hashtag,
      listId: widget.listId,
      maxId: maxId,
    );

    if (mounted) {
      setState(() {
        isRefresh = false;
        isLoading = false;
        isCompleted = schemas.isEmpty;
        statuses.addAll(schemas);
      });
    }
  }

  // Load the possible unreaded statuses when the app is resumed.
  Future<void> onLoadUnreaded() async {
    String? minId = unreaded.isEmpty ?
        (statuses.isNotEmpty ? statuses.first.id : null) :
        unreaded.first.id;

    if (minId == null) [];

    while (true) {
      final List<StatusSchema> schemas = await onLoadUnreadedMore(minId);

      if (schemas.isEmpty) break;

      setState(() => unreaded = [...schemas, ...unreaded]);
      minId = schemas.first.id;

      await Future.delayed(const Duration(milliseconds: 750));
    }
  }

  Future<List<StatusSchema>> onLoadUnreadedMore(String? minId) async {
    return await widget.status.fetchTimeline(
      widget.type,
      account: widget.type == TimelineType.schedule ? widget.status.account : widget.account,
      tag: widget.hashtag,
      listId: widget.listId,
      minId: minId,
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
