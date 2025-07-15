// The Notification widget in the current selected Mastodon server.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

// The notification badge that shows the unread notifications count.
class NotificationBadge extends ConsumerStatefulWidget {
  final double size;
  final bool isSelected;

  const NotificationBadge({
    super.key,
    this.size = 24,
    this.isSelected = false,
  });

  @override
  ConsumerState<NotificationBadge> createState() => _NotificationBadgeState();
}

class _NotificationBadgeState extends ConsumerState<NotificationBadge> with WidgetsBindingObserver {
  late final ServerSchema? server = ref.read(serverProvider);
  late final String? accessToken = ref.read(accessTokenProvider);

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    _startTaskIfForeground();
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
        onLoad();
        _startTask();
        break;
      default:
        // logger.d("App is not in foreground, skipping task start: $currentState.");
        _stopTask();
        break;
    }
  }

  void _startTask() {
    _stopTask();
    _timer = Timer.periodic(const Duration(seconds: 30), (Timer timer) {
      onLoad();
    });
  }

  void _stopTask() async {
    _timer?.cancel();
    _timer = null;
  }

  @override
  Widget build(BuildContext context) {
    final int unreadCount = ref.watch(unreadNotifyCountProvider);
    final SidebarButtonType action = SidebarButtonType.notifications;
    final Widget icon = Icon(action.icon(active: widget.isSelected), size: widget.size);

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
  void onLoad() async {
    final int count = await server?.unreadNotificationsCount(accessToken: accessToken) ?? 0;
    ref.read(unreadNotifyCountProvider.notifier).state = count;
  }
}

class GroupNotification extends ConsumerStatefulWidget {
  const GroupNotification({super.key});

  @override
  ConsumerState<GroupNotification> createState() => _GroupNotificationState();
}

class _GroupNotificationState extends ConsumerState<GroupNotification> {
  final double loadingThreshold = 180;

  late final ScrollController controller = ScrollController();
  late final ServerSchema? server = ref.read(serverProvider);
  late final String? accessToken = ref.read(accessTokenProvider);

  bool isLoading = false;
  List<GroupSchema> groups = [];

  @override
  void initState() {
    super.initState();
    controller.addListener(onScroll);
    GlobalController.scrollToTop = controller;
    onLoad();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (server == null) {
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
    return ListView.builder(
      controller: controller,
      itemCount: groups.length,
      itemBuilder: (BuildContext context, int index) {
        final GroupSchema group = groups[index];

        return Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
          ),
          child: Padding(
            padding: EdgeInsets.only(right: 16),
            child: SingleNotification(schema: group),
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

  Future<void> onLoad() async {
    final String? maxId = groups.isNotEmpty ? groups.last.pageMaxID : null;

    if (isLoading) {
      return;
    }
    setState(() => isLoading = true);

    final GroupNotificationSchema? schema = await server?.listNotifications(accessToken: accessToken, maxId: maxId);

    onResetUnreadCount(schema?.groups.first.id);
    setState(() => groups.addAll(schema?.groups ?? []));
    setState(() => isLoading = false);
  }

  Future<void> onResetUnreadCount(int? lastReadId) async {
    final TimelineMarkerType type = TimelineMarkerType.notifications;
    final int unreadCount = ref.read(unreadNotifyCountProvider);

    if (unreadCount == 0) {
      return; // No unread notifications to reset.
    }

    await server?.updateTimelinePosition(accessToken: accessToken, id: lastReadId.toString(), type: type);
    ref.read(unreadNotifyCountProvider.notifier).state = 0;
  }
}

class SingleNotification extends ConsumerWidget {
  final GroupSchema schema;

  const SingleNotification({
    super.key,
    required this.schema,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ServerSchema? server = ref.watch(serverProvider);
    final String? accessToken = ref.watch(accessTokenProvider);

    if (server == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: buildContent(context, server: server, accessToken: accessToken),
    );
  }

  // Build the notification based on the type of the schema.
  Widget buildContent(BuildContext context, {required ServerSchema server, String? accessToken}) {
    late final Widget content;

    switch (schema.type) {
      case NotificationType.favourite:
      case NotificationType.reblog:
        content = FutureBuilder(
          future: server.getStatus(schema.statusID!, accessToken: accessToken),
          builder: (BuildContext context, AsyncSnapshot<StatusSchema?> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const ClockProgressIndicator();
            } else if (snapshot.hasError || !snapshot.hasData) {
              return const SizedBox.shrink();
            }

            final StatusSchema status = snapshot.data!;
            return ColorFiltered(
              colorFilter: ColorFilter.mode(Colors.grey, BlendMode.modulate),
              child: StatusLight(schema: status),
            );
          },
        );

        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildHeader(context, server: server),
            const SizedBox(height: 8),
            Transform.scale(
              scale: 0.9,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: content,
                ),
              ),
            ),
          ],
        );
      case NotificationType.mention:
      case NotificationType.poll:
        return FutureBuilder(
          future: server.getStatus(schema.statusID!, accessToken: accessToken),
          builder: (BuildContext context, AsyncSnapshot<StatusSchema?> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const ClockProgressIndicator();
            } else if (snapshot.hasError || !snapshot.hasData) {
              return const SizedBox.shrink();
            }

            final StatusSchema status = snapshot.data!;
            return StatusLight(schema: status);
          },
        );
      case NotificationType.follow:
        return FutureBuilder(
          future: server.getAccounts(schema.accounts, accessToken: accessToken),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const ClockProgressIndicator();
            } else if (snapshot.hasError || !snapshot.hasData) {
              logger.w("failed to load accounts for notification: ${snapshot.error}");
              return const SizedBox.shrink();
            }

            final List<AccountSchema> accounts = snapshot.data!;
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.person_add, color: Theme.of(context).colorScheme.tertiary, size: 24),
                const SizedBox(height: 8),
                Column(
                  children: accounts.map((a) => ColorFiltered(
                    colorFilter: ColorFilter.mode(Colors.grey, BlendMode.modulate),
                    child: Account(schema: a))
                  ).toList(),
                ),
              ],
            );
          },
        );
      default:
        return Text("not implemented yet: ${schema.type}", style: TextStyle(color: Colors.red));
    }
  }

  // Build the related accounts based on the schema.
  Widget buildHeader(BuildContext context, {required ServerSchema server}) {
    final double iconSize = 24;
    final Storage storage = Storage();
    final List<AccountSchema?> accounts = schema.accounts.map((a) => storage.loadAccountFromCache(server, a)).toList();

    late final IconData? icon;
    switch (schema.type) {
      case NotificationType.favourite:
        icon = StatusInteraction.favourite.icon(active: true);
        break;
      case NotificationType.reblog:
        icon = StatusInteraction.reblog.icon(active: true);
        break;
      default:
        icon = null;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        icon == null ? const SizedBox.shrink() : Icon(icon, size: iconSize, color: Theme.of(context).colorScheme.tertiary),
        const SizedBox(width: 8),
        ...accounts.map((account) {
          if (account == null) {
            return const SizedBox.shrink();
          }

          final Widget avatar = CachedNetworkImage(
            imageUrl: account.avatar,
            placeholder: (context, url) => const ClockProgressIndicator(),
            errorWidget: (context, url, error) => const Icon(Icons.error),
            width: iconSize,
            height: iconSize,
            fit: BoxFit.cover,
          );
          return Padding(
            padding: const EdgeInsets.only(right: 4),
            child: ClipOval(
              child: InkWellDone(
                onTap: () => context.push(RoutePath.profile.path, extra: account),
                child: avatar,
              ),
            ),
          );
        }),
      ],
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
