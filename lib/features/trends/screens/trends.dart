// The Trends widget in the current selected Mastodon server.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

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
  late final AccessStatusSchema? status = ref.read(accessStatusProvider);
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
    if (status?.domain?.isEmpty == true) {
      logger.w("No server selected, but it's required to show the trends.");
      return const SizedBox.shrink();
    }

    final bool isSignedIn = status?.accessToken?.isNotEmpty == true;

    return SwipeTabView(
      tabController: controller,
      itemCount: tabs.length,
      tabBuilder: (context, index) {
        final TrendsType type = tabs[index];
        final bool isSelected = controller.index == index;
        final bool isActivate = type != TrendsType.users || isSignedIn;
        final Color color = isActivate ?
            isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface :
            Theme.of(context).disabledColor;

        return Tooltip(
          message: type.tooltip(context),
          child: Icon(type.icon(active: isSelected), color: color, size: tabSize),
        );
      },
      itemBuilder: (context, index) => Trends(
         type: tabs[index],
         status: status!,
      ),
      onTabTappable: (index) => tabs[index] != TrendsType.users || isSignedIn,
    );
  }
}

// Get the popular statuses trends in the current Mastodon server.
class Trends extends StatefulWidget {
  final TrendsType type;
  final AccessStatusSchema status;

  const Trends({
    super.key,
    required this.type,
    required this.status,
  });

  @override
  State<Trends> createState() => _TrendsState();
}

class _TrendsState extends State<Trends> {
  final double loadingThreshold = 180;

  late final ItemScrollController itemScrollController = ItemScrollController();
  late final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();

  bool isRefresh = false;
  bool isLoading = false;
  bool isCompleted = false;
  List<dynamic> trends = [];

  @override
  void initState() {
    super.initState();

    itemPositionsListener.itemPositions.addListener(() {
      final List<ItemPosition> positions = itemPositionsListener.itemPositions.value.toList();
      final int? lastIndex = positions.isNotEmpty ? positions.last.index : null;

      if (lastIndex != null && lastIndex > trends.length - 5) onLoad();
    });

    GlacialHome.itemScrollToTop = itemScrollController;
    onLoad();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          (isLoading && !isRefresh) ? ClockProgressIndicator() : const SizedBox.shrink(),
          Flexible(child: buildContent()),
        ],
      ),
    );
  }

  // Build the list of the trends.
  Widget buildContent() {
    if (trends.isEmpty) {
      return const SizedBox.shrink();
    }

    return CustomMaterialIndicator(
      onRefresh: onRefresh,
      indicatorBuilder: (_, __) => const ClockProgressIndicator(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: ScrollablePositionedList.builder(
          itemScrollController: itemScrollController,
          itemPositionsListener: itemPositionsListener,
          shrinkWrap: true,
          itemCount: trends.length,
          itemBuilder: (context, index) {
            late final Widget child;

            switch (widget.type) {
              case TrendsType.statuses:
                final StatusSchema status = trends[index] as StatusSchema;
                child = Status(schema: status);
                break;
              case TrendsType.links:
                final LinkSchema link = trends[index] as LinkSchema;
                child = TrendsLink(schema: link);
                break;
              case TrendsType.tags:
                final HashtagSchema hashtag = trends[index] as HashtagSchema;
                child = Hashtag(schema: hashtag);
                break;
              case TrendsType.users:
                final SuggestionSchema suggestion = trends[index] as SuggestionSchema;
                child = Account(schema: suggestion.account);

                return Tooltip(
                  message: suggestion.source.tooltip(context),
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 6),
                    child: child,
                  ),
                );
            }

            return Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.outline)),
              ),
              child: child,
            );
          },
        ),
      ),
    );
  }

  // Clean-up and refresh the timeline when the user pulls down the list.
  Future<void> onRefresh() async {
    setState(() {
      isRefresh = true;
      isLoading = false;
      isCompleted = false;
    });

    await onLoad();
  }

  // Load the statuses from the current selected Mastodon server.
  Future<void> onLoad() async {
    if (isLoading || isCompleted) {
      return;
    }

    if (mounted) setState(() => isLoading = true);

    final int offset = trends.length;
    final List<dynamic> newTrends = await widget.status.fetchTrends(widget.type, offset: offset);

    if (mounted) {
      setState(() {
        isRefresh = false;
        isLoading = false;
        isCompleted = newTrends.isEmpty;
        trends.addAll(newTrends);
      });
    }
  }
}

// vim: set ts=2 sw=2 sts=2 et:
