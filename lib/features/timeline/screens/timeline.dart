// The Timeline widget in the current selected Mastodon server.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/glacial/models/server.dart';
import 'package:glacial/features/timeline/models/core.dart';
import 'status.dart';


// The timeline tab that shows the all possible timelines in the current
// selected Mastodon server.
class TimelineTab extends ConsumerStatefulWidget {
  const TimelineTab({super.key});

  @override
  ConsumerState<TimelineTab> createState() => _TimelineTabState();
}

class _TimelineTabState extends ConsumerState<TimelineTab> with TickerProviderStateMixin {
  // Exclude TimelineType.hashtag from the timeline tab as hashtag timelines are handled differently
  // or are not supported in the current implementation.
  final List<TimelineType> types = TimelineType.values.where((type) => type.isPublicView).toList();

  late final TabController controller;
  late final ServerSchema? schema;

  @override
  void initState() {
    super.initState();
    schema = ref.read(currentServerProvider);

    final String? accessToken = ref.read(currentAccessTokenProvider);
    final TimelineType initType = accessToken == null ? TimelineType.local : TimelineType.home;

    controller = TabController(
      length: types.length,
      initialIndex: types.indexWhere((type) => type == initType),
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    final String? accessToken = ref.watch(currentAccessTokenProvider);

    if (schema == null) {
      logger.w("No server selected, but it's required to show the timeline.");
      return const SizedBox.shrink();
    }

    return SwipeTabView(
      tabController: controller,
      itemCount: types.length,
      tabBuilder: (context, index) {
        final TimelineType type = types[index];
        final bool isSelected = controller.index == index;
        final bool isActive = accessToken != null || type.supportAnonymous;
        final Color color = isActive ?
            (isSelected ?
              Theme.of(context).colorScheme.primary :
              Theme.of(context).colorScheme.onSurface
            ) : Theme.of(context).disabledColor;

        return Icon(isSelected ? type.activeIcon : type.icon, color: color);
      },
      itemBuilder: (context, index) => TimelineBuilder(key: ValueKey(types[index]), type: types[index]),
      onTabTappable: (index) => accessToken != null || types[index].supportAnonymous,
    );
  }
}

class TimelineBuilder extends ConsumerWidget {
  final TimelineType type;
  final String? keyword;
  final AccountSchema? account;

  const TimelineBuilder({
    super.key,
    required this.type,
    this.keyword,
    this.account,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ServerSchema? schema = ref.read(currentServerProvider);
    final String? accessToken = ref.read(currentAccessTokenProvider);

    if (schema == null) {
      logger.w("No server selected, but it's required to show the timeline.");
      return const SizedBox.shrink();
    }

    return FutureBuilder(
      future: schema.fetchTimeline(type: type, accessToken: accessToken, keyword: keyword, account: account),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Align(
            alignment: Alignment.topCenter,
            child: LinearProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            ),
          );
        } else if (snapshot.hasError) {
          final String text = AppLocalizations.of(context)?.txt_invalid_instance ?? 'Invalid instance: ${schema.domain}';
          return Align(
            alignment: Alignment.topCenter,
            child: Text(text, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.red)),
          );
        }

        final List<StatusSchema> statuses = snapshot.data as List<StatusSchema>;
        return Timeline(
          schema: schema,
          accessToken: accessToken,
          type: type,
          statuses: statuses,
          account: account,
        );
      },
    );
  }
}

// The timeline widget that contains the status from the current selected
// Mastodon server.
class Timeline extends StatefulWidget {
  final ServerSchema schema;
  final TimelineType type;
  final String? accessToken;
  final String? keyword;
  final AccountSchema? account;
  final List<StatusSchema> statuses;

  const Timeline({
    super.key,
    required this.schema,
    required this.type,
    this.accessToken,
    this.keyword,
    this.account,
    this.statuses = const [],
  });

  @override
  State<Timeline> createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  final ScrollController controller = ScrollController();
  final Storage storage = Storage();
  final double loadingThreshold = 180;

  bool isLoading = false;
  bool isCompleted = false;
  late List<StatusSchema> statuses = [];

  @override
  void initState() {
    super.initState();
    statuses = widget.statuses;
    controller.addListener(onScroll);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          isLoading ? LinearProgressIndicator() : const SizedBox.shrink(),
          Flexible(child: buildContent()),
        ],
      ),
    );
  }

  // Build the list of the statuses in the current selected Mastodon server and
  // timeline type.
  Widget buildContent() {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        controller: controller,
        shrinkWrap: true,
        itemCount: statuses.length,
        itemBuilder: (context, index) {
          final StatusSchema status = statuses[index];
          return Status(
            schema: status.reblog ?? status,
            reblogFrom: status.reblog != null ? status.account : null,
            replyToAccountID: status.inReplyToAccountID,
            onDeleted: () => onDeleted(index),
          );
        },
      ),
    );
  }

  // Detect the scroll event and load more statuses when the user scrolls to the
  // almost bottom of the list.
  void onScroll() async {
    if (controller.position.pixels >= controller.position.maxScrollExtent - loadingThreshold) {
      onLoad();
    }
  }

  // Clean-up and refresh the timeline when the user pulls down the list.
  Future<void> onRefresh() async {
    setState(() {
      isLoading = false;
      isCompleted = false;
      statuses.clear();
    });
    await onLoad();
  }

  // Load the statuses from the current selected Mastodon server.
  Future<void> onLoad() async {
    if (isLoading || isCompleted) {
      return;
    }

    setState(() => isLoading = true);
    final String? maxId = statuses.isNotEmpty ? statuses.last.id : null;
    final List<StatusSchema> newStatuses = await widget.schema.fetchTimeline(
      type: widget.type,
      accessToken: widget.accessToken,
      maxId: maxId,
      account: widget.account,
    );

    setState(() {
      isLoading = false;

      if (newStatuses.isEmpty) {
        isCompleted = true;
        return;
      }

      statuses.addAll(newStatuses);
    });
  }

  // Reload the timeline when the status is deleted.
  void onDeleted(int index) async {
    final StatusSchema status = statuses[index];

    if (widget.accessToken != null) {
      await status.deleteIt(domain: widget.schema.domain, accessToken: widget.accessToken!);
      setState(() => statuses.removeAt(index));
    }
  }
}

// vim: set ts=2 sw=2 sts=2 et:
