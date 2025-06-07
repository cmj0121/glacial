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
  final int indent;
  final AccountSchema? reblogFrom;
  final String? replyToAccountID;
  final VoidCallback? onDeleted;

  const Status({
    super.key,
    required this.schema,
    this.indent = 0,
    this.reblogFrom,
    this.replyToAccountID,
    this.onDeleted,
  });

  @override
  ConsumerState<Status> createState() => _StatusState();
}

class _StatusState extends ConsumerState<Status> {
  final double metadataHeight = 22;
  final Storage storage = Storage();

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
        buildSensitiveView(),

        Application(schema: schema.application),
      ],
    );
  }

  // The header of the status, which includes the account information, the status
  // posted time, and the visibility status.
  Widget buildHeader() {
    final String duration = timeago.format(schema.createdAt, locale: 'en_short');

    return Row(
      children: [
        Expanded(
          flex: 10,
          child: Account(schema: schema.account),
        ),

        const Spacer(),

        Tooltip(
          message: schema.createdAt.toLocal().toString(),
          child: Text(duration, style: const TextStyle(color: Colors.grey)),
        ),
        const SizedBox(width: 4),
        StatusVisibility(type: schema.visibility, size: 16, isCompact: true),
      ],
    );
  }

  // Build the possible sensitive content of the status, including the
  // spoiler text and the media attachments.
  Widget buildSensitiveView() {
    final Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HtmlDone(
          html: schema.content,
          onLinkTap: onLinkTap,
        ),

        Attachments(schemas: schema.attachments),
      ],
    );

    if (!schema.sensitive) {
      return content;
    }

    return SensitiveView(
      spoiler: schema.spoiler,
      child: content,
    );
  }

  // reload the status when the user interacts with it.
  void onReload(StatusSchema schema) async {
    // fetch the status again from the server, and update the status
    setState(() => this.schema = schema);
  }

  // Handle the link tap event, and open the link in the in-app webview.
  void onLinkTap(String? url, Map<String, String> attributes, _) {
    final Uri? uri = url == null ? null : Uri.parse(url);
    if (uri == null) {
      return;
    }

    context.push(RoutePath.webview.path, extra: uri);
  }
}

// vim: set ts=2 sw=2 sts=2 et:
