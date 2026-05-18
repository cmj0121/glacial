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
  Timer? _timer;
  Duration? _scheduledInterval;
  bool _loadInFlight = false;
  int unreadCount = 0;

  AccessStatusSchema? get _status => ref.read(accessStatusProvider);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Fetch immediately on cold start so the badge doesn't wait a full
      // refresh interval before showing unread count.
      onLoad();
      _startTaskIfForeground();
    });
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

  void _startTask() {
    final Duration? refreshInterval = ref.read(preferenceProvider)?.refreshInterval;
    if (refreshInterval == _scheduledInterval && _timer != null) return;

    _stopTask();
    _scheduledInterval = refreshInterval;

    if (refreshInterval != null && refreshInterval.inSeconds > 0) {
      _timer = Timer.periodic(refreshInterval, (Timer timer) {
        onLoad();
      });
    }
  }

  void _stopTask() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  Widget build(BuildContext context) {
    // Listen to preference changes so a refreshInterval update reschedules the
    // timer; we don't use the value here, but the watch wires up the rebuild.
    ref.listen<SystemPreferenceSchema?>(
      preferenceProvider,
      (_, _) => _startTaskIfForeground(),
    );
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
    if (_loadInFlight) return;
    _loadInFlight = true;
    try {
      final int count = await _status?.getUnreadGroupCount() ?? 0;
      if (!mounted) return;
      if (count > unreadCount) await onNotify(count);
      if (!mounted) return;
      setState(() => unreadCount = count);
    } finally {
      _loadInFlight = false;
    }
  }

  // Send the notification to the user when the unread count is updated.
  Future<void> onNotify(int unreadCount) async {
    final l10n = AppLocalizations.of(context);
    final String title = l10n?.msg_notification_title ?? "New Notifications";
    final String body = l10n?.msg_notification_body(unreadCount) ?? "You have $unreadCount new notifications.";

    await sendLocalNotification(title, body, badgeNumber: unreadCount);
  }
}

// vim: set ts=2 sw=2 sts=2 et:
