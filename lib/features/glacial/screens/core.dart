// The Glacial home page.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

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
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 600;

        return Scaffold(
          key: scaffoldKey,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(appBarHeight),
            child: AppBar(
              actions: [
                Explorer(size: sidebarSize),
              ],
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: buildContent(isMobile: isMobile),
            ),
          ),
          drawer: const GlacialDrawer(),
          bottomNavigationBar: buildBottomNavigationBar(isMobile: isMobile),
        );
      },
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

    return Padding(
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

    final List<Widget> children = actions.map((action) {
      final int index = actions.indexOf(action);
      final bool isSelected = action.route == route;
      late final Widget icon = Icon(action.icon(active: isSelected), size: sidebarSize);

      if (action == SidebarButtonType.post) {
        return IconButton.filledTonal(
          icon: icon,
          tooltip: action.tooltip(context),
          color: isSelected ? Theme.of(context).colorScheme.primary : null,
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
          onPressed: () => onSelect(index),
        );
      }

      return IconButton(
        icon: icon,
        tooltip: action.tooltip(context),
        color: isSelected ? Theme.of(context).colorScheme.primary : null,
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        onPressed: () => onSelect(index),
      );
    }).toList();

    return children;
  }

  // Select the action in the sidebar and show the corresponding content.
  void onSelect(int index) {
    final SidebarButtonType action = actions[index];

    logger.d("selected action: ${action.name} -> ${action.route.path}");
    context.go(action.route.path, extra: action);
  }
}

// The Glacial SideDrawer, used to show the current sign-in user, the advanced
// operations and the server switcher.
class GlacialDrawer extends StatelessWidget {
  const GlacialDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final int logoutIndex = DrawerButtonType.values.indexWhere((action) => action == DrawerButtonType.logout);
    final List<Widget> children = DrawerButtonType.values.map((action) {
      return ListTile(
        leading: Icon(action.icon()),
        title: Text(action.tooltip(context)),
        onTap: () {
          context.pop(); // Close the drawer before navigating
          logger.d("selected drawer action: ${action.name} -> ${action.route.path}");
          context.go(action.route.path);
        }
      );
    }).toList();

    return Drawer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const DrawerHeader(child: Text('Glacial')),
          ...children.sublist(0, logoutIndex),
          const Spacer(),
          children[logoutIndex],
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// The landing page that shows the icon of the app and flips intermittently.
class LandingPage extends ConsumerStatefulWidget {
  final double size;

  const LandingPage({
    super.key,
    this.size = 64,
  });

  @override
  ConsumerState<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends ConsumerState<LandingPage> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      logger.i("preloading resources ...");
      onLoading();
    });
  }

  @override
  Widget build(BuildContext context) {
    final double size = widget.size;
    final Widget icon = Image.asset('assets/images/icon.png', width: size, height: size);

    return Scaffold(
      body: SafeArea(
        child: Center(child: Flipping(child: icon)),
      ),
    );
  }

  // Called when the preloading is completed, it will navigate to the next page.
  void onLoading() async {
    await Storage().loadPreference(ref);

    if (mounted) {
      context.go(RoutePath.timeline.path);
      return;
    }
  }
}

// vim: set ts=2 sw=2 sts=2 et:
