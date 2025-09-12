// The account relationship widget to show the relationship between two accounts.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';

// The relationship between accounts, such as following / blocking / muting / etc
class Relationship extends ConsumerStatefulWidget {
  final AccountSchema schema;

  const Relationship({
    super.key,
    required this.schema,
  });

  @override
  ConsumerState<Relationship> createState() => _RelationshipState();
}

class _RelationshipState extends ConsumerState<Relationship> {
  final double size = tabSize;
  late final AccessStatusSchema? status = ref.read(accessStatusProvider);

  RelationshipSchema? schema;

  @override
  void initState() {
    super.initState();
    onRefresh();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        buildMoreActions(),
        const SizedBox(width: 8),
        buildRequest(),
        buildRelationship(),
        const SizedBox(width: 8),
      ],
    );
  }

  // Build the more actions to interactive the account.
  Widget buildMoreActions() {
    return PopupMenuButton(
      icon: const Icon(Icons.more_horiz),
      tooltip: '',
      itemBuilder: (BuildContext context) {
        List<RelationshipType> actions = RelationshipType.values.where((r) => r.isMoreActions).toList();

        actions.remove(schema?.muting == true ? RelationshipType.mute : RelationshipType.unmute);
        actions.remove(schema?.blocking == true ? RelationshipType.block : RelationshipType.unblock);

        return actions.map((RelationshipType action) {
          final bool disabled = action == RelationshipType.report;
          final Color? color = action.isDangerous ? Theme.of(context).colorScheme.error : null;

          return PopupMenuItem(
            value: action,
            enabled: !disabled,
            child: ListTile(
              leading: Icon(action.icon(), size: size),
              title: Text(action.tooltip(context, account: widget.schema)),
              iconColor: disabled ? null : color,
              textColor: disabled ? null : color,
            ),
          );
        }).toList();
      },
      onSelected: (RelationshipType r) async {
        await status?.changeRelationship(account: widget.schema, type: r);
        onRefresh();
      }
    );
  }

  // Build the request button to show the request status if the account is not followed yet.
  Widget buildRequest() {
    Widget icon = Padding(
      padding: const EdgeInsets.only(right: 8),
      child: IconButton(
        icon: Icon(Icons.mark_email_unread_sharp, size: size),
        tooltip: AppLocalizations.of(context)?.btn_notification_follow_request ?? "Follow Request",
        style: IconButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () async {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              final String text = AppLocalizations.of(context)?.msg_follow_request(widget.schema.displayName) ?? "Follow request";
              return AlertDialog(
                title: Text(text, style: Theme.of(context).textTheme.bodyLarge),

                actions: [
                  TextButton.icon(
                    label: Text(AppLocalizations.of(context)?.btn_follow_request_accept ?? "Accept"),
                    icon: Icon(Icons.check, size: tabSize),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.primary,
                    ),
                    onPressed: () async {
                      context.pop();
                      await status?.acceptFollowRequest(widget.schema.id);
                      onRefresh();
                    }
                  ),
                  TextButton.icon(
                    label: Text(AppLocalizations.of(context)?.btn_follow_request_reject ?? "Reject"),
                    icon: Icon(Icons.close, size: tabSize),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                    ),
                    onPressed: () async {
                      context.pop();
                      await status?.rejectFollowRequest(widget.schema.id);
                      onRefresh();
                    }
                  ),
                ],
              );
            },
          );
        }
      ),
    );

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(animation),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      child: schema?.requestedBy == true ? icon : const SizedBox.shrink(),
    );
  }

  // Build the relationship type icon and switch the relationship type when tapped.
  Widget buildRelationship() {
    final bool disabled = relationship == RelationshipType.blockedBy;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(animation),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      child: IconButton(
        key: ValueKey('${widget.schema.id}-${relationship.name}'),
        icon: Icon(relationship.icon(), size: size),
        tooltip: relationship.tooltip(context, account: widget.schema),
        style: IconButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: disabled ? null : onChangeRelationship,
      ),
    );
  }

  // Switch the relationship type when tapped.
  void onChangeRelationship() async {
    final AccessStatusSchema? status = ref.read(accessStatusProvider);
    await status?.changeRelationship(account: widget.schema, type: relationship);
    onRefresh();
  }

  // refresh the relationship state when the relationship is changed.
  void onRefresh() async {
    final AccessStatusSchema? status = ref.read(accessStatusProvider);
    final List<AccountSchema> accounts = [widget.schema];
    final List<RelationshipSchema> relationships = await status?.fetchRelationships(accounts) ?? [];

    setState(() => schema = relationships.firstOrNull);
  }

  RelationshipType get relationship => schema?.type ?? RelationshipType.stranger;
}

// The pending follow request badge to show the pending follow request.
class FollowRequestBadge extends ConsumerStatefulWidget {
  final double size;
  final VoidCallback? onPressed;

  const FollowRequestBadge({
    super.key,
    this.size = iconSize,
    this.onPressed,
  });

  @override
  ConsumerState<FollowRequestBadge> createState() => _FollowRequestBadgeState();
}

class _FollowRequestBadgeState extends ConsumerState<FollowRequestBadge> {
  late final AccessStatusSchema? status = ref.read(accessStatusProvider);

  int pendingCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => onLoad());
  }

  @override
  Widget build(BuildContext context) {
    final SidebarButtonType action = SidebarButtonType.followRequests;

    if (pendingCount == 0) {
      // No need to show the badge when there is no pending follow request or the follow request page is selected.
      return const SizedBox.shrink();
    }

    return Badge.count(
      count: pendingCount,
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: IconButton(
        icon: Icon(action.icon(), size: widget.size),
        tooltip: action.tooltip(context),
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        onPressed: widget.onPressed,
      ),
    );
  }

  // Try to load the ending follow requests when the widget is built.
  Future<void> onLoad() async {
    final List<AccountSchema> accounts = await status?.fetchFollowRequests() ?? [];
    final int count = accounts.length;

    setState(() => pendingCount = count);
  }
}

// vim: set ts=2 sw=2 sts=2 et:
