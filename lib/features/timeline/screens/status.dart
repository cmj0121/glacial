// The Status widget to show the toots from user.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  late StatusSchema schema = widget.schema;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: buildContent(),
    );
  }

  // Build the main content of the status, including the author, the content
  // and the possible actions
  Widget buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HtmlDone(
          html: schema.content,
        ),
        const SizedBox(height: 8),
        InteractionBar(schema: schema),
      ],
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
