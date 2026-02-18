// The Conversation list screen for direct messages.
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildLoadingIndicator(),
          Flexible(child: buildContent()),
        ],
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
            child: const Icon(Icons.delete_outline, color: Colors.white),
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

    final String? maxId = conversations.isNotEmpty ? conversations.last.id : null;
    final (items, _) = await status?.fetchConversations(maxId: maxId) ?? (<ConversationSchema>[], null);

    if (mounted) {
      setState(() => conversations.addAll(items));
      markLoadComplete(isEmpty: items.isEmpty);
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
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildAvatars(context),
              const SizedBox(width: 12),
              Expanded(child: buildBody(context)),
              if (schema.unread) buildUnreadBadge(context),
            ],
          ),
        ),
      ),
    );
  }

  // Build stacked avatars for conversation participants.
  Widget buildAvatars(BuildContext context) {
    if (schema.accounts.isEmpty) return const SizedBox(width: 40, height: 40);

    if (schema.accounts.length == 1) {
      return AccountAvatar(schema: schema.accounts.first, size: 40);
    }

    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            right: 0,
            child: AccountAvatar(schema: schema.accounts[1], size: 30),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: AccountAvatar(schema: schema.accounts.first, size: 30),
          ),
        ],
      ),
    );
  }

  // Build the conversation body: participant names and last message preview.
  Widget buildBody(BuildContext context) {
    final TextStyle? nameStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
      fontWeight: schema.unread ? FontWeight.bold : FontWeight.normal,
    );
    final TextStyle? previewStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: Theme.of(context).colorScheme.outline,
    );
    final TextStyle? timeStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
      color: Theme.of(context).colorScheme.outline,
    );

    final String names = schema.accounts.map((a) => a.displayName).join(', ');
    final String? preview = schema.lastStatus == null
        ? null
        : canonicalizeHtml(schema.lastStatus!.content);
    final String? time = schema.lastStatus?.createdAt.toIso8601String().split('T').first;

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

  // Build the unread indicator dot.
  Widget buildUnreadBadge(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 4),
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
