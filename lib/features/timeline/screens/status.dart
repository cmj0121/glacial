// The Status widget to show the toots from user.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

// The single Status widget that contains the status information.
class Status extends ConsumerStatefulWidget {
  final StatusSchema schema;

  const Status({
    super.key,
    required this.schema,
  });

  @override
  ConsumerState<Status> createState() => _StatusState();
}

class _StatusState extends ConsumerState<Status> {
  final double headerHeight = 48.0;
  final double iconSize = 16.0;
  late StatusSchema schema = widget.schema;

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
        buildHeader(),
        buildCoreContent(),

        Application(schema: schema.application),
        const SizedBox(height: 8),
        InteractionBar(schema: schema),
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
}

// vim: set ts=2 sw=2 sts=2 et:
