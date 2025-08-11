// The Notification widget in the current selected Mastodon server.
import 'dart:async';
import 'dart:math';

import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

// The notification badge that shows the unread notifications count.
class NotificationBadge extends ConsumerStatefulWidget {
  final double size;
  final bool isSelected;
  final VoidCallback? onPressed;

  const NotificationBadge({
    super.key,
    this.size = iconSize,
    this.isSelected = false,
    this.onPressed,
  });

  @override
  ConsumerState<NotificationBadge> createState() => _NotificationBadgeState();
}

class _NotificationBadgeState extends ConsumerState<NotificationBadge> with WidgetsBindingObserver {
  late final SystemPreferenceSchema? pref = ref.watch(preferenceProvider);
  late final AccessStatusSchema? status = ref.watch(accessStatusProvider);

  Timer? _timer;
  int unreadCount = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _startTaskIfForeground());
  }

  @override
  void dispose() {
    _stopTask();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _startTaskIfForeground(state: state);
  }

  void _startTaskIfForeground({AppLifecycleState? state}) {
    final currentState = state ?? WidgetsBinding.instance.lifecycleState;

    switch (currentState) {
      case AppLifecycleState.resumed:
        logger.d("App is in foreground, starting task: $currentState.");
        _startTask();
        break;
      default:
        logger.d("App is not in foreground");
        break;
    }
  }

  void _startTask({int? times}) {
    final Duration? refreshInterval = pref?.refreshInterval;
    _stopTask();

    if (refreshInterval != null && refreshInterval.inSeconds > 0) {
      final int interval = refreshInterval.inSeconds;

      _timer = Timer.periodic(Duration(seconds: interval * (times ?? 1)), (Timer timer) async {
        onLoad();
      });
    }
  }

  void _stopTask() async {
    _timer?.cancel();
    _timer = null;
  }

  @override
  Widget build(BuildContext context) {
    final SidebarButtonType action = SidebarButtonType.notifications;
    final Widget icon = IconButton(
      icon: Icon(action.icon(active: widget.isSelected), size: widget.size),
      tooltip: action.tooltip(context),
      color: widget.isSelected ? Theme.of(context).colorScheme.primary : null,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      onPressed: widget.onPressed,
    );

    if (unreadCount == 0 || widget.isSelected) {
      // No need to show the unread count if it's zero or the widget is selected.
      return icon;
    }

    return Badge.count(
      count: unreadCount,
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: icon,
    );
  }

  // Try to load the unread notifications count when the widget is built.
  Future<void> onLoad() async {
    final int count = await status?.getUnreadGroupCount() ?? 0;

    if (count> unreadCount) { await onNotify(count); }
    setState(() => unreadCount = count);
  }

  // Send the notification to the user when the unread count is updated.
  Future<void> onNotify(int unreadCount) async {
    final String title = AppLocalizations.of(context)?.msg_notification_title ?? "New Notifications";
    final String body = AppLocalizations.of(context)?.msg_notification_body(unreadCount) ?? "You have $unreadCount new notifications.";

    await sendLocalNotification(title, body, badgeNumber: unreadCount);
  }
}

// The group notification widget that shows the notifications from the current signed-in user.
class GroupNotification extends ConsumerStatefulWidget {
  const GroupNotification({super.key});

  @override
  ConsumerState<GroupNotification> createState() => _GroupNotificationState();
}

class _GroupNotificationState extends ConsumerState<GroupNotification> {
  final double loadingThreshold = 180;

  late final AccessStatusSchema? status = ref.watch(accessStatusProvider);
  late final ScrollController controller = ScrollController();

  bool isRefresh = false;
  bool isLoading = false;
  bool isCompleted = false;
  List<GroupSchema> groups = [];

  @override
  void initState() {
    super.initState();

    controller.addListener(onScroll);
    GlacialHome.scrollToTop = controller;
    WidgetsBinding.instance.addPostFrameCallback((_) => onLoad());
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
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
          isLoading ? ClockProgressIndicator() : const SizedBox.shrink(),
          Flexible(child: buildContent()),
        ],
      ),
    );
  }

  // Build the notification content.
  Widget buildContent() {
    final Widget builder =  ListView.builder(
      controller: controller,
      itemCount: groups.length,
      itemBuilder: (BuildContext context, int index) => SingleNotification(schema: groups[index]),
    );

    return CustomMaterialIndicator(
      onRefresh: onRefresh,
      indicatorBuilder: (_, __) => const ClockProgressIndicator(),
      child: isRefresh ? const SizedBox.shrink() : builder,
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
      isRefresh = true;
      isLoading = false;
      isCompleted = false;
    });

    await onLoad();
  }

  Future<void> onLoad() async {
    if (isLoading || isCompleted) { return; }

    setState(() => isLoading = true);

    final String? maxId = groups.isNotEmpty ? groups.last.pageMaxID : null;
    final GroupNotificationSchema? schema = await status?.fetchNotifications(maxId: maxId);
    final TimelineMarkerType type = TimelineMarkerType.notifications;

    setState(() {
      isRefresh = false;
      isLoading = false;
      isCompleted = schema?.isEmpty ?? false;
      groups.addAll(schema?.groups ?? []);
    });

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

class SingleNotification extends ConsumerStatefulWidget {
  final GroupSchema schema;
  final double iconSize;

  const SingleNotification({
    super.key,
    required this.schema,
    this.iconSize = 18,
  });

  @override
  ConsumerState<SingleNotification> createState() => _SingleNotificationState();
}

class _SingleNotificationState extends ConsumerState<SingleNotification> {
  late final AccessStatusSchema? status = ref.read(accessStatusProvider);

  Widget? child;
  List<AccountSchema> accounts = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => onLoad());
  }

  @override
  Widget build(BuildContext context) {
    if (child == null) {
      return const ClockProgressIndicator();
    }

    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Align(
          alignment: Alignment.topLeft,
          child: buildContent(),
        ),
      ),
    );
  }

  Widget buildContent() {
    switch (widget.schema.type) {
      case NotificationType.mention:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildHeader(),
            const SizedBox(height: 8),
            child ?? const SizedBox.shrink(),
          ],
        );
      case NotificationType.status:
      case NotificationType.reblog:
      case NotificationType.favourite:
      case NotificationType.poll:
      case NotificationType.update:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildHeader(),
            const SizedBox(height: 8),
            ColorFiltered(
              colorFilter: ColorFilter.mode(Colors.grey, BlendMode.modulate),
              child: child ?? const SizedBox.shrink(),
            ),
          ],
        );
      case NotificationType.follow:
      case NotificationType.followRequest:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildHeader(),
            const SizedBox(height: 8),
            child ?? const SizedBox.shrink(),
          ],
        );
      case NotificationType.unknown:
        return buildHeader();
    }
  }

  // Build the optional header for the notification, which shows the accounts involved in the notification.
  Widget buildHeader() {
    final Widget icon = TextButton.icon(
      icon: Icon(widget.schema.type.icon, size: widget.iconSize),
      label: Text(widget.schema.type.tooltip(context)),
      onPressed: null,
    );

    return Row(
      children: [
        ...accounts.map((a) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: AccountAvatar(schema: a, size: widget.iconSize),
        )),
        icon,
      ],
    );
  }

  void onLoad() async {
    if (child != null) { return; }

    late final Widget content;
    switch (widget.schema.type) {
      case NotificationType.status:
      case NotificationType.reblog:
      case NotificationType.favourite:
      case NotificationType.poll:
      case NotificationType.update:
      case NotificationType.mention:
        final StatusSchema? schema = await status?.getStatus(widget.schema.statusID, loadCache: true);

        content = schema == null ? const SizedBox.shrink() : StatusLite(schema: schema);
        break;
      case NotificationType.follow:
      case NotificationType.followRequest:
        final List<AccountSchema> accounts = await status?.getAccounts(widget.schema.accounts) ?? [];
        content = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: accounts.map((a) => Account(schema: a)).toList(),
        );
        break;
      case NotificationType.unknown:
        content = NoResult();
        break;
    }

    await onLoadAccounts();
    if (mounted) { setState(() => child = content ); }
  }

  // Load the accounts involved in the notification.
  Future<void> onLoadAccounts() async {
    switch (widget.schema.type) {
      case NotificationType.status:
      case NotificationType.reblog:
      case NotificationType.favourite:
      case NotificationType.poll:
      case NotificationType.update:
        final List<AccountSchema> accounts = await status?.getAccounts(widget.schema.accounts) ?? [];
        if (mounted) { setState(() => this.accounts = accounts); }
        return;
      case NotificationType.mention:
      case NotificationType.follow:
      case NotificationType.followRequest:
      case NotificationType.unknown:
    }
  }
}

// vim: set ts=2 sw=2 sts=2 et:
