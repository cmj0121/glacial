// The Status widget to show the toots from user.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:glacial/core.dart';
import 'package:glacial/features/timeline/models/core.dart';
import 'package:glacial/features/glacial/models/server.dart';

import 'account.dart';
import 'interaction.dart';
import 'visibility.dart';

// The single Status widget that contains the status information.
class Status extends ConsumerStatefulWidget {
  final StatusSchema schema;
  final AccountSchema? reblogFrom;
  final String? replyToAccountID;
  final ValueChanged<StatusSchema>? onShowStatusContext;
  final VoidCallback? onDeleted;

  const Status({
    super.key,
    required this.schema,
    this.reblogFrom,
    this.replyToAccountID,
    this.onShowStatusContext,
    this.onDeleted,
  });

  @override
  ConsumerState<Status> createState() => _StatusState();
}

class _StatusState extends ConsumerState<Status> {
  final double metadataHeight = 22;

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
        child: InkWellDone(
          // View statuses above and below this status in the thread.
          onTap: () => widget.onShowStatusContext?.call(widget.schema),
          child: buildContent(),
        ),
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
        Html(data: schema.content),

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


    final ServerSchema? schema = ref.read(currentServerProvider);
    return FutureBuilder(
      future: schema?.loadAccount(widget.reblogFrom?.id ?? widget.replyToAccountID),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox.shrink();
        }

        if (snapshot.hasError) {
          return SizedBox.shrink();
        }

        final IconData icon = widget.reblogFrom != null ? StatusInteraction.reblog.activeIcon : StatusInteraction.reply.activeIcon;
        final AccountSchema? account = snapshot.data;
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
      },
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
        StatusVisibility(type: schema.visibility, size: 16, isCompact: true),
      ],
    );
  }

  // reload the status when the user interacts with it.
  void onReload(StatusSchema schema) async {
    // fetch the status again from the server, and update the status
    setState(() => this.schema = schema);
  }
}

// The new status button to create a new status.
class NewStatus extends ConsumerWidget {
  final double size;

  const NewStatus({
    super.key,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String? accessToken = ref.watch(currentAccessTokenProvider);

    return IconButton.filledTonal(
      icon: Icon(Icons.post_add_outlined, size: size),
      tooltip: AppLocalizations.of(context)?.btn_post ?? "Post",
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      onPressed: accessToken == null ? null : () => onPressed(context, ref),
    );
  }

  void onPressed(BuildContext context, WidgetRef ref) async {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: NewStatusForm(onPost: (schema) => onPost(context, ref, schema)),
        );
      },
    );
  }

  void onPost(BuildContext context, WidgetRef ref, NewStatusSchema status) async {
    final ServerSchema? schema = ref.watch(currentServerProvider);
    final String? accessToken = ref.watch(currentAccessTokenProvider);

    if (schema == null || accessToken == null) {
      final String text = AppLocalizations.of(context)?.txt_invalid_instance ?? "No server selected";

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(text),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    await status.create(schema: schema, accessToken: accessToken);
    if (context.mounted) {
      logger.d("completed create a new status");
      context.pop();
    }
  }
}

// The form of the new status that user can fill in to create a new status.
class NewStatusForm extends ConsumerStatefulWidget {
  final double maxWidth;
  final ValueChanged<NewStatusSchema>? onPost;

  const NewStatusForm({
    super.key,
    this.maxWidth = 600,
    this.onPost,
  });

  @override
  ConsumerState<NewStatusForm> createState() => _NewStatusFormState();
}

class _NewStatusFormState extends ConsumerState<NewStatusForm> {
  final TextEditingController controller = TextEditingController();
  final formKey = GlobalKey<FormState>();

  VisibilityType vtype = VisibilityType.public;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: widget.maxWidth,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: buildContent(),
        ),
      ),
    );
  }

  Widget buildContent() {
    final ServerSchema? schema = ref.watch(currentServerProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          maxLines: 10,
          minLines: 10,
          maxLength: schema?.config.statuses.maxCharacters ?? 500,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        Flexible(child: buildActions()),
      ],
    );
  }

  Widget buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        VisibilitySelector(type: vtype, onChanged: (type) => setState(() => vtype = type)),
        const Spacer(),
        TextButton.icon(
          icon: Icon(Icons.chat),
          label: Text(AppLocalizations.of(context)?.btn_post ?? "Post"),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.primary,
          ),
          onPressed: onPost,
        ),
      ],
    );
  }

  void onPost() async {
    if (controller.text.isEmpty) {
      // empty content, do nothing
      return;
    }

    final NewStatusSchema schema = NewStatusSchema(
      status: controller.text,
      mediaIDs: [],
      pollIDs: [],
      visibility: vtype,
    );

    widget.onPost?.call(schema);
  }
}

// vim: set ts=2 sw=2 sts=2 et:
