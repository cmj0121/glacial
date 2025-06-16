// The Trends widget in the current selected Mastodon server.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

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
    final ServerSchema? server = ref.read(serverProvider);

    if (server == null) {
      logger.w("No server selected, but it's required to show the trends.");
      return const SizedBox.shrink();
    }

    return SwipeTabView(
      tabController: controller,
      itemCount: tabs.length,
      tabBuilder: (context, index) {
        final TrendsType type = tabs[index];
        final Widget icon = Icon(type.icon(active: controller.index == index), size: 32);

        return Tooltip(
          message: type.tooltip(context),
          child: icon,
        );
      },
      itemBuilder: (context, index) => Trends(
        schema: server,
        type: tabs[index],
        accessToken: ref.read(accessTokenProvider),
      ),
    );
  }
}

// Get the popular statuses trends in the current Mastodon server.
class Trends extends StatefulWidget {
  final ServerSchema schema;
  final TrendsType type;
  final String? accessToken;

  const Trends({
    super.key,
    required this.schema,
    required this.type,
    this.accessToken,
  });

  @override
  State<Trends> createState() => _TrendsState();
}

// Show the trends for a specific hashtag in the current Mastodon server.
class _TrendsState extends State<Trends> {
  final ScrollController controller = ScrollController();

  bool isLoading = false;
  bool isCompleted = false;
  List<dynamic> trends = [];

  @override
  void initState() {
    super.initState();
    controller.addListener(onScroll);
    onLoad();
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
        isLoading ? ClockProgressIndicator() : const SizedBox.shrink(),
        Flexible(child: buildContent()),
      ],
    );
  }

  // Build the content of the trends page based on the type of trends.
  Widget buildContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        late final double imageSize;
        if (constraints.maxWidth < 600) {
          imageSize = 80;
        } else {
          imageSize = 120;
        }

        return ListView.builder(
          controller: controller,
          shrinkWrap: true,
          itemCount: trends.length,
          itemBuilder: (context, index) {
            late final Widget child;

            switch (widget.type) {
              case TrendsType.statuses:
                final StatusSchema status = trends[index] as StatusSchema;
                child = Status(
                  schema: status.reblog ?? status,
                  reblogFrom: status.reblog != null ? status.account : null,
                  replyToAccountID: status.inReplyToAccountID,
                );
                break;
              case TrendsType.links:
                final LinkSchema link = trends[index] as LinkSchema;
                child = TrendsLink(schema: link, imageSize: imageSize);
                break;
              case TrendsType.tags:
                final HashtagSchema tag = trends[index] as HashtagSchema;
                child = Hashtag(schema: tag);
                break;
            }


          return Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.outline)),
            ),
            child: Padding(
              padding: EdgeInsets.only(right: 16),
              child: child,
            ),
          );
          },
        );
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
    final List<dynamic> newStatuses = await widget.schema.fetchTrends(
      widget.type,
      accessToken: widget.accessToken,
      offset: trends.length,
    );

    if (mounted == false) {
      return;
    }

    setState(() {
      trends.addAll(newStatuses);
      isLoading = false;
      isCompleted = newStatuses.isEmpty;
    });
  }
}

// vim: set ts=2 sw=2 sts=2 et:
