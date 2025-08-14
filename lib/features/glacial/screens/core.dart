// The Glacial home page.
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

// The main home page of the app, interacts with the current server and show the
// server timeline and other features.
class GlacialHome extends ConsumerStatefulWidget {
  // The global scroll-to-top controller callback
  static ScrollController? scrollToTop;

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
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 600;
        final IconData icon = widget.backable ? Icons.arrow_back_ios_new_rounded : Icons.read_more_rounded;

        return Scaffold(
          key: scaffoldKey,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(appBarHeight),
            child: AppBar(
              leading: IconButton(
                icon: Icon(icon, size: iconSize, color: Theme.of(context).colorScheme.onSurface),
                hoverColor: Colors.transparent,
                focusColor: Colors.transparent,
                onPressed: widget.backable ? () => context.pop() : () => scaffoldKey.currentState?.openDrawer(),
              ),
              title: widget.title,
              actions: [
                ...widget.actions,
                SearchExplorer(size: sidebarSize),
              ],
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: buildContent(isMobile: isMobile),
            ),
          ),
          drawer: GlacialDrawer(),
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
    final AccessStatusSchema? status = ref.read(accessStatusProvider);

    final List<Widget> children = actions.map((action) {
      final int index = actions.indexOf(action);
      final bool isSelected = action.route == route;
      late final Widget icon = Icon(action.icon(active: isSelected), size: sidebarSize);

      switch (action) {
        case SidebarButtonType.notifications:
          return NotificationBadge(
            size: sidebarSize,
            isSelected: isSelected,
            onPressed: () => debounce.callOnce(() => onSelect(index)),
          );
        case SidebarButtonType.post:
          if (status?.accessToken?.isNotEmpty == true) {
            // Already signed in, show the post button.
            return IconButton.filledTonal(
              icon: icon,
              tooltip: action.tooltip(context),
              color: isSelected ? Theme.of(context).colorScheme.primary : null,
              hoverColor: Colors.transparent,
              focusColor: Colors.transparent,
              onPressed: () => debounce.callOnce(() => onSelect(index)),
            );
          }

          return SignIn(size: sidebarSize);
        default:
          return IconButton(
            icon: icon,
            tooltip: action.tooltip(context),
            color: isSelected ? Theme.of(context).colorScheme.primary : null,
            hoverColor: Colors.transparent,
            focusColor: Colors.transparent,
            onPressed: () => debounce.callOnce(() => onSelect(index)),
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

    if (curRoute == action.route) {
      logger.d("already on the ${action.name} page, no need to navigate.");

      if (GlacialHome.scrollToTop?.hasClients == true) {
        final Duration duration = const Duration(milliseconds: 300);

        GlacialHome.scrollToTop?.animateTo(0, duration: duration, curve: Curves.easeInOut);
      }
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

// The Glacial SideDrawer, used to show the current sign-in user, the advanced
// operations and the server switcher.
class GlacialDrawer extends ConsumerStatefulWidget {
  const GlacialDrawer({super.key});

  @override
  ConsumerState<GlacialDrawer> createState() => _GlacialDrawerState();
}

class _GlacialDrawerState extends ConsumerState<GlacialDrawer> {
  @override
  Widget build(BuildContext context) {
    final AccessStatusSchema? status = ref.watch(accessStatusProvider);
    final int logoutIndex = DrawerButtonType.values.indexWhere((action) => action == DrawerButtonType.logout);
    final List<Widget> children = DrawerButtonType.values.map((action) {
      return ListTile(
        leading: Icon(action.icon()),
        title: Text(action.tooltip(context)),
        onTap: () => onTap(status, action),
      );
    }).toList();


    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double height = min(constraints.maxHeight, 85);

        return Drawer(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DrawerHeader(
                child: Column(
                  children: [
                    Text(status?.domain ?? 'Glacial Server'),
                    const SizedBox(height: 8),
                    status?.server?.thumbnail == null ?
                      const SizedBox.shrink() :
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: status?.server?.thumbnail ?? '-',
                          placeholder: (context, url) => SizedBox(
                            width: width,
                            height: height,
                            child: ClockProgressIndicator(size: min(width, height) / 2),
                          ),
                          errorWidget: (context, url, error) => const Icon(Icons.error),
                          imageBuilder: (context, imageProvider) => Image(
                            image: imageProvider,
                            width: width,
                            height: height,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              AccountLite(schema: status?.account, size: tabSize),
              ...children.sublist(0, logoutIndex),

              const Spacer(),
              if (status?.accessToken?.isNotEmpty ?? false) children[logoutIndex],
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void onTap(AccessStatusSchema? status, DrawerButtonType action) async {
    final Storage storage = Storage();

    context.pop(); // Close the drawer before navigating

    switch (action) {
      case DrawerButtonType.switchServer:
        storage.saveAccessStatus((status ?? AccessStatusSchema()).copyWith(domain: ''), ref: ref);
        break;
      case DrawerButtonType.logout:
        await storage.logout(status, ref: ref);
        return;
      default:
        break;
    }

    if (mounted) {
      logger.d("selected drawer action: ${action.name} -> ${action.route.path}");
      context.push(action.route.path);
    }
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
  String? error;

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
        child: error == null ? Center(child: Flipping(child: icon)) : NoResult(message: error!),
      ),
    );
  }

  // Called when the preloading is completed, it will navigate to the next page.
  void onLoading() async {
    final Storage storage = Storage();

    try {
      await storage.loadPreference(ref: ref);
      await storage.loadAccessStatus(ref: ref);
    } catch (e) {
      setState(() => error = e.toString());
      return ;
    }

    final AccessStatusSchema? status = ref.read(accessStatusProvider);
    final RoutePath route = status?.domain?.isEmpty ?? true ? RoutePath.explorer : RoutePath.timeline;

    if (mounted) {
      logger.i("preloading completed, navigating to the ${route.path} page (${status?.domain}) ...");
      context.go(route.path);
    }
  }
}

// vim: set ts=2 sw=2 sts=2 et:
