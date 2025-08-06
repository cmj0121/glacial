// The Status widget to show the toots from user.
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

// The single Status widget that contains the status information.
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

  late SystemPreferenceSchema? pref = ref.read(preferenceProvider);
  late StatusSchema schema = widget.schema.reblog ?? widget.schema;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: InkWellDone(
        onTap: () {
          final RoutePath path = RoutePath.values.firstWhere((r) => r.path == GoRouterState.of(context).uri.path);

          switch (path) {
            case RoutePath.status:
              context.replace(RoutePath.status.path, extra: schema);
              break;
            default:
              context.push(RoutePath.status.path, extra: schema);
              break;
          }
        },
        child: buildContent(),
      ),
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
        Indent(
          indent: widget.indent,
          child: SpoilerView(
            spoiler: schema.spoiler,
            child: SensitiveView(
              isSensitive: (pref?.sensitive ?? true) && widget.schema.sensitive && schema.spoiler.isEmpty == true,
              child: buildCoreContent(),
            ),
          ),
        ),

        Application(schema: schema.application),
        const SizedBox(height: 8),
        InteractionBar(
          schema: schema,
          onReload: onReload,
          onDeleted: widget.onDeleted,
        ),
      ],
    );
  }

  // Build the core content of the status which may be hidden or shown by the
  // status visibility.
  Widget buildCoreContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HtmlDone(html: schema.content, emojis: schema.emojis),
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
          AccountAvatar(schema: account, size: metadataHeight),
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

// The lightweight widget that can be used to show the status without the interaction
// bar and the sensitive view.
class StatusLite extends StatelessWidget {
  final StatusSchema schema;

  final double headerHeight = 48.0;
  final double iconSize = 16.0;

  const StatusLite({
    super.key,
    required this.schema,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildHeader(),

        HtmlDone(html: schema.content, emojis: schema.emojis),
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

// The optional sensitive view that can hide the sensitive content by blurring it
// and showing an icon to indicate that the content is sensitive.
class SensitiveView extends StatefulWidget {
  final Widget child;
  final bool isSensitive;

  const SensitiveView({
    super.key,
    required this.child,
    this.isSensitive = false,
  });

  @override
  State<SensitiveView> createState() => _SensitiveViewState();
}

class _SensitiveViewState extends State<SensitiveView> {
  late bool isSensitiveVisible = widget.isSensitive;

  @override
  Widget build(BuildContext context) {
    return InkWellDone(
      onTap: isSensitiveVisible ? () => setState(() => isSensitiveVisible = !isSensitiveVisible) : null,
      child: isSensitiveVisible ? buildContent() : widget.child,
    );
  }

  Widget buildContent() {
    return Stack(
        alignment: Alignment.topCenter,
        children: [
          widget.child,
          Positioned.fill(child: buildCover()),
        ],
    );
  }

  // Build the cover for the sensitive content, which will be shown when the
  // sensitive content is not visible.
  Widget buildCover() {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
          alignment: Alignment.center,
          child: Icon(Icons.visibility_off_outlined, size: iconSize, color: Theme.of(context).disabledColor),
        ),
      ),
    );
  }
}

// The optional spoiler view that can hide the spoiler content by showing a button
// to toggle the visibility of the spoiler content.
class SpoilerView extends StatefulWidget {
  final String? spoiler;
  final Widget child;

  const SpoilerView({
    super.key,
    this.spoiler,
    required this.child,
  });

  @override
  State<SpoilerView> createState() => _SpoilerViewState();
}

class _SpoilerViewState extends State<SpoilerView> {
  bool isVisible = false;

  @override
  Widget build(BuildContext context) {
    return widget.spoiler?.isNotEmpty == true ? buildContent() : widget.child;
  }

  Widget buildContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          InkWellDone(
            onDoubleTap: () => setState(() => isVisible = !isVisible),
            child: buildSpoiler(),
          ),
          Visibility(
            visible: isVisible,
            child: widget.child,
          ),
        ],
      ),
    );
  }

  Widget buildSpoiler() {
    final String text = isVisible
        ? AppLocalizations.of(context)?.txt_show_less ?? "Show less"
        : AppLocalizations.of(context)?.txt_show_more ?? "Show more";

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        border: Border.all(width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.spoiler ?? ""),
            const SizedBox(height: 8),
            Text(text, style: TextStyle(color: Theme.of(context).colorScheme.primary)),
          ],
        ),
      ),
    );
  }
}

// The List of statuses that shows the context of the status, including the
// previous statuses and the next statuses.
class StatusContext extends ConsumerStatefulWidget {
  final StatusSchema schema;

  const StatusContext({
    super.key,
    required this.schema,
  });

  @override
  ConsumerState<StatusContext> createState() => _StatusContextState();
}

class _StatusContextState extends ConsumerState<StatusContext> {
  final ItemScrollController itemScrollController = ItemScrollController();

  @override
  Widget build(BuildContext context) {
    final AccessStatusSchema? status = ref.watch(accessStatusProvider);

    if (status == null) {
      return const SizedBox.shrink();
    }

    return FutureBuilder(
      future: status.getStatusContext(schema: widget.schema),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Align(
            alignment: Alignment.topCenter,
            child: ClockProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return const SizedBox.shrink();
        }

        final StatusContextSchema ctx = snapshot.data as StatusContextSchema;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // scroll to the current status when the widget is built
          itemScrollController.scrollTo(
            index: ctx.ancestors.length,
            duration: const Duration(milliseconds: 300),
          );
        });
        return buildContent(ctx);
      }
    );
  }

  // Build the list of the context statuses, including the ancestors and descendants
  Widget buildContent(StatusContextSchema ctx) {
    Map<String, int> indents = {widget.schema.id: 1};

    final List<Widget> children = [
      ...ctx.ancestors.map((StatusSchema status) {
        final int indent = indents[status.inReplyToID] ?? 1;

        indents[status.id] = indent + 1;
        return Status(schema: status, indent: indent);
      }),

      Status(schema: widget.schema),

      ...ctx.descendants.map((StatusSchema status) {
        final int indent = indents[status.inReplyToID] ?? 1;

        indents[status.id] = indent + 1;
        return Status(schema: status, indent: indent);
      }),
    ];

    return ScrollablePositionedList.builder(
      itemScrollController: itemScrollController,
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
