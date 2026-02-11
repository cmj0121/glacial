// Lightweight status display widget without interaction bar.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

/// Lightweight status display widget that shows content without interaction bar.
/// Used for embedding in StatusContext and as base for full Status widget.
class StatusLite extends ConsumerWidget {
  final StatusSchema schema;
  final int indent;
  final String? spoiler;
  final bool sensitive;
  final double headerHeight;
  final double iconSize;
  final bool isNestedQuote;
  final ValueChanged<PollSchema>? onPollVote;
  final ValueChanged<String?>? onLinkTap;

  const StatusLite({
    super.key,
    required this.schema,
    this.indent = 0,
    this.spoiler,
    this.sensitive = false,
    this.iconSize = 16.0,
    this.headerHeight = 48.0,
    this.isNestedQuote = false,
    this.onPollVote,
    this.onLinkTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AccessStatusSchema? status = ref.read(accessStatusProvider);
    final bool isSelfPost = status?.account?.id == schema.account.id;
    final bool isSchedulePost = schema.scheduledAt != null;

    return InkWellDone(
      onTap: isSchedulePost ? null : () {
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
      child: buildContent(context, status, isSelfPost: isSelfPost),
    );
  }

  Widget buildContent(BuildContext context, AccessStatusSchema? status, {bool isSelfPost = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildHeader(context, isSelfPost: isSelfPost),

        Indent(
        indent: indent,
          child: Column(
            children:[
              buildStatusContent(context, status),
              Application(schema: schema.application),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildStatusContent(BuildContext context, AccessStatusSchema? status) {
    final FilterAction? action = schema.filterAction;

    switch (action) {
      case FilterAction.warn:
        return SpoilerView(
          spoiler: action!.desc(context),
          child: buildCoreContent(status),
        );
      case FilterAction.hide:
        return const SizedBox.shrink();
      case FilterAction.blur:
        return SensitiveView(
          isSensitive: true,
          child: buildCoreContent(status),
        );
      default:
        return SpoilerView(
          spoiler: spoiler,
          child: SensitiveView(
            isSensitive: sensitive,
            child: buildCoreContent(status),
          ),
        );
    }
  }

  Widget buildCoreContent(AccessStatusSchema? status) {
    final List<EmojiSchema> emojis = [...?status?.emojis, ...schema.emojis];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HtmlDone(html: schema.content, emojis: emojis, onLinkTap: (url, attributes, _) => onLinkTap?.call(url)),
        TranslateView(schema: schema, status: status, emojis: emojis, onLinkTap: onLinkTap),
        isNestedQuote ? const SizedBox.shrink() : Quote(schema: schema.quote),
        Poll(schema: schema.poll, onChanged: (poll) => onPollVote?.call(poll)),
        Attachments(schemas: schema.attachments),
        buildTags(),
        schema.card == null ? const SizedBox.shrink() : PreviewCard(schema: schema.card!),
      ],
    );
  }

  Widget buildHeader(BuildContext context, {bool isSelfPost = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(flex: 10, child: Account(schema: schema.account, size: headerHeight)),
            const Spacer(),
            buildMeta(context, isSelfPost: isSelfPost),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: buildTimeInfo(context),
        ),
      ],
    );
  }

  Widget buildMeta(BuildContext context, {bool isSelfPost = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        buildEditLog(context),
        isSelfPost ? buildQuote(context) : const SizedBox.shrink(),
        StatusVisibility(type: schema.visibility, size: iconSize),

        buildLikes(context),
        buildFiltered(context),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget buildTimeInfo(BuildContext context) {
    if (schema.scheduledAt != null) {
      return Tooltip(
        message: schema.scheduledAt!.toLocal().toString(),
        child: Icon(Icons.schedule_outlined, size: iconSize, color: Colors.grey),
      );
    }

    final String duration = timeago.format(schema.createdAt, locale: timeagoLocale(context));

    return Tooltip(
      message: schema.createdAt.toLocal().toString(),
      child: Text(duration, style: const TextStyle(color: Colors.grey)),
    );
  }

  Widget buildFiltered(BuildContext context) {
    FilterAction? filter = schema.filterAction;

    if (filter == null) return const SizedBox.shrink();

    return Tooltip(
      message: filter.desc(context),
      child: Icon(filter.icon, size: iconSize),
    );
  }

  Widget buildLikes(BuildContext context) {
    final int count = schema.reblogsCount + schema.favouritesCount;
    final String tooltip = AppLocalizations.of(context)?.btn_status_info ?? 'View interactions';

    return IconButton(
      icon: Icon(Icons.info_outline, size: iconSize),
      tooltip: tooltip,
      padding: EdgeInsets.zero,
      onPressed: count == 0 ? null : () => context.push(RoutePath.statusInfo.path, extra: schema),
    );
  }

  Widget buildEditLog(BuildContext context) {
    final String tooltip = AppLocalizations.of(context)?.btn_status_history ?? 'View edit history';

    return IconButton(
      icon: Icon(Icons.edit_outlined, size: iconSize),
      tooltip: tooltip,
      padding: EdgeInsets.zero,
      onPressed: schema.editedAt == null ? null : () => context.push(RoutePath.statusHistory.path, extra: schema),
    );
  }

  Widget buildQuote(BuildContext context) {
    final QuotePolicyType policy = schema.quoteApproval?.toUser ?? QuotePolicyType.nobody;

    return IconButton(
      icon: Icon(policy.icon, size: iconSize),
      tooltip: policy.description(context),
      padding: EdgeInsets.zero,
      onPressed: null,
    );
  }

  Widget buildTags() {
    if (schema.tags.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        children: schema.tags.map((tag) => TagLite(schema: tag)).toList(),
      ),
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
