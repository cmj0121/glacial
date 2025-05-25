// The Trends widget in the current selected Mastodon server.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/core.dart';
import 'package:glacial/features/glacial/models/server.dart';
import 'package:glacial/features/explore/models/core.dart';
import 'package:glacial/features/trends/models/core.dart';

// Show the possible timeline tab per timeline type.
class TrendsTab extends ConsumerStatefulWidget {
  const TrendsTab({super.key});

  @override
  ConsumerState<TrendsTab> createState() => _TrendsTabState();
}

class _TrendsTabState extends ConsumerState<TrendsTab> with SingleTickerProviderStateMixin {
  final List<TrendsType> tabs = TrendsType.values;
  late final TabController controller;

  late int selectedIndex;
  late Widget? child;

  @override
  void initState() {
    super.initState();
    controller = TabController(
      length: tabs.length,
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ServerSchema? server = ref.read(currentServerProvider);

    if (server == null) {
      logger.w("No server selected, but it's required to show the trends.");
      return const SizedBox.shrink();
    }

    return SwipeTabView(
      tabController: controller,
      itemCount: tabs.length,
      tabBuilder: (context, index) {
        final TrendsType type = tabs[index];
        final Widget icon = Icon(controller.index == index ? type.activeIcon : type.icon);

        return Tooltip(
          message: type.tooltip(context) ?? '',
          child: icon,
        );
      },
      itemBuilder: (context, index) => Trends.builder(schema: server, type: tabs[index]),
    );
  }
}

// Get the popular statuses trends in the current Mastodon server.
class Trends extends StatefulWidget {
  final ServerSchema schema;
  final TrendsType type;
  final List<dynamic> trends;

  const Trends({
    super.key,
    required this.schema,
    required this.type,
    this.trends = const [],
  });

  @override
  State<Trends> createState() => _TrendsState();

  // The builder method to create a Trends instance based on the server schema and trends type.
  static builder({required ServerSchema schema, required TrendsType type}) {
    return FutureBuilder(
      future: type.fetch(server: schema),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Align(
            alignment: Alignment.topCenter,
            child: const LinearProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return const Text('Error loading trends');
        }

        final List<dynamic> trends = snapshot.data as List<dynamic>;
        return Trends(schema: schema, type: type, trends: trends);
      },
    );
  }
}

// Show the trends for a specific hashtag in the current Mastodon server.
class _TrendsState extends State<Trends> {
  final ScrollController controller = ScrollController();

  bool isLoading = false;
  bool isCompleted = false;
  late List<dynamic> trends = [];

  @override
  void initState() {
    super.initState();
    trends.addAll(widget.trends);
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
      child: buildLayout(),
    );
  }

  Widget buildLayout() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        isLoading ? LinearProgressIndicator() : const SizedBox.shrink(),
        Flexible(child: buildContent()),
      ],
    );
  }

  // Build the content of the trends page based on the type of trends.
  Widget buildContent() {
    return ListView.builder(
      controller: controller,
      shrinkWrap: true,
      itemCount: trends.length,
      itemBuilder: (context, index) {
        switch (widget.type) {
          case TrendsType.statuses:
            final StatusSchema status = trends[index] as StatusSchema;
            return Status(
              schema: status.reblog ?? status,
              reblogFrom: status.reblog != null ? status.account : null,
              replyToAccountID: status.inReplyToAccountID,
            );
          case TrendsType.links:
            final LinkSchema link = trends[index] as LinkSchema;
            return TrendsLink(
              schema: link,
            );
          case TrendsType.tags:
						final HashTagSchema tag = trends[index] as HashTagSchema;
						return HashTag(schema: tag);
        }
      },
    );
  }

  // Try to load more trends when the user scrolls to the bottom of the list.
  void onScroll() async {
    if (controller.position.pixels >= controller.position.maxScrollExtent - 100) {
      onLoad();
    }
  }

  // Load the next page of trends from the server.
  void onLoad() async {
    if (isLoading || isCompleted) {
      return;
    }

    setState(() => isLoading = true);
    final List<dynamic> newStatuses = await widget.type.fetch(server: widget.schema, offset: trends.length);

    setState(() {
      trends.addAll(newStatuses);
      isLoading = false;
      isCompleted = newStatuses.isEmpty;
    });
  }
}

// vim: set ts=2 sw=2 sts=2 et::w
