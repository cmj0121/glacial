// The Status widget to show the toots from user.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart'; // ignore: deprecated_member_use

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';
import 'package:glacial/features/timeline/screens/reaction_chips.dart';

/// The single Status widget that contains the status information.
class Status extends ConsumerStatefulWidget {
  final int indent;
  final StatusSchema schema;
  final ValueChanged<StatusSchema>? onReload;
  final VoidCallback? onDeleted;

  const Status({
    super.key,
    this.indent = 0,
    required this.schema,
    this.onReload,
    this.onDeleted,
  });

  @override
  ConsumerState<Status> createState() => _StatusState();
}

class _StatusState extends ConsumerState<Status> {
  final double headerHeight = 40.0;
  final double metadataHeight = 22.0;
  final double iconSize = 16.0;

  late final AccessStatusSchema? status = ref.read(accessStatusProvider);
  late final SystemPreferenceSchema? pref = ref.read(preferenceProvider);
  late StatusSchema schema = widget.schema.reblog ?? widget.schema;

  bool _showHeartOverlay = false;

  @override
  Widget build(BuildContext context) {
    final bool sensitive = (pref?.sensitive ?? true) && schema.sensitive && schema.spoiler.isEmpty == true;
    final bool isSignedIn = status?.isSignedIn == true;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildMetadata(),
          GestureDetector(
            onDoubleTap: isSignedIn ? _onDoubleTapFavourite : null,
            onLongPress: isSignedIn ? () => _showContextMenu(context) : null,
            child: Stack(
              alignment: Alignment.center,
              children: [
                StatusLite(
                  schema: schema,
                  indent: widget.indent,
                  spoiler: schema.spoiler.isEmpty ? null : schema.spoiler,
                  sensitive: sensitive,
                  iconSize: iconSize,
                  headerHeight: headerHeight,
                  onPollVote: (_) async {
                    final StatusSchema updatedStatus = await status?.getStatus(schema.id) ?? schema;
                    onReload(updatedStatus);
                  },
                  onLinkTap: onLinkTap,
                ),
                if (_showHeartOverlay)
                  Icon(Icons.favorite, size: 80, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7)),
              ],
            ),
          ),

          ReactionChips(
            schema: schema,
            onReload: onReload,
          ),

          const SizedBox(height: 8),

          InteractionBar(
            schema: schema,
            onReload: onReload,
            onDeleted: widget.onDeleted,
          ),
        ],
      ),
    );
  }

  Future<void> _showContextMenu(BuildContext context) async {
    HapticFeedback.mediumImpact();

    final l10n = AppLocalizations.of(context);
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset offset = box.localToGlobal(Offset.zero);

    final action = await showMenu<StatusInteraction>(
      context: context,
      position: RelativeRect.fromLTRB(offset.dx, offset.dy + box.size.height / 2, offset.dx + box.size.width, 0),
      items: [
        PopupMenuItem(value: StatusInteraction.reply, child: ListTile(leading: Icon(StatusInteraction.reply.icon()), title: Text(l10n?.btn_interaction_reply ?? 'Reply'), dense: true)),
        PopupMenuItem(value: StatusInteraction.reblog, child: ListTile(leading: Icon(StatusInteraction.reblog.icon(active: schema.reblogged ?? false)), title: Text(l10n?.btn_interaction_reblog ?? 'Boost'), dense: true)),
        PopupMenuItem(value: StatusInteraction.favourite, child: ListTile(leading: Icon(StatusInteraction.favourite.icon(active: schema.favourited ?? false)), title: Text(l10n?.btn_interaction_favourite ?? 'Favourite'), dense: true)),
        PopupMenuItem(value: StatusInteraction.bookmark, child: ListTile(leading: Icon(StatusInteraction.bookmark.icon(active: schema.bookmarked ?? false)), title: Text(l10n?.btn_interaction_bookmark ?? 'Bookmark'), dense: true)),
        PopupMenuItem(value: StatusInteraction.share, child: ListTile(leading: Icon(StatusInteraction.share.icon()), title: Text(l10n?.btn_interaction_share ?? 'Share'), dense: true)),
      ],
    );

    if (action == null || status == null || !mounted) return;

    if (action == StatusInteraction.reply) {
      if (mounted) this.context.push(RoutePath.post.path, extra: schema);
      return;
    }

    if (action == StatusInteraction.share) {
      if (schema.url != null) SharePlus.instance.share(ShareParams(text: schema.url!));
      return;
    }

    if (action == StatusInteraction.reblog || action == StatusInteraction.favourite || action == StatusInteraction.bookmark) {
      final updatedStatus = await status!.interactWithStatus(
        schema, action,
        negative: action == StatusInteraction.reblog ? (schema.reblogged ?? false)
            : action == StatusInteraction.favourite ? (schema.favourited ?? false)
            : (schema.bookmarked ?? false),
      );
      onReload(updatedStatus);
    }
  }

  Future<void> _onDoubleTapFavourite() async {
    if (status == null) return;

    setState(() => _showHeartOverlay = true);
    HapticFeedback.mediumImpact();

    final updatedStatus = await status!.interactWithStatus(
      schema,
      StatusInteraction.favourite,
      negative: schema.favourited ?? false,
    );
    onReload(updatedStatus);

    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) setState(() => _showHeartOverlay = false);
  }

  /// The optional metadata of the status, including the status reply or reblog
  /// from the user.
  Widget buildMetadata() {
    if (widget.schema.reblog == null && widget.schema.inReplyToAccountID == null) {
      // The status is a normal status, so no need to show the metadata.
      return const SizedBox.shrink();
    }

    final AccessStatusSchema status = ref.read(accessStatusProvider) ?? AccessStatusSchema();
    late final AccountSchema account;
    late final StatusInteraction action;

    if (widget.schema.inReplyToAccountID != null) {
      // The status is a reply to another status, so show the reply account.
      final AccountSchema? inReplyToAccount = status.lookupAccount(widget.schema.inReplyToAccountID!);

      if (inReplyToAccount == null) {
        // If the account is not found, we cannot show the reply metadata.
        logger.w("cannot get the account from cache: ${widget.schema.inReplyToAccountID}");
        return const SizedBox.shrink();
      }

      account = inReplyToAccount;
      action = StatusInteraction.reply;
    } else {
      account = widget.schema.account;
      action = StatusInteraction.reblog;
    }

    final String label = account.displayName;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(action.icon(active: true), color: Theme.of(context).hintColor, size: metadataHeight),
          const SizedBox(width: 8),
          AccountAvatar(schema: account, size: metadataHeight),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).hintColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Reload the status when the status is reblogged or updated.
  void onReload(StatusSchema status) {
    if (mounted) {
      setState(() => schema = status.reblog ?? status);
      widget.onReload?.call(status);
    }
  }

  /// Handle the link tap event, and open the link in the in-app webview.
  Future<void> onLinkTap(String? url) async {
    final Uri? uri = url == null ? null : Uri.parse(url);

    if (uri == null) {
      return;
    }

    // Link belong to the same domain, so we can open it in the app.
    final String path = uri.path;

    if (path.startsWith('/@')) {
      // The link is an account link, so we can open the profile.
      final String acct = uri.pathSegments.isNotEmpty ? uri.pathSegments.first.substring(1) : '';
      final List<AccountSchema> accounts = await status?.searchAccounts(acct) ?? [];
      final AccountSchema? account = accounts.where((a) => a.acct == acct).firstOrNull;

      if (mounted && account != null) {
        // only push the profile route if the account is found
        context.push(RoutePath.profile.path, extra: account);
        return;
      }
    } else if (path.startsWith('/tags/')) {
      // The link is a tag link, so we can open the tag search.
      final String tag = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : '';

      if (mounted && tag.isNotEmpty) {
        // only push the hashtag route if the tag is not empty
        context.push(RoutePath.hashtag.path, extra: tag);
        return;
      }
    }

    if (mounted) {
      openLink(context, uri, ref: ref);
    }
  }
}

// vim: set ts=2 sw=2 sts=2 et:
