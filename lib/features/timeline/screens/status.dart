// The Status widget to show the toots from user.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

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
  final double headerHeight = 48.0;
  final double metadataHeight = 22.0;
  final double iconSize = 16.0;

  late final AccessStatusSchema? status = ref.read(accessStatusProvider);
  late final SystemPreferenceSchema? pref = ref.read(preferenceProvider);
  late StatusSchema schema = widget.schema.reblog ?? widget.schema;

  @override
  Widget build(BuildContext context) {
    final bool sensitive = (pref?.sensitive ?? true) && schema.sensitive && schema.spoiler.isEmpty == true;

    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildMetadata(),
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

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(action.icon(active: true), color: Theme.of(context).hintColor, size: metadataHeight),
          const SizedBox(width: 4),
          AccountAvatar(schema: account, size: metadataHeight),
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
      // Open the link in the in-app webview.
      context.push(RoutePath.webview.path, extra: uri);
    }
  }
}

// vim: set ts=2 sw=2 sts=2 et:
