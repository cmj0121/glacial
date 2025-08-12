// The Status widget to show the toots from user.
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
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
        HtmlDone(html: schema.content, emojis: schema.emojis, onLinkTap: onLinkTap),
        Poll(schema: schema.poll),
        Attachments(schemas: schema.attachments),

        if (schema.tags.isNotEmpty) Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            children: schema.tags.map((tag) => TagLite(schema: tag)).toList(),
          ),
        ),
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
    return ClipRect(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ClipRect(child: Account(schema: schema.account, size: headerHeight)),
          const Spacer(),
          ClipRRect(child: buildHeaderMeta()),
        ],
      ),
    );
  }

  Widget buildHeaderMeta() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        buildTimeInfo(),
        buildEditLog(),
        StatusVisibility(type: schema.visibility, size: iconSize),
        buildLikes(),
        const SizedBox(width: 4),
      ],
    );
  }

  // Build the post time information, showing the time since the post was created.
  Widget buildTimeInfo() {
    final String duration = timeago.format(schema.createdAt, locale: 'en_short');

    return Tooltip(
      message: schema.createdAt.toLocal().toString(),
      child: Text(duration, style: const TextStyle(color: Colors.grey)),
    );
  }

  // Build the post's reblog or favorite details.
  Widget buildLikes() {
    final int count = schema.reblogsCount + schema.favouritesCount;

    return IconButton(
      icon: Icon(Icons.info_outline, size: iconSize),
      padding: EdgeInsets.zero,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      onPressed: count == 0 ? null : () => context.push(RoutePath.statusInfo.path, extra: schema),
    );
  }

  // Build the post's edit log, which shows the edit history of the post.
  Widget buildEditLog() {
    return IconButton(
      icon: Icon(Icons.edit_outlined, size: iconSize),
      padding: EdgeInsets.zero,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      onPressed: widget.schema.editedAt == null ? null : () => context.push(RoutePath.statusHistory.path, extra: schema),
    );
  }

  // Reload the status when the status is reblogged or updated.
  void onReload(StatusSchema status) {
    if (mounted) {
      setState(() => schema = status.reblog ?? status);
      widget.onReload?.call(status);
    }
  }

  // Handle the link tap event, and open the link in the in-app webview.
  void onLinkTap(String? url, Map<String, String> attributes, _) async {
    final AccessStatusSchema? status = ref.read(accessStatusProvider);
    final Uri? uri = url == null ? null : Uri.parse(url);

    if (uri == null) {
      return;
    }

    // Link belong to the same domain, so we can open it in the app.
    final String path = uri.path;

    if (path.startsWith('/@')) {
      // The link is an account link, so we can open the profile.
      final String acct = uri.pathSegments.isNotEmpty ? uri.pathSegments.first.substring(1) : '';
      final List<AccountSchema> accounts = await status?.searchAccounts(acct) ?? [];
      final AccountSchema? account = accounts.where((a) => a.acct == acct).firstOrNull;

      if (mounted && account != null) {
        // only push the profile route if the account is found
        context.push(RoutePath.profile.path, extra: account);
        return;
      }
    } else if (path.startsWith('/tags/')) {
      // The link is a tag link, so we can open the tag search.
      final String tag = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : '';

      if (mounted && tag.isNotEmpty) {
        // only push the hashtag route if the tag is not empty
        context.push(RoutePath.hashtag.path, extra: tag);
        return;
      }
    }

    if (mounted) {
      // Open the link in the in-app webview.
      context.push(RoutePath.webview.path, extra: uri);
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
    return InkWellDone(
      onTap: () => context.push(RoutePath.status.path, extra: schema),
      child: buildContent(context),
    );
  }

  Widget buildContent(BuildContext content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildHeader(),

        HtmlDone(html: schema.content, emojis: schema.emojis),
        Poll(schema: schema.poll),
        Attachments(schemas: schema.attachments),

        if (schema.tags.isNotEmpty) Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            children: schema.tags.map((tag) => TagLite(schema: tag)).toList(),
          ),
        ),
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
    final AccessStatusSchema? status = ref.read(accessStatusProvider);

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

        return Dismissible(
          key: ValueKey(widget.schema.id),
          direction: DismissDirection.startToEnd,
          onDismissed: (_) => context.pop(),
          child: buildContent(ctx),
        );
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

// Show the status information, like the reblogged by user and the favourited by user.
class StatusInfo extends ConsumerStatefulWidget {
  final StatusSchema schema;

  const StatusInfo({
    super.key,
    required this.schema,
  });

  @override
  ConsumerState<StatusInfo> createState() => _StatusInfoState();
}

class _StatusInfoState extends ConsumerState<StatusInfo> with SingleTickerProviderStateMixin {
  final List<StatusInteraction> actions = [StatusInteraction.reblog, StatusInteraction.favourite];
  late final TabController controller;

  @override
  void initState() {
    super.initState();
    controller = TabController(length: actions.length, vsync: this);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AccessStatusSchema? status = ref.read(accessStatusProvider);

    return Align(
      alignment: Alignment.topCenter,
      child: SwipeTabView(
        itemCount: actions.length,
        tabController: controller,
        tabBuilder: (context, index) {
          final StatusInteraction action = actions[index];
          final bool isSelected = controller.index == index;
          final bool isActive = tappable(action);
          final Color color = isActive ?
              (isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface) :
              Theme.of(context).disabledColor;

          return Tooltip(
            message: action.tooltip(context),
            child: Icon(action.icon(active: isSelected), color: color, size: tabSize),
            );
        },
        itemBuilder: (context, index) {
          final StatusInteraction action = actions[index];
          final bool isReblog = action == StatusInteraction.reblog;

          return FutureBuilder(
            future: isReblog ? status?.fetchRebloggedBy(schema: widget.schema) : status?.fetchFavouritedBy(schema: widget.schema),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: ClockProgressIndicator());
              } else if (snapshot.hasError) {
                return const SizedBox.shrink();
              }

              final List<AccountSchema> accounts = snapshot.data as List<AccountSchema>;
              return ListView.builder(
                shrinkWrap: true,
                itemCount: accounts.length,
                itemBuilder: (context, index) {
                  final AccountSchema account = accounts[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Account(schema: account),
                  );
                },
              );
            },
          );
        },
        onTabTappable: (index) => tappable(actions[index]),
      ),
    );
  }

  bool tappable(StatusInteraction action) {
    switch (action) {
      case StatusInteraction.reblog:
        return widget.schema.reblogsCount > 0;
      case StatusInteraction.favourite:
        return widget.schema.favouritesCount > 0;
      default:
        return false;
    }
  }
}

class StatusHistory extends ConsumerStatefulWidget {
  final StatusSchema schema;

  const StatusHistory({
    super.key,
    required this.schema,
  });

  @override
  ConsumerState<StatusHistory> createState() => _StatusHistoryState();
}

class _StatusHistoryState extends ConsumerState<StatusHistory> {
  bool isDisposed = false;
  int selectedIndex = 0;
  List<StatusEditSchema> history = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => onLoad());
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: isDisposed ? const SizedBox() : Dismissible(
        key: ValueKey(widget.schema.id),
        direction: DismissDirection.startToEnd,
        onDismissed: (_) => onDismiss(),
        child: buildContent(),
      ),
    );
  }

  // Build the content of the status history, showing the edit history of the status and the
  // slider of timestamp.
  Widget buildContent() {
    if (history.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return SlideTransition(
                position: Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(animation),
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
            child: buildHistory(),
          ),
        ),
        buildSlider(),
      ],
    );
  }

  // Build the slider of the status history, showing the timestamp of the status edit history.
  Widget buildSlider() {
    return SfSlider.vertical(
      min: 0,
      max: history.length - 1,
      value: selectedIndex.toDouble(),
      interval: 1,
      showTicks: true,
      onChanged: (dynamic value) => setState(() => selectedIndex = value.toInt()),
    );
  }

  // Build the history of the status, showing the edit history of the status.
  Widget buildHistory() {
    final StatusEditSchema schema = history[selectedIndex];
    return Align(
      key: ValueKey(selectedIndex),
      alignment: Alignment.topLeft,
      child: StatusEdit(schema: schema),
    );
  }

  void onLoad() async {
    final AccessStatusSchema? status = ref.read(accessStatusProvider);
    final List<StatusEditSchema> history = await status?.fetchHistory(schema: widget.schema) ?? [];

    setState(() {
      this.history = history;
      selectedIndex = history.isEmpty ? 0 : history.length - 1;
    });
  }

  void onDismiss() {
    setState(() => isDisposed = true);
    context.pop();
  }
}

class StatusEdit extends StatelessWidget {
  final StatusEditSchema schema;

  const StatusEdit({
    super.key,
    required this.schema,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HtmlDone(html: schema.content, emojis: schema.emojis),
        Poll(schema: schema.poll),
        Attachments(schemas: schema.attachments),

        const Spacer(),

        Text(schema.createdAt.toLocal().toString(), style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
