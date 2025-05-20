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
  final Widget child;
  final SidebarButtonType? active;

  const GlacialHome({
    super.key,
    required this.child,
    this.active,
  });

  @override
  ConsumerState<GlacialHome> createState() => _GlacialHomeState();
}

class _GlacialHomeState extends ConsumerState<GlacialHome> {
  final double appBarHeight = 44;
  final double sidebarSize = 32;
  final List<SidebarButtonType> actions = SidebarButtonType.values;

  late final ServerSchema schema;
  late final int selectedIndex;

  @override
  void initState() {
    super.initState();

    final ServerSchema? schema = ref.read(currentServerProvider);
    if (schema == null) {
      throw Exception("No server schema found, please select a server.");
    }

    this.schema = schema;
    selectedIndex = widget.active == null ? -1 : actions.indexOf(widget.active!);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 600;

        return Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(appBarHeight),
            child: AppBar(
              leading: const SizedBox.shrink(),
              title: Align(
                alignment: Alignment.center,
                child: Tooltip(
                  message: schema.desc,
                  child: InkWellDone(
                    onDoubleTap: onBack,
                    child: Text(
                      schema.title,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
              ),
              actions: [
                UserProfile(schema: schema),
                const SizedBox(width: 8),
              ],
            ),
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
    final Widget content = Align(
      alignment: Alignment.topCenter,
      child: widget.child,
    );

    if (isMobile) {
      return content;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSidebar(),
        const VerticalDivider(),
        Flexible(child: content),
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
          NewStatus(size: sidebarSize),
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
          NewStatus(size: sidebarSize),
        ],
      ),
    );
  }

  List<Widget> buildActions() {
    final String? accessToken = ref.watch(currentAccessTokenProvider);

    return actions.map((action) {
        final int index = actions.indexOf(action);
        final bool isSelected = selectedIndex == index;
        final bool isEnabled = accessToken != null || action.supportAnonymous;

        return IconButton(
          key: ValueKey<int>(index),
          icon: Icon(isSelected ? action.activeIcon : action.icon, size: sidebarSize),
          color: isSelected ? Theme.of(context).colorScheme.primary : null,
          tooltip: actionTooltip(action),
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
          onPressed: isEnabled ? () => onSelect(index) : null,
        );
      }).toList();
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

  // Back to the explorer page.
  void onBack() {
    ref.read(currentServerProvider.notifier).state = null;
    ref.read(currentAccessTokenProvider.notifier).state = null;
    context.go(RoutePath.explorer.path);
  }

  // Select the action in the sidebar and show the corresponding content.
  void onSelect(int index) {
    final SidebarButtonType action = actions[index];
    if (action == widget.active) {
      return;
    }

    switch (action) {
      case SidebarButtonType.timeline:
        context.go(RoutePath.homeTimeline.path, extra: action);
        break;
      case SidebarButtonType.trending:
        context.go(RoutePath.homeTrends.path, extra: action);
        break;
      case SidebarButtonType.explore:
        context.go(RoutePath.homeExplore.path, extra: action);
        break;
      case SidebarButtonType.notifications:
        context.go(RoutePath.homeNotifications.path, extra: action);
        break;
      case SidebarButtonType.settings:
        context.go(RoutePath.homeSettings.path, extra: action);
        break;
    }
  }
}

// vim: set ts=2 sw=2 sts=2 et:
