// The Timeline widget in the current selected Mastodon server.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/glacial/models/server.dart';
import 'package:glacial/features/timeline/models/core.dart';
import 'status.dart';

// The timeline type button to show the timeline type in the tab bar.
class TimelineTypeButton extends StatelessWidget {
  final TimelineType type;
  final double size;
  final VoidCallback? onPressed;

  const TimelineTypeButton({
    super.key,
    required this.type,
    this.size = 32,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon,size: size),
      tooltip: type.name,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      onPressed: onPressed,
    );
  }

  IconData get icon {
    switch (type) {
      case TimelineType.home:
        return Icons.home_outlined;
      case TimelineType.hashtag:
        return Icons.tag_outlined;
      case TimelineType.local:
        return Icons.groups_outlined;
      case TimelineType.federal:
        return Icons.account_tree_outlined;
      case TimelineType.public:
        return Icons.public_outlined;
      case TimelineType.bookmarks:
        return Icons.bookmarks_outlined;
      case TimelineType.favourites:
        return Icons.star_outline_outlined;
    }
  }
}

// The timeline tab that shows the all possible timelines in the current
// selected Mastodon server.
class TimelineTab extends ConsumerStatefulWidget {
  const TimelineTab({super.key});

  @override
  ConsumerState<TimelineTab> createState() => _TimelineTabState();
}

class _TimelineTabState extends ConsumerState<TimelineTab> with SingleTickerProviderStateMixin {
  // Exclude TimelineType.hashtag from the timeline tab as hashtag timelines are handled differently
  // or are not supported in the current implementation.
  final List<TimelineType> types = TimelineType.values.where((type) => type != TimelineType.hashtag).toList();
  late final TabController controller;
  late final ServerSchema? schema;

  @override
  void initState() {
    super.initState();
    schema = ref.read(currentServerProvider);
    controller = TabController(length: types.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final String? accessToken = ref.watch(currentAccessTokenProvider);
    final ServerSchema? schema = ref.read(currentServerProvider);

    if (schema == null) {
      logger.w("No server selected, but it's required to show the timeline.");
      return const SizedBox.shrink();
    }

    controller.index = accessToken == null ? TimelineType.local.index : TimelineType.home.index;

    return SlideTabView(
      controller: controller,
      tabs: types,
      tabBuilder: (index) => (accessToken != null || types[index].supportAnonymous),
      itemBuilder: (context, index) {
        final TimelineType type = types[index];
        return TimelineBuilder(type: type);
      },
    );
  }
}

class TimelineBuilder extends ConsumerWidget {
  final TimelineType type;
  final String? keyword;

  const TimelineBuilder({
    super.key,
    required this.type,
    this.keyword,
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
      future: schema.fetchTimeline(type: type, accessToken: accessToken, keyword: keyword),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LinearProgressIndicator();
        } else if (snapshot.hasError) {
          final String text = AppLocalizations.of(context)?.txt_invalid_instance ?? 'Invalid instance: ${schema.domain}';
          return Text(text, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.red));
        }

        final List<StatusSchema> statuses = snapshot.data as List<StatusSchema>;
        return Timeline(
          schema: schema,
          accessToken: accessToken,
          type: type,
          statuses: statuses,
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
  final List<StatusSchema> statuses;

  const Timeline({
    super.key,
    required this.schema,
    required this.type,
    this.accessToken,
    this.keyword,
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
    return ListView.builder(
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
    );
  }

  // Detect the scroll event and load more statuses when the user scrolls to the
  // almost bottom of the list.
  void onScroll() async {
    if (controller.position.pixels >= controller.position.maxScrollExtent - loadingThreshold) {
      onLoad();
    }
  }

  // Load the statuses from the current selected Mastodon server.
  void onLoad() async {
    if (isLoading || isCompleted) {
      return;
    }

    setState(() => isLoading = true);
    final String? maxId = statuses.isNotEmpty ? statuses.last.id : null;
    final List<StatusSchema> newStatuses = await widget.schema.fetchTimeline(
      type: widget.type,
      accessToken: widget.accessToken,
      maxId: maxId,
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
