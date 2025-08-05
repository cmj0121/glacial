// The Status widget to show the toots from user.
import 'dart:ui';

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

  late SystemPreferenceSchema? pref = ref.read(preferenceProvider);
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
        SpoilerView(
          spoiler: schema.spoiler,
          child: buildCoreContent(),
        ),

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
        SensitiveView(
          isSensitive: (pref?.sensitive ?? true) && widget.schema.sensitive,
          child: HtmlDone(html: schema.content),
        ),
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

// vim: set ts=2 sw=2 sts=2 et:
