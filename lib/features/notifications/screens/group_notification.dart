// The group notification widget that shows the notifications from the current signed-in user.
import 'dart:math';

import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

// The group notification widget that shows the notifications from the current signed-in user.
class GroupNotification extends ConsumerStatefulWidget {
  const GroupNotification({super.key});

  @override
  ConsumerState<GroupNotification> createState() => _GroupNotificationState();
}

class _GroupNotificationState extends ConsumerState<GroupNotification> with PaginatedListMixin {
  final double loadingThreshold = 180;

  late final AccessStatusSchema? status = ref.read(accessStatusProvider);

  ItemScrollController itemScrollController = ItemScrollController();
  ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();

  List<GroupSchema> groups = [];
  int _firstVisibleIndex = 0;

  @override
  void initState() {
    super.initState();

    itemPositionsListener.itemPositions.addListener(_onPositionChange);

    GlacialHome.itemScrollToTop = itemScrollController;
    WidgetsBinding.instance.addPostFrameCallback((_) => onLoad());
  }

  @override
  void dispose() {
    itemPositionsListener.itemPositions.removeListener(_onPositionChange);
    super.dispose();
  }

  void _onPositionChange() {
    final List<ItemPosition> positions = itemPositionsListener.itemPositions.value.toList();
    if (positions.isEmpty) return;

    _firstVisibleIndex = positions.first.index;

    final int lastIndex = positions.last.index;
    if (lastIndex > groups.length - 5) onLoad();
  }

  @override
  Widget build(BuildContext context) {
    if (status?.isSignedIn != true) {
      logger.w("No server selected, but it's required to show the notifications.");
      return const SizedBox.shrink();
    }

    return Align(
      alignment: Alignment.topCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildToolbar(),
          buildLoadingIndicator(),
          Flexible(child: buildContent()),
        ],
      ),
    );
  }

  // Build the toolbar row with the notification policy settings button.
  Widget buildToolbar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          icon: const Icon(Icons.tune, size: 20),
          tooltip: AppLocalizations.of(context)?.txt_notification_policy ?? "Notification Policy",
          onPressed: () => showAdaptiveGlassSheet(
            context: context,
            builder: (_) => NotificationPolicySheet(status: status),
          ),
        ),
      ],
    );
  }

  // Build the notification content.
  Widget buildContent() {
    if (groups.isEmpty) {
      final String message = AppLocalizations.of(context)?.txt_no_notifications ?? 'No notifications yet';
      return isCompleted ? NoResult(message: message, icon: Icons.notifications_none_outlined) : const SizedBox.shrink();
    }

    final Widget builder = ScrollablePositionedList.builder(
      itemScrollController: itemScrollController,
      itemPositionsListener: itemPositionsListener,
      initialScrollIndex: _firstVisibleIndex.clamp(0, groups.length - 1),
      itemCount: groups.length,
      itemBuilder: (BuildContext context, int index) {
        final GroupSchema group = groups[index];

        return AccessibleDismissible(
          dismissKey: ValueKey(group.key),
          direction: DismissDirection.endToStart,
          dismissLabel: AppLocalizations.of(context)?.lbl_swipe_remove,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            color: Theme.of(context).colorScheme.error,
            child: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.onError),
          ),
          confirmDismiss: (_) async {
            onDismissGroup(index, group.key);
            return false;
          },
          child: SingleNotification(schema: group),
        );
      },
    );

    return CustomMaterialIndicator(
      onRefresh: onRefresh,
      indicatorBuilder: ClockProgressIndicator.refreshBuilder,
      child: isRefresh ? const SizedBox.shrink() : builder,
    );
  }

  // Dismiss a notification group and rebuild the list with fresh controllers
  // to avoid ScrollablePositionedList stale state after item removal.
  void onDismissGroup(int index, String groupKey) {
    itemPositionsListener.itemPositions.removeListener(_onPositionChange);
    groups.removeAt(index);
    status?.dismissNotificationGroup(groupKey);

    // Recreate controllers to force a clean ScrollablePositionedList rebuild.
    itemScrollController = ItemScrollController();
    itemPositionsListener = ItemPositionsListener.create();
    itemPositionsListener.itemPositions.addListener(_onPositionChange);
    GlacialHome.itemScrollToTop = itemScrollController;

    setState(() {});
  }

  // Clean-up and refresh the timeline when the user pulls down the list.
  Future<void> onRefresh() async {
    setState(() => groups.clear());
    await refreshList(onLoad);
  }

  Future<void> onLoad() async {
    if (shouldSkipLoad) return;

    setLoading(true);

    final String? maxId = groups.isNotEmpty ? groups.last.pageMaxID : null;
    final GroupNotificationSchema? schema = await status?.fetchNotifications(maxId: maxId);
    final TimelineMarkerType type = TimelineMarkerType.notifications;

    if (mounted) {
      setState(() => groups.addAll(schema?.groups ?? []));
      markLoadComplete(isEmpty: schema?.isEmpty ?? false);
    }

    final int? id = schema?.groups.firstOrNull?.id;
    if (id != null) {
      final MarkersSchema? markers = await status?.getMarker(type: type);
      final MarkerSchema? marker = markers?.markers[type];
      final int lastReadId = max(int.parse(marker?.lastReadID ?? '0'), id);

      await status?.setMarker(id: lastReadId.toString(), type: type);
      AppBadgePlus.updateBadge(0);
    }
  }
}

// vim: set ts=2 sw=2 sts=2 et:
