// The Conversation list screen for direct messages.
import 'dart:io';

import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

// The conversation tab that shows the list of direct message conversations.
class ConversationTab extends ConsumerStatefulWidget {
  const ConversationTab({super.key});

  @override
  ConsumerState<ConversationTab> createState() => _ConversationTabState();
}

class _ConversationTabState extends ConsumerState<ConversationTab> with PaginatedListMixin {
  late final AccessStatusSchema? status = ref.read(accessStatusProvider);

  ItemScrollController itemScrollController = ItemScrollController();
  ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();

  List<ConversationSchema> conversations = [];
  int _firstVisibleIndex = 0;

  @override
  void initState() {
    super.initState();

    itemPositionsListener.itemPositions.addListener(_onPositionChange);
    GlacialHome.itemScrollToTop = itemScrollController;
    WidgetsBinding.instance.addPostFrameCallback((_) => onLoad());
  }

  @override
  void dispose() {
    itemPositionsListener.itemPositions.removeListener(_onPositionChange);
    super.dispose();
  }

  void _onPositionChange() {
    final List<ItemPosition> positions = itemPositionsListener.itemPositions.value.toList();
    if (positions.isEmpty) return;

    _firstVisibleIndex = positions.first.index;

    final int lastIndex = positions.last.index;
    if (lastIndex > conversations.length - 5) onLoad();
  }

  @override
  Widget build(BuildContext context) {
    if (status?.isSignedIn != true) {
      return const SizedBox.shrink();
    }

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildLoadingIndicator(),
            Flexible(child: buildContent()),
          ],
        ),
      ),
    );
  }

  Widget buildContent() {
    if (conversations.isEmpty) {
      return isCompleted
          ? NoResult(
              message: AppLocalizations.of(context)?.txt_no_conversations ?? "No conversations",
              icon: Icons.mail_outline,
            )
          : const SizedBox.shrink();
    }

    final Widget builder = ScrollablePositionedList.builder(
      itemScrollController: itemScrollController,
      itemPositionsListener: itemPositionsListener,
      initialScrollIndex: _firstVisibleIndex.clamp(0, conversations.length - 1),
      itemCount: conversations.length,
      itemBuilder: (BuildContext context, int index) {
        final ConversationSchema conversation = conversations[index];

        return AccessibleDismissible(
          dismissKey: ValueKey(conversation.id),
          direction: DismissDirection.endToStart,
          dismissLabel: AppLocalizations.of(context)?.lbl_swipe_delete,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            color: Theme.of(context).colorScheme.error,
            child: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.onError),
          ),
          confirmDismiss: (_) async {
            final confirmed = await showConfirmDialog(
              context: context,
              title: AppLocalizations.of(context)?.txt_admin_confirm_action ?? 'Confirm',
              message: AppLocalizations.of(context)?.msg_confirm_delete_conversation ?? 'Delete this conversation?',
            );
            if (confirmed) onDismiss(index, conversation.id);
            return false;
          },
          child: ConversationItem(
            schema: conversation,
            onTap: () => onTapConversation(conversation),
          ),
        );
      },
    );

    return CustomMaterialIndicator(
      onRefresh: onRefresh,
      indicatorBuilder: ClockProgressIndicator.refreshBuilder,
      child: isRefresh ? const SizedBox.shrink() : builder,
    );
  }

  // Dismiss a conversation and rebuild the list with fresh controllers.
  void onDismiss(int index, String conversationId) {
    itemPositionsListener.itemPositions.removeListener(_onPositionChange);
    conversations.removeAt(index);
    status?.deleteConversation(conversationId);

    itemScrollController = ItemScrollController();
    itemPositionsListener = ItemPositionsListener.create();
    itemPositionsListener.itemPositions.addListener(_onPositionChange);
    GlacialHome.itemScrollToTop = itemScrollController;

    setState(() {});
  }

  // Navigate to the conversation thread via the last status.
  void onTapConversation(ConversationSchema conversation) {
    if (conversation.unread) {
      status?.markConversationAsRead(conversation.id);
    }

    final StatusSchema? lastStatus = conversation.lastStatus;
    if (lastStatus != null && mounted) {
      context.push(RoutePath.status.path, extra: lastStatus);
    }
  }

  Future<void> onRefresh() async {
    setState(() => conversations.clear());
    await refreshList(onLoad);
  }

  Future<void> onLoad() async {
    if (shouldSkipLoad) return;

    setLoading(true);

    try {
      final String? maxId = conversations.isNotEmpty ? conversations.last.id : null;
      final (items, _) = await status?.fetchConversations(maxId: maxId) ?? (<ConversationSchema>[], null);

      if (mounted) {
        setState(() => conversations.addAll(items));
        markLoadComplete(isEmpty: items.isEmpty);
      }
    } on SocketException catch (e) {
      logger.w('conversation fetch failed (offline): $e');
      if (mounted) {
        if (conversations.isEmpty) {
          markLoadError();
        } else {
          markLoadComplete(isEmpty: false);
        }
      }
    } on HttpTimeoutException catch (e) {
      logger.w('conversation fetch timed out: $e');
      if (mounted) {
        if (conversations.isEmpty) {
          markLoadError();
        } else {
          markLoadComplete(isEmpty: false);
        }
      }
    }
  }
}

// A single conversation item in the list.
class ConversationItem extends StatelessWidget {
  final ConversationSchema schema;
  final VoidCallback? onTap;

  const ConversationItem({
    super.key,
    required this.schema,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: schema.unread ? scheme.primary.withValues(alpha: 0.06) : null,
          border: Border(
            bottom: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.3)),
            left: BorderSide(
              color: schema.unread ? scheme.primary : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAvatar(context),
            const SizedBox(width: 12),
            Expanded(child: _buildBody(context)),
          ],
        ),
      ),
    );
  }

  // Single 44px avatar; when there are multiple participants, overlay a
  // small "+N" chip on the bottom-right so the card geometry stays the
  // same regardless of group size.
  Widget _buildAvatar(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    if (schema.accounts.isEmpty) return const SizedBox(width: 44, height: 44);
    final int extras = schema.accounts.length - 1;

    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AccountAvatar(schema: schema.accounts.first, size: 44),
          if (extras > 0)
            Positioned(
              bottom: -2,
              right: -2,
              child: Container(
                height: 18,
                constraints: const BoxConstraints(minWidth: 18),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: scheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: scheme.surface, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  '+$extras',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.onSecondaryContainer,
                    fontWeight: FontWeight.w700,
                    height: 1.0,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final TextStyle? nameStyle = theme.textTheme.titleSmall?.copyWith(
      fontWeight: schema.unread ? FontWeight.w700 : FontWeight.w600,
    );
    final TextStyle? previewStyle = theme.textTheme.bodySmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );
    final TextStyle? timeStyle = theme.textTheme.labelSmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );

    final String names = schema.accounts.map((a) => a.displayName).join(', ');
    final String? preview = schema.lastStatus == null
        ? null
        : canonicalizeHtml(schema.lastStatus!.content);
    final DateTime? createdAt = schema.lastStatus?.createdAt;
    final String? time = createdAt == null
        ? null
        : timeago.format(createdAt, locale: timeagoLocale(context));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(names, style: nameStyle, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            if (time != null) Text(time, style: timeStyle),
          ],
        ),
        if (preview != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(preview, style: previewStyle, maxLines: 2, overflow: TextOverflow.ellipsis),
          ),
      ],
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
