// The interaction button that interacts with the current status, which
// may disable the button if the action is not supported for now.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

class Interaction extends ConsumerStatefulWidget {
  final StatusSchema schema;
  final AccessStatusSchema status;
  final StatusInteraction action;
  final bool isCompact;
  final VoidCallback? onPressed;
  final ValueChanged<StatusSchema>? onReload;
  final VoidCallback? onDeleted;

  const Interaction({
    super.key,
    required this.schema,
    required this.status,
    required this.action,
    this.isCompact = true,
    this.onPressed,
    this.onReload,
    this.onDeleted,
  });

  @override
  ConsumerState<Interaction> createState() => _InteractionState();
}

class _InteractionState extends ConsumerState<Interaction> {
  @override
  Widget build(BuildContext context) {
    return widget.isCompact ? buildCompactIcon() : buildFullButton(context);
  }

  // Build the compact icon for the interaction that only show the icon and the
  // count of the interaction.
  Widget buildCompactIcon() {
    final String tooltip = widget.action.tooltip(context);

    return Semantics(
      label: tooltip,
      button: true,
      enabled: isAvailable,
      child: Tooltip(
        message: tooltip,
        child: TextButton.icon(
          label: count == null ? const SizedBox.shrink() : Text(count.toString()),
          icon: Icon(icon, size: tabSize, color: color),
          style: TextButton.styleFrom(foregroundColor: color),
          onPressed: isAvailable ? onPressed : null,
        ),
      ),
    );
  }

  // Build the normal icon for the interaction that shows the icon and the
  // action text.
  Widget buildFullButton(BuildContext context) {
    late final String title;

    switch (widget.action) {
      case StatusInteraction.policy:
        final QuotePolicyType policy = widget.schema.quoteApproval?.toUser ?? QuotePolicyType.nobody;
        title = policy.title(context);
        break;
      default:
        title = widget.action.tooltip(context);
        break;
    }

    return ListTile(
      leading: Icon(icon, size: tabSize),
      title: Text(title),
      textColor: color,
      iconColor: color,
      onTap: isAvailable ? onPressed : null,
    );
  }

  // The action is available if the user is signed in or the action is supported anonymously
  bool get isAvailable {
    if (isScheduled) {
      // If the post is scheduled, only the edit and delete actions are available.
      return widget.action == StatusInteraction.edit || widget.action == StatusInteraction.delete;
    }

    switch (widget.action) {
      case StatusInteraction.quote:
        switch (widget.schema.quoteApproval?.currentUser) {
          case CurrentQuoteApprovalType.automatic:
          case CurrentQuoteApprovalType.manual:
            return true;
          default:
            return false;
        }
      case StatusInteraction.reply:
      case StatusInteraction.reblog:
      case StatusInteraction.favourite:
      case StatusInteraction.bookmark:
      case StatusInteraction.mute:
        return isSignedIn;
      case StatusInteraction.share:
        return true;
      case StatusInteraction.pin:
      case StatusInteraction.edit:
      case StatusInteraction.policy:
      case StatusInteraction.delete:
        return isSignedIn && isSelfPost;
      case StatusInteraction.filter:
      case StatusInteraction.block:
      case StatusInteraction.report:
        return isSignedIn && !isSelfPost;
    }
  }

  // The action now is available or activated.
  bool get isActive {
    switch (widget.action) {
      case StatusInteraction.share:
        return true;
      case StatusInteraction.reply:
        return false;
      case StatusInteraction.reblog:
        return widget.schema.reblogged ?? false;
      case StatusInteraction.favourite:
        return widget.schema.favourited ?? false;
      case StatusInteraction.bookmark:
        return widget.schema.bookmarked ?? false;
      case StatusInteraction.pin:
        return widget.schema.pinned ?? false;
      case StatusInteraction.mute:
        return widget.schema.muted ?? false;
      case StatusInteraction.delete:
      case StatusInteraction.edit:
        return isSelfPost;
      case StatusInteraction.report:
        return !isSelfPost;
      default:
        return isSignedIn;
    }
  }

  // Get the icon for the interaction, which may be active or not based on the
  // current status of the interaction.
  IconData get icon {
    switch (widget.action) {
      case StatusInteraction.policy:
        final QuotePolicyType policy = widget.schema.quoteApproval?.toUser ?? QuotePolicyType.nobody;
        return policy.icon;
      default:
        return widget.action.icon(active: isActive); // Replace with actual logic to determine active state
    }
  }

  // The total count of the interaction of the status, if applicable.
  int? get count {
    switch (widget.action) {
      case StatusInteraction.reply:
        return widget.schema.repliesCount;
      case StatusInteraction.quote:
        return widget.schema.quotesCount;
      case StatusInteraction.reblog:
        return widget.schema.reblogsCount;
      case StatusInteraction.favourite:
        return widget.schema.favouritesCount;
      default:
        return null; // No count for other actions
    }
  }

  // Get the icon color based on the type of the interaction.
  Color get color {
    if (!isAvailable) {
      // Use disabled color if not available
      return Theme.of(context).disabledColor;
    }

    final Color defaultColor = Theme.of(context).colorScheme.onSurface;

    switch (widget.action) {
      case StatusInteraction.filter:
      case StatusInteraction.block:
      case StatusInteraction.edit:
      case StatusInteraction.delete:
        return Theme.of(context).colorScheme.error;
      case StatusInteraction.mute:
        return isActive ? Theme.of(context).colorScheme.tertiary : defaultColor;
      case StatusInteraction.reblog:
        return isActive ? Theme.of(context).colorScheme.tertiary : defaultColor;
      case StatusInteraction.favourite:
        return isActive ? Theme.of(context).colorScheme.tertiary : defaultColor;
      case StatusInteraction.bookmark:
        return isActive ? Theme.of(context).colorScheme.tertiary : defaultColor;
      case StatusInteraction.pin:
        return isActive ? Theme.of(context).colorScheme.tertiary : defaultColor;
      case StatusInteraction.report:
        return Theme.of(context).colorScheme.error;
      default:
        return defaultColor;
    }
  }

  Future<void> onPressed() async {
    switch (widget.action) {
      case StatusInteraction.reply:
        context.push(RoutePath.post.path, extra: widget.schema);
        return;
      case StatusInteraction.quote:
        context.push(RoutePath.postQuote.path, extra: widget.schema);
        return;
      case StatusInteraction.reblog:
      case StatusInteraction.favourite:
      case StatusInteraction.bookmark:
      case StatusInteraction.pin:
        _haptic();
        final StatusSchema updatedStatus = await widget.status.interactWithStatus(
          widget.schema,
          widget.action,
          negative: isActive,
        );

        widget.onReload?.call(updatedStatus);
        return;
      case StatusInteraction.edit:
        context.pop();
        context.push(RoutePath.edit.path, extra: widget.schema);
        return;
      case StatusInteraction.policy:
        context.pop();

        final QuotePolicyType policy = widget.schema.quoteApproval?.toUser ?? QuotePolicyType.nobody;
        final StatusSchema updatedStatus = await widget.status.editStatusInteractionPolicy(
          schema: widget.schema,
          policy: policy.next,
        );

        widget.onReload?.call(updatedStatus);
        return;
      case StatusInteraction.delete:
        if (mounted) context.pop();
        final confirmedDelete = await showConfirmDialog(
          context: context,
          title: AppLocalizations.of(context)?.txt_admin_confirm_action ?? 'Confirm',
          message: AppLocalizations.of(context)?.msg_confirm_delete_post ?? 'Are you sure you want to delete this post?',
        );
        if (!confirmedDelete || !mounted) return;
        await widget.status.deleteStatus(widget.schema);
        widget.onDeleted?.call();
        return;
      case StatusInteraction.share:
        _haptic();
        try {
          final String uri = widget.schema.uri;
          final String plainText = widget.schema.plainText;
          final String content = plainText.isNotEmpty ? '$plainText\n$uri' : uri;
          await Share.share(content);
        } catch (_) {
          if (!mounted) return;
          Clipboard.setData(ClipboardData(text: widget.schema.uri));
          final String text = AppLocalizations.of(context)?.msg_copied_to_clipboard ?? "Copy to clipboard";
          showSnackbar(context, text);
        }
        return;
      case StatusInteraction.filter:
        context.pop();
        showAdaptiveGlassDialog(
          context: context,
          builder: (BuildContext context) => FilterSelector(
            status: widget.schema,
            onSelected: (filter) async {
              context.pop();

              await widget.status.addFilterStatus(filter: filter, status: widget.schema);

              final StatusSchema? updatedStatus = await widget.status.getStatus(widget.schema.id);
              if (updatedStatus != null) widget.onReload?.call(updatedStatus);
            },
            onDeleted: (filter) async {
              context.pop();

              final List<FilterStatusSchema> statusFilters = await widget.status.fetchFilterStatuses(filter: filter);
              final FilterStatusSchema? status = statusFilters.where((s) => s.statusId == widget.schema.id).firstOrNull;
              if (status == null) return;

              await widget.status.removeFilterStatus(status: status);

              final StatusSchema? updatedStatus = await widget.status.getStatus(widget.schema.id);
              if (updatedStatus != null) widget.onReload?.call(updatedStatus);
            },
          ),
        );
        return;
      case StatusInteraction.mute:
        _haptic();
        final StatusSchema mutedStatus = await widget.status.interactWithStatus(
          widget.schema,
          widget.action,
          negative: isActive,
        );

        widget.onReload?.call(mutedStatus);
        return;
      case StatusInteraction.block:
        if (mounted) context.pop();
        final confirmedBlock = await showConfirmDialog(
          context: context,
          title: AppLocalizations.of(context)?.txt_admin_confirm_action ?? 'Confirm',
          message: AppLocalizations.of(context)?.msg_confirm_block(widget.schema.account.displayName) ?? 'Block this account?',
        );
        if (!confirmedBlock || !mounted) return;
        await widget.status.changeRelationship(account: widget.schema.account, type: RelationshipType.block);
        widget.onDeleted?.call();
        return;
      case StatusInteraction.report:
        // Pop the opened menu first, then show the report dialog
        if (mounted) context.pop();

        showAdaptiveGlassDialog(
          context: context,
          builder: (BuildContext context) => ReportDialog(account: widget.schema.account, status: widget.schema),
        );
        return;
    }
  }

  void _haptic() {
    final bool enabled = ref.read(preferenceProvider)?.hapticFeedback ?? true;
    if (enabled) HapticFeedback.lightImpact();
  }

  bool get isSignedIn => widget.status.accessToken?.isNotEmpty == true;
  bool get isSelfPost => widget.schema.account.id == widget.status.account?.id;
  bool get isScheduled => widget.schema.scheduledAt != null;
}

// vim: set ts=2 sw=2 sts=2 et:
