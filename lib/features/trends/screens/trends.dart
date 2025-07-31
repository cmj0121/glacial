// The Trends widget in the current selected Mastodon server.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';

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
    if (status?.server?.isEmpty == true) {
      logger.w("No server selected, but it's required to show the trends.");
      return const SizedBox.shrink();
    }

    return SwipeTabView(
      tabController: controller,
      itemCount: tabs.length,
      tabBuilder: (context, index) {
        final TrendsType type = tabs[index];
        final Widget icon = Icon(type.icon(active: controller.index == index), size: tabSize);

        return Tooltip(
          message: type.tooltip(context),
          child: icon,
        );
      },
      itemBuilder: (context, index) => Trends(type: tabs[index]),
    );
  }
}

// Get the popular statuses trends in the current Mastodon server.
class Trends extends StatelessWidget {
  final TrendsType type;

  const Trends({
    super.key,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return const WIP();
  }
}

// vim: set ts=2 sw=2 sts=2 et:
