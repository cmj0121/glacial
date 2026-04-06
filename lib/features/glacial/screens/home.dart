// The Glacial home page.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

// The main home page of the app, interacts with the current server and show the
// server timeline and other features.
class GlacialHome extends ConsumerStatefulWidget {
  // The global scroll-to-top controller callback
  static ItemScrollController? itemScrollToTop;
  static ItemPositionsListener? itemPositions;
  static List<StatusSchema> Function()? getStatuses;
  static TabController? activeTabController;
  static List<int> Function()? activeVisibleIndexes;
  // Cycle the active SwipeTabView forward (delta=1) or backward (delta=-1).
  static void Function(int delta)? onTabSwitch;
  static VoidCallback? onFocusSearch;
  // Collapse/clear the search bar when Esc is pressed.
  static VoidCallback? onCloseSearch;
  static Future<void> Function()? onRefresh;
  // Toggle a reblog/favourite/bookmark interaction on the status at index.
  static Future<void> Function(int index, StatusInteraction action)? onInteractStatus;
  // Index of the status currently focused by keyboard navigation (j/k).
  // null means no selection; timelines observe this to render a highlight.
  static final ValueNotifier<int?> focusedStatusIndex = ValueNotifier<int?>(null);
  // When set, viewport-based auto-focus is suppressed until this instant
  // so j/k moves aren't stomped by the in-flight scroll animation.
  static DateTime? suppressAutoFocusUntil;
  // Label of the active sub-tab (e.g. "Home", "Public") — shown
  // in the app bar as a subtitle next to the route title.
  static final ValueNotifier<String?> activeTabLabel = ValueNotifier<String?>(null);

  final bool backable;
  final Widget? title;
  final List<Widget> actions;
  final Widget child;

  const GlacialHome({
    super.key,
    this.backable = false,
    this.title,
    this.actions = const [],
    required this.child,
  });

  @override
  ConsumerState<GlacialHome> createState() => _GlacialHomeState();
}

class _GlacialHomeState extends ConsumerState<GlacialHome> {
  final double appBarHeight = 44;
  final double sidebarSize = iconSize;
  final Debouncer debounce = Debouncer();

  late final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  late final List<SidebarButtonType> actions = SidebarButtonType.values;
  late final Widget content;

  @override
  void initState() {
    super.initState();
    content = Align(
      alignment: Alignment.topCenter,
      child: widget.child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.sizeOf(context).width < 600;
    final IconData icon = widget.backable ? Icons.arrow_back_ios_new_rounded : Icons.read_more_rounded;

    return Scaffold(
      key: scaffoldKey,
      extendBodyBehindAppBar: useLiquidGlass,
      appBar: AdaptiveGlassAppBar(
        leading: AdaptiveGlassIconButton(
          icon: icon,
          size: iconSize,
          onPressed: widget.backable ? () => context.pop() : () => scaffoldKey.currentState?.openDrawer(),
        ),
        title: widget.title,
        actions: [
          ...widget.actions,
          SearchExplorer(size: sidebarSize),
        ],
      ),
      body: AppShortcuts(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: buildContent(isMobile: isMobile),
          ),
        ),
      ),
      drawer: GlacialDrawer(),
      bottomNavigationBar: buildBottomNavigationBar(isMobile: isMobile),
    );
  }

  // The main content of the home page, shows the server timeline and other
  // features.
  Widget buildContent({required bool isMobile}) {
    if (isMobile) {
      return content;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSidebar(),
        Flexible(child: content),
      ],
    );
  }

  // The left sidebar of the app, shows the possible actions to interact with
  // the current server.
  Widget buildSidebar() {
    final List<Widget> children = buildActions();
    final int postIndex = actions.indexWhere((action) => action.route == RoutePath.post);

    return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...children.sublist(0, postIndex),
          const Spacer(),
          ...children.sublist(postIndex, children.length),
          const SizedBox(height: 8),
        ],
    );
  }

  // Build the buttom navigation bar for the app, used in the mobile devices.
  Widget? buildBottomNavigationBar({required bool isMobile}) {
    if (!isMobile) {
      return null;
    }

    return AdaptiveGlassBottomBar(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: buildActions(),
      ),
    );
  }

  // Build the list of actions in the sidebar for the general user, the actions
  // may not be available for the anonymous user.
  List<Widget> buildActions() {
    final String path = GoRouter.of(context).state.uri.toString();
    final RoutePath route = RoutePath.values.where((r) => r.path == path).first;
    final AccessStatusSchema? status = ref.read(accessStatusProvider);
    final bool isSignedIn = status?.accessToken?.isNotEmpty == true;
    final bool isAdmin = status?.account?.role?.hasPrivilege == true;
    final timelinesAccess = status?.server?.config.timelinesAccess;

    final List<Widget> children = actions.map((action) {
      final int index = actions.indexOf(action);
      final bool isSelected = action.route == route;
      late final Widget icon = Icon(action.icon(active: isSelected), size: sidebarSize);

      switch (action) {
        case SidebarButtonType.notifications:
          return NotificationBadge(
            size: sidebarSize,
            isSelected: isSelected,
            onPressed: isSignedIn ? () => debounce.callOnce(() => onSelect(index)) : null,
          );
        case SidebarButtonType.post:
          if (status?.accessToken?.isNotEmpty == true) {
            // Already signed in, show the post button.
            return IconButton.filledTonal(
              icon: icon,
              tooltip: action.tooltip(context),
              color: isSelected ? Theme.of(context).colorScheme.primary : null,
              onPressed: () => debounce.callOnce(() => onSelect(index)),
            );
          }

          return SignIn(size: sidebarSize);
        case SidebarButtonType.admin:
          final Widget adminButton = IconButton(
            icon: icon,
            tooltip: action.tooltip(context),
            color: isSelected ? Theme.of(context).colorScheme.primary : null,
            onPressed: isAdmin ? () => debounce.callOnce(() => onSelect(index)) : null,
          );
          return isAdmin ? adminButton : AccessibleTooltip(
            message: AppLocalizations.of(context)?.msg_admin_only ?? 'Admin access required',
            child: adminButton,
          );
        default:
          final bool accessible = action.isAccessible(isSignedIn: isSignedIn, access: timelinesAccess);
          return IconButton(
            icon: icon,
            tooltip: action.tooltip(context),
            color: isSelected ? Theme.of(context).colorScheme.primary : null,
            onPressed: accessible ? () => debounce.callOnce(() => onSelect(index)) : null,
          );
      }
    }).toList();

    return children;
  }

  // Select the action in the sidebar and show the corresponding content.
  void onSelect(int index) {
    final SidebarButtonType action = actions[index];
    final String path = GoRouter.of(context).state.uri.toString();
    final RoutePath curRoute = RoutePath.values.where((r) => r.path == path).first;
    final Duration duration = const Duration(milliseconds: 300);
    final Curve curve = Curves.easeInOut;

    if (curRoute == action.route && GlacialHome.itemScrollToTop?.isAttached == true) {
      logger.d("already on the ${action.name} page, no need to navigate.");

      GlacialHome.itemScrollToTop?.scrollTo(index: 0, duration: duration, curve: curve);
      return ;
    }

    switch (action.route) {
      case RoutePath.post:
        context.push(action.route.path);
        break;
      default:
        context.go(action.route.path);
        break;
    }
  }
}

// vim: set ts=2 sw=2 sts=2 et:
