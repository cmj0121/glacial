// The Glacial home page.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/routes.dart';
import 'package:glacial/features/glacial/models/server.dart';
import 'package:glacial/features/auth/screens/core.dart';
import 'package:glacial/features/timeline/screens/core.dart';

// The possible actions in sidebar and used to interact with the current server.
enum SidebarButtonType {
  timeline,
  trending,
  explore,
  notifications,
  settings;

  bool get supportAnonymous {
    switch (this) {
      case timeline:
      case trending:
      case explore:
        return true;
      case notifications:
      case settings:
        return false;
    }
  }

  IconData get icon {
    switch (this) {
      case timeline:
        return Icons.view_list_outlined;
      case trending:
        return Icons.trending_up_outlined;
      case explore:
        return Icons.search_outlined;
      case notifications:
        return Icons.notifications_outlined;
      case settings:
        return Icons.settings_outlined;
    }
  }

  IconData get activeIcon {
    switch (this) {
      case timeline:
        return Icons.view_list;
      case trending:
        return Icons.bar_chart;
      case explore:
        return Icons.manage_search;
      case notifications:
        return Icons.notifications;
      case settings:
        return Icons.settings;
    }
  }
}

// The main home page of the app, interacts with the current server and show the
// server timeline and other features.
class GlacialHome extends ConsumerStatefulWidget {
  const GlacialHome({super.key});

  @override
  ConsumerState<GlacialHome> createState() => _GlacialHomeState();
}

class _GlacialHomeState extends ConsumerState<GlacialHome> {
  final double sidebarSize = 32;
  final List<SidebarButtonType> actions = SidebarButtonType.values;
  late final ServerSchema schema;

  late int selectedIndex;
  late Widget content;

  @override
  void initState() {
    super.initState();

    final ServerSchema? schema = ref.read(currentServerProvider);
    if (schema == null) {
      throw Exception("No server schema found, please select a server.");
    }

    this.schema = schema;
    onSelect(SidebarButtonType.timeline.index);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 600;

        return Scaffold(
          appBar: AppBar(
            leading: buildBackButton(),
            title: Center(
              child: Tooltip(
                message: schema.desc,
                child: Text(
                  schema.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ),
            actions: [
              SignIn(),
              const SizedBox(width: 8),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: buildContent(isMobile: isMobile),
            ),
          ),
          bottomNavigationBar: buildBottomNavigationBar(isMobile: isMobile),
        );
      },
    );
  }

  // The main content of the home page, shows the server timeline and other
  // features.
  Widget buildContent({required bool isMobile}) {
    final Widget animatedContent = AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return ScaleTransition(scale: animation, child: child);
      },
      child: Align(
        key: ValueKey<int>(selectedIndex), // Ensure actually changing the widget identity
        alignment: Alignment.topCenter,
        child: content,
      ),
    );

    if (isMobile) {
      return animatedContent;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSidebar(),
        const VerticalDivider(),
        Flexible(child: animatedContent),
      ],
    );
  }

  // The left sidebar of the app, shows the possible actions to interact with
  // the current server.
  Widget buildSidebar() {
    return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...buildActions(),
          const Spacer(),
          buildPostButton(),
        ],
    );
  }

  // Build the buttom navigation bar for the app, used in the mobile devices.
  Widget? buildBottomNavigationBar({required bool isMobile}) {
    if (!isMobile) {
      return null;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...buildActions(),
          buildPostButton(),
        ],
      ),
    );
  }

  List<Widget> buildActions() {
    return actions.map((action) {
        final int index = actions.indexOf(action);
        final bool isSelected = selectedIndex == index;

        return IconButton(
          key: ValueKey<int>(index),
          icon: Icon(isSelected ? action.activeIcon : action.icon, size: sidebarSize),
          color: isSelected ? Theme.of(context).colorScheme.primary : null,
          tooltip: actionTooltip(action),
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
          onPressed: action.supportAnonymous ? () => onSelect(index) : null,
        );
      }).toList();
  }

  // Back to the explorer page.
  Widget buildBackButton() {
    return IconButton(
      icon: Icon(Icons.account_tree_outlined),
      tooltip: AppLocalizations.of(context)?.btn_back_to_explorer ?? "Back to Explorer",
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      onPressed: () {
        ref.read(currentServerProvider.notifier).state = null;
        context.go(RoutePath.explorer.path);
      },
    );
  }

  // The post button to post a new status to the current server.
  Widget buildPostButton() {
    return IconButton.filledTonal(
      icon: Icon(Icons.post_add_outlined, size: sidebarSize),
      tooltip: AppLocalizations.of(context)?.btn_post ?? "Post",
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      onPressed: () {},
    );
  }

  // The list of actions could be performed in the sidebar.
  String actionTooltip(SidebarButtonType action) {
    switch (action) {
      case SidebarButtonType.timeline:
        return AppLocalizations.of(context)?.btn_timeline ?? "Timeline";
      case SidebarButtonType.trending:
        return AppLocalizations.of(context)?.btn_trending ?? "Trending";
      case SidebarButtonType.explore:
        return AppLocalizations.of(context)?.btn_explore ?? "Explore";
      case SidebarButtonType.notifications:
        return AppLocalizations.of(context)?.btn_notifications ?? "Notifications";
      case SidebarButtonType.settings:
        return AppLocalizations.of(context)?.btn_settings ?? "Settings";
    }
  }

  void onSelect(int index) {
    setState(() {
      selectedIndex = index;

      switch (actions[index]) {
        case SidebarButtonType.timeline:
          content = const TimelineTab();
          break;
        case SidebarButtonType.trending:
          content = const WIP();
          break;
        case SidebarButtonType.explore:
          content = const WIP();
          break;
        case SidebarButtonType.notifications:
          content = const WIP();
          break;
        case SidebarButtonType.settings:
          content = const WIP();
          break;
      }
    });
  }
}

// vim: set ts=2 sw=2 sts=2 et:
