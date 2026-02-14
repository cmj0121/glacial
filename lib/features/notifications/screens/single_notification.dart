// The single notification widget for rendering individual notification groups.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

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
      return const LoadingOverlay(isLoading: true, child: SizedBox(height: 100));
    }

    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 8),
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
      case NotificationType.adminSignUp:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildHeader(),
            const SizedBox(height: 8),
            child ?? const SizedBox.shrink(),
          ],
        );
      case NotificationType.adminReport:
      case NotificationType.unknown:
        logger.d("Unknown notification type: ${widget.schema.type}");
        return buildHeader();
    }
  }

  // Build the optional header for the notification, which shows the accounts involved in the notification.
  Widget buildHeader() {
    final TextStyle? style = Theme.of(context).textTheme.labelMedium;
    final Color color = widget.schema.type.isAdminOnly ? Theme.of(context).colorScheme.error : Theme.of(context).disabledColor;

    final List<Widget> icons = [
      Icon(widget.schema.type.icon, size: widget.iconSize - 2, color: color),
      const SizedBox(width: 4),
      Text(widget.schema.type.tooltip(context), style: style?.copyWith(color: color)),
    ];

    return Row(
      children: [
        ...accounts.map((a) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: AccountAvatar(schema: a, size: widget.iconSize),
        )),
        ...icons,
      ],
    );
  }

  Future<void> onLoad() async {
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
      case NotificationType.adminSignUp:
        final List<AccountSchema> accounts = await status?.getAccounts(widget.schema.accounts) ?? [];
        content = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: accounts.map((a) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Account(schema: a),
          )).toList(),
        );
        break;
      case NotificationType.adminReport:
      case NotificationType.unknown:
        content = const NoResult();
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
      case NotificationType.adminSignUp:
      case NotificationType.adminReport:
      case NotificationType.unknown:
    }
  }
}

// vim: set ts=2 sw=2 sts=2 et:
