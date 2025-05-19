// The Status widget to show the toots from user.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:glacial/features/timeline/models/core.dart';

import 'account.dart';
import 'interaction.dart';

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
  late StatusSchema schema;

  @override
  void initState() {
    super.initState();
    schema = widget.schema;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: buildContent(),
      ),
    );
  }

  // Build the main content of the status, including the author, the content
  // and the possible actions
  Widget buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildHeader(),
        const SizedBox(height: 8),
        Html(data: schema.content),

        const SizedBox(height: 8),
        InteractionBar(schema: schema),
      ],
    );
  }

  Widget buildHeader() {
    final String duration = timeago.format(schema.createdAt, locale: 'en_short');

    return Row(
      children: [
        Account(schema: schema.account),

        const Spacer(),

        Text(duration, style: const TextStyle(color: Colors.grey)),
        const SizedBox(width: 4),
        Icon(Icons.public, color: Colors.grey, size: 16),
      ],
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
