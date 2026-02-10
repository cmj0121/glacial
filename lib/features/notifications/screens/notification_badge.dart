// The notification badge that shows the unread notifications count.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';

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
  late final AccessStatusSchema? status = ref.read(accessStatusProvider);

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
        _startTask();
        break;
      default:
        break;
    }
  }

  void _startTask({int? times}) {
    final Duration? refreshInterval = pref?.refreshInterval;
    _stopTask();

    if (refreshInterval != null && refreshInterval.inSeconds > 0) {
      final int interval = refreshInterval.inSeconds;

      _timer = Timer.periodic(Duration(seconds: interval * (times ?? 1)), (Timer timer) async {
        await onLoad();
      });
    }
  }

  Future<void> _stopTask() async {
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

    if (!mounted) return;
    if (count > unreadCount) { await onNotify(count); }
    if (mounted) setState(() => unreadCount = count);
  }

  // Send the notification to the user when the unread count is updated.
  Future<void> onNotify(int unreadCount) async {
    final String title = AppLocalizations.of(context)?.msg_notification_title ?? "New Notifications";
    final String body = AppLocalizations.of(context)?.msg_notification_body(unreadCount) ?? "You have $unreadCount new notifications.";

    await sendLocalNotification(title, body, badgeNumber: unreadCount);
  }
}

// vim: set ts=2 sw=2 sts=2 et:
