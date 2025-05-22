// The Glacial home page.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/core.dart';
import 'package:glacial/features/glacial/models/server.dart';

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

  RoutePath get route {
    switch (this) {
      case timeline:
        return RoutePath.timeline;
      case trending:
        return RoutePath.trends;
      case explore:
        return RoutePath.explorer;
      case notifications:
        return RoutePath.notifications;
      case settings:
        return RoutePath.settings;
    }
  }
}

// The main home page of the app, interacts with the current server and show the
// server timeline and other features.
class GlacialHome extends ConsumerStatefulWidget {
  final Widget child;

  const GlacialHome({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<GlacialHome> createState() => _GlacialHomeState();
}

class _GlacialHomeState extends ConsumerState<GlacialHome> {
  final double appBarHeight = 44;
  final double sidebarSize = 32;
  final List<SidebarButtonType> actions = SidebarButtonType.values;

  late final ServerSchema schema;

  @override
  void initState() {
    super.initState();

    final ServerSchema? schema = ref.read(currentServerProvider);
    if (schema == null) {
      throw Exception("No server schema found, please select a server.");
    }
    this.schema = schema;
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
              leading: UserAvatar(schema: schema),
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
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
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
    final String path = GoRouter.of(context).state.uri.toString();
    final RoutePath route = RoutePath.values.where((r) => r.path == path).first;

    return actions.map((action) {
        final int index = actions.indexOf(action);
        final bool isSelected = action.route == route;
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
    context.go(RoutePath.serverExplorer.path);
  }

  // Select the action in the sidebar and show the corresponding content.
  void onSelect(int index) {
    final String path = GoRouter.of(context).state.uri.toString();
    final RoutePath route = RoutePath.values.where((r) => r.path == path).first;
    final SidebarButtonType action = actions[index];

    if (action.route != route) {
      logger.i("selected action: ${action.name} -> ${action.route.path}");
      context.go(action.route.path, extra: action);
    }
  }
}

// vim: set ts=2 sw=2 sts=2 et:
