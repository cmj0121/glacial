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
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: InkWellDone(
        onTap: () {
          final RoutePath path = RoutePath.values.firstWhere((r) => r.path == GoRouterState.of(context).uri.path);

          if (path == RoutePath.status) {
            // already in the status context, replace it
            context.replace(RoutePath.status.path, extra: schema);
            return;
          }
          context.push(RoutePath.status.path, extra: schema);
        },
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
        buildMetadata(),
        buildHeader(),
        const SizedBox(height: 8),
        Indent(
          indent: widget.indent,
          child: buildSensitiveView(),
        ),

        Application(schema: schema.application),
        const SizedBox(height: 8),
        InteractionBar(schema: schema, onReload: onReload, onDeleted: widget.onDeleted),
      ],
    );
  }

  // The optional metadata of the status, including the status reply or reblog
  // from the user.
  Widget buildMetadata() {
    if (widget.reblogFrom == null && widget.replyToAccountID == null) {
      return SizedBox.shrink();
    }

    final ServerSchema? schema = ref.read(serverProvider);
    final AccountSchema? account = storage.loadAccountFromCache(schema!, widget.reblogFrom?.id ?? widget.replyToAccountID);
    final IconData icon = widget.reblogFrom != null ?
        StatusInteraction.reblog.icon(active: true) :
        StatusInteraction.reply.icon(active: true);

    if (account == null) {
      return SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: metadataHeight),
          const SizedBox(width: 4),
          Account(schema: account, maxHeight: metadataHeight),
        ],
      ),
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
          emojis: schema.emojis,
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
    final Uri baseUri = Uri.parse(schema.uri);
    final Uri? uri = url == null ? null : Uri.parse(url);
    if (uri == null) {
      return;
    }

    // check if the url is the tag from the Mastodon server
    if (schema.tags.any((tag) => uri == baseUri.replace(path: '/tags/${tag.name}'))) {
      // navigate to the tag timeline
      final String path = Uri.decodeFull(uri.path);
      final String tag = path.substring(path.lastIndexOf('/') + 1);

      context.push(RoutePath.hashtag.path, extra: tag);
      return;
    }

    context.push(RoutePath.webview.path, extra: uri);
  }
}

// The lightweight Status widget
class StatusLight extends StatelessWidget {
  final StatusSchema schema;

  const StatusLight({
    super.key,
    required this.schema,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: InkWellDone(
        onTap: () {
          final RoutePath path = RoutePath.values.firstWhere((r) => r.path == GoRouterState.of(context).uri.path);

          if (path == RoutePath.status) {
            // already in the status context, replace it
            context.replace(RoutePath.status.path, extra: schema);
            return;
          }
          context.push(RoutePath.status.path, extra: schema);
        },
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
        HtmlDone(
          html: schema.content,
          emojis: schema.emojis,
        ),

        Attachments(schemas: schema.attachments),
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
}

// The single Status widget that contains the status information.
class StatusContext extends ConsumerWidget {
  final StatusSchema schema;

  const StatusContext({
    super.key,
    required this.schema,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ServerSchema? server = ref.watch(serverProvider);
    final String? accessToken = ref.watch(accessTokenProvider);

    if (server == null) {
      return const SizedBox.shrink();
    }

    return FutureBuilder(
      future: server.getStatusContext(schema: schema, accessToken: accessToken),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Align(
            alignment: Alignment.topCenter,
            child: ClockProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          final String text = AppLocalizations.of(context)?.txt_invalid_instance ?? 'Invalid instance: ${server.domain}';
          return Text(text, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.red));
        }

        final StatusContextSchema ctx = snapshot.data as StatusContextSchema;
        return buildContent(ctx);
      }
    );
  }

  // The main content of the status context, including the current status
  // the previous statuses and the next statuses.
  Widget buildContent(StatusContextSchema ctx) {
    Map<String, int> indents = {schema.id: 1};
    final List<Widget> children = [
      ...ctx.ancestors.map((StatusSchema status) {
        final int indent = indents[status.inReplyToID] ?? 1;

        indents[status.id] = indent + 1;
        return Status(schema: status, indent: indent);
      }),

      Status(schema: schema),

      ...ctx.descendants.map((StatusSchema status) {
        final int indent = indents[status.inReplyToID] ?? 1;

        indents[status.id] = indent + 1;
        return Status(schema: status, indent: indent);
      }),
    ];

    return ListView.builder(
      itemCount: children.length,
      itemBuilder: (context, index) {
        final Widget child = children[index];

        return Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.outline)),
          ),
          child: child,
        );
      },
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
