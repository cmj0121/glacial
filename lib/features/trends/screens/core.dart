// The Trends widget in the current selected Mastodon server.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/glacial/models/server.dart';
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
      itemBuilder: (context, index) => Trends(
        schema: server,
        type: tabs[index],
      ),
    );
  }
}

// Get the popular statuses trends in the current Mastodon server.
class Trends extends StatelessWidget {
  final ServerSchema schema;
  final TrendsType type;

  const Trends({
    super.key,
    required this.schema,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Text(type.name),
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et::w
