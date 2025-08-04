// The Status widget to show the toots from user.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

// The single Status widget that contains the status information.
class Status extends ConsumerStatefulWidget {
  final StatusSchema schema;
  final ValueChanged<StatusSchema>? onReload;

  const Status({
    super.key,
    required this.schema,
    this.onReload,
  });

  @override
  ConsumerState<Status> createState() => _StatusState();
}

class _StatusState extends ConsumerState<Status> {
  final double headerHeight = 48.0;
  final double metadataHeight = 22.0;
  final double iconSize = 16.0;

  late StatusSchema schema = widget.schema.reblog ?? widget.schema;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: buildContent(),
    );
  }

  // Build the main content of the status, including the author, the content
  // and the possible actions.
  Widget buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildMetadata(),
        buildHeader(),
        buildCoreContent(),

        Application(schema: schema.application),
        const SizedBox(height: 8),
        InteractionBar(schema: schema, onReload: onReload),
      ],
    );
  }

  // Build the core content of the status which may be hidden or shown by the
  // status visibility.
  Widget buildCoreContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HtmlDone(html: schema.content),
        Poll(schema: schema.poll),
        Attachments(schemas: schema.attachments),
      ],
    );
  }

  // The optional metadata of the status, including the status reply or reblog
  // from the user.
  Widget buildMetadata() {
    if (widget.schema.reblog == null && widget.schema.inReplyToAccountID == null) {
      // The status is a normal status, so no need to show the metadata.
      return SizedBox.shrink();
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
        return SizedBox.shrink();
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
          Icon(action.icon(active: true), color: Colors.grey, size: metadataHeight),
          const SizedBox(width: 4),
          Account(schema: account, size: metadataHeight, isCompact: true),
        ],
      ),
    );
  }

  // Build the header of the status, including the author and the date and
  // visibility information.
  Widget buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Account(schema: schema.account, size: headerHeight),
        const Spacer(),
        buildTimeInfo(),
        StatusVisibility(type: schema.visibility, size: iconSize),
        const SizedBox(width: 4),
      ],
    );
  }

  // Build the post time information, showing the time since the post was created.
  Widget buildTimeInfo() {
    final String duration = timeago.format(schema.createdAt, locale: 'en_short');
    final Widget editedAt = Tooltip(
      message: schema.editedAt?.toLocal().toString() ?? '-',
      child: Icon(Icons.edit_outlined, size: iconSize, color: Colors.grey),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          schema.editedAt == null ? const SizedBox.shrink() : editedAt,
          const SizedBox(width: 8),
          Tooltip(
            message: schema.createdAt.toLocal().toString(),
            child: Text(duration, style: const TextStyle(color: Colors.grey)),
          ),
        ]
      ),
    );
  }

  void onReload(StatusSchema status) {
    if (mounted) {
      setState(() => schema = status.reblog ?? status);
      widget.onReload?.call(status);
    }
  }
}

// vim: set ts=2 sw=2 sts=2 et:
