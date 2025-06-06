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
  final Storage storage = Storage();

  late final List<SidebarButtonType> actions;
  late final ServerSchema schema;

  @override
  void initState() {
    super.initState();

    late final ServerSchema? schema = ref.read(serverProvider);

    if (schema == null) {
      logger.w("No server selected, but it's required to show the home page.");
      return;
    }

    this.schema = schema;
    actions = SidebarButtonType.values;
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
                  child: Text(
                    schema.title,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
              actions: [
                Explorer(),
                IconButton(
                  icon: Icon(Icons.logout),
                  color: Theme.of(context).colorScheme.outline,
                  hoverColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  onPressed: onBack,
                ),
              ],
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
        ],
      ),
    );
  }

  // Build the list of actions in the sidebar for the general user, the actions
  // may not be available for the anonymous user.
  List<Widget> buildActions() {
    final String path = GoRouter.of(context).state.uri.toString();
    final AccountSchema? account = ref.read(accountProvider);
    final RoutePath route = RoutePath.values.where((r) => r.path == path).first;

    return actions.map((action) {
        final int index = actions.indexOf(action);
        final bool isSelected = action.route == route;
        final bool isEnabled = account != null || action.supportAnonymous;

        return IconButton(
          icon: Icon(action.icon(active: isSelected), size: sidebarSize),
          tooltip: action.tooltip(context),
          color: isSelected ? Theme.of(context).colorScheme.primary : null,
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
          onPressed: isEnabled ? () => onSelect(index) : null,
        );
      }).toList();
  }

  // Select the action in the sidebar and show the corresponding content.
  void onSelect(int index) {
    final String path = GoRouter.of(context).state.uri.toString();
    final RoutePath route = RoutePath.values.where((r) => r.path == path).first;
    final SidebarButtonType action = actions[index];

    if (action.route != route) {
      logger.d("selected action: ${action.name} -> ${action.route.path}");
      context.go(action.route.path, extra: action);
    }
  }

  // Back to the explorer page.
  void onBack() async {
    await storage.clearProvider(ref);
    if (mounted) {
      logger.i("back to the explorer page ...");
      context.go(RoutePath.explorer.path);
    }
  }
}

// vim: set ts=2 sw=2 sts=2 et:
