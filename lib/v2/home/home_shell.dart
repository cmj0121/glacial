// The v2 home shell — icon-only navigation with drawer.
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';
import 'package:glacial/v2/core.dart';

class V2HomeShell extends ConsumerStatefulWidget {
  final bool backable;
  final Widget? title;
  final List<Widget> actions;
  final Widget child;

  const V2HomeShell({
    super.key,
    this.backable = false,
    this.title,
    this.actions = const [],
    required this.child,
  });

  @override
  ConsumerState<V2HomeShell> createState() => _V2HomeShellState();
}

class _V2HomeShellState extends ConsumerState<V2HomeShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Debouncer _debounce = Debouncer();

  @override
  void dispose() {
    _debounce.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(accessStatusProvider);
    final bool isSignedIn = status?.isSignedIn == true;
    final bool isAdmin = status?.account?.role?.hasPrivilege == true;
    final timelinesAccess = status?.server?.config.timelinesAccess;

    // Use MediaQuery instead of LayoutBuilder to determine wide/narrow
    // layout. LayoutBuilder creates a nested build scope that conflicts
    // with AnimatedWidgets (AnimatedBuilder, scroll animations, etc.)
    // anywhere in the descendant tree during animation ticks.
    final bool isWide = MediaQuery.sizeOf(context).width >= V2Theme.wideBreakpoint;
    final allItems = SidebarButtonType.values.where((item) {
      if (item == SidebarButtonType.admin && !isAdmin) return false;
      return true;
    }).toList();
    final bool showNav = allItems.isNotEmpty && !widget.backable;

    return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            leading: widget.backable
                ? IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    onPressed: () => context.pop(),
                  )
                : IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                  ),
            title: widget.title,
            actions: [
              ...widget.actions,
              SearchExplorer(size: iconSize),
            ],
          ),
          drawer: widget.backable ? null : _buildDrawer(status),
          body: AppShortcuts(
            child: SafeArea(
              child: Row(
                children: [
                  if (isWide && showNav)
                    _buildSidebar(allItems, isSignedIn: isSignedIn, access: timelinesAccess),
                  Expanded(child: widget.child),
                ],
              ),
            ),
          ),
          bottomNavigationBar: isWide || !showNav
              ? null
              : _buildBottomNav(allItems, isSignedIn: isSignedIn, access: timelinesAccess),
        );
  }

  Widget _buildDrawerHeader(AccessStatusSchema? status, ThemeData theme, String domain) {
    final String? thumbnail = status?.server?.thumbnail;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (thumbnail != null && thumbnail.isNotEmpty)
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(V2Theme.borderRadius),
              bottomRight: Radius.circular(V2Theme.borderRadius),
            ),
            child: CachedNetworkImage(
              imageUrl: thumbnail,
              width: double.infinity,
              height: 120,
              fit: BoxFit.cover,
              placeholder: (context, url) => ShimmerEffect(
                child: Container(height: 120, color: theme.colorScheme.surfaceContainerHighest),
              ),
              errorWidget: (context, url, error) => const SizedBox.shrink(),
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(V2Theme.spacingLG),
          child: Row(
            children: [
              Image.asset('assets/images/icon.png', width: 32, height: 32),
              if (domain.isNotEmpty) ...[
                const SizedBox(width: V2Theme.spacingMD),
                Expanded(
                  child: Text(domain, style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  )),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDrawer(AccessStatusSchema? status) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final String domain = status?.domain ?? '';
    final bool isSignedIn = status?.isSignedIn == true;

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDrawerHeader(status, theme, domain),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.swap_horiz),
                      title: Text(l10n?.btn_drawer_switch_server ?? 'Switch Server'),
                      onTap: () {
                        Navigator.of(context).pop();
                        context.go(RoutePath.v2AccountHub.path);
                      },
                    ),
                    if (isSignedIn) ...[
                      ListTile(
                        leading: status?.account != null
                            ? AccountAvatar(schema: status!.account!, size: 28)
                            : const Icon(Icons.person_outline),
                        title: Text(l10n?.btn_profile_core ?? 'Profile'),
                        onTap: () {
                          Navigator.of(context).pop();
                          if (status?.account != null) {
                            context.push(RoutePath.profile.path, extra: status!.account);
                          }
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.people_outline),
                        title: Text(l10n?.btn_drawer_switch_account ?? 'Switch Account'),
                        onTap: () {
                          Navigator.of(context).pop();
                          showAdaptiveGlassSheet(
                            context: context,
                            builder: (_) => AccountPickerSheet(status: status),
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.drafts_outlined),
                        title: Text(l10n?.btn_drawer_drafts ?? 'Drafts'),
                        onTap: () {
                          Navigator.of(context).pop();
                          final messenger = ScaffoldMessenger.of(context);
                          showAdaptiveGlassSheet(
                            context: context,
                            builder: (_) => DraftListSheet(status: status, messenger: messenger),
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.explore_outlined),
                        title: Text(l10n?.btn_drawer_directory ?? 'Directory'),
                        onTap: () {
                          Navigator.of(context).pop();
                          context.push(RoutePath.directory.path);
                        },
                      ),
                    ],
                    ListTile(
                      leading: const Icon(Icons.campaign_outlined),
                      title: Text(l10n?.btn_drawer_announcement ?? 'Announcements'),
                      onTap: () {
                        Navigator.of(context).pop();
                        showAdaptiveGlassSheet(
                          context: context,
                          builder: (_) => AnnouncementSheet(status: status),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: Text(l10n?.btn_drawer_instance_info ?? 'About This Server'),
                      onTap: () {
                        Navigator.of(context).pop();
                        showAdaptiveGlassSheet(
                          context: context,
                          builder: (_) => InstanceInfoSheet(status: status),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.settings_outlined),
                      title: Text(l10n?.btn_drawer_preference ?? 'Preference'),
                      onTap: () {
                        Navigator.of(context).pop();
                        context.push(RoutePath.preference.path);
                      },
                    ),
                  ],
                ),
              ),
            ),
            if (isSignedIn) ...[
              const Divider(),
              ListTile(
                leading: Icon(Icons.logout, color: theme.colorScheme.error),
                title: Text(l10n?.btn_drawer_logout ?? 'Logout'),
                onTap: () {
                  Navigator.of(context).pop();
                  _onLogout();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  RoutePath? get _currentRoute {
    final path = GoRouter.of(context).state.uri.toString();
    return RoutePath.values.where((r) => r.path == path).firstOrNull;
  }

  Widget _buildNavButton(
    SidebarButtonType item, {
    required RoutePath? current,
    required bool isSignedIn,
    TimelinesAccessSchema? access,
  }) {
    final bool accessible = item.isAccessible(isSignedIn: isSignedIn, access: access);
    final bool isSelected = item.route == current;

    Color? color;
    if (!accessible) {
      color = Theme.of(context).disabledColor;
    } else if (isSelected) {
      color = Theme.of(context).colorScheme.primary;
    }

    return IconButton(
      icon: Icon(item.icon(active: isSelected), size: iconSize, color: color),
      tooltip: item.tooltip(context),
      onPressed: accessible ? () => _onNavTap(item) : null,
    );
  }

  Widget _buildSidebar(
    List<SidebarButtonType> items, {
    required bool isSignedIn,
    TimelinesAccessSchema? access,
  }) {
    final current = _currentRoute;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: V2Theme.spacingXS, vertical: V2Theme.spacingSM),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: items
                    .where((i) => i != SidebarButtonType.post)
                    .map((item) => _buildNavButton(item, current: current, isSignedIn: isSignedIn, access: access))
                    .toList(),
              ),
            ),
          ),
          _buildPostButton(current, isSignedIn: isSignedIn),
        ],
      ),
    );
  }

  Widget _buildBottomNav(
    List<SidebarButtonType> items, {
    required bool isSignedIn,
    TimelinesAccessSchema? access,
  }) {
    final current = _currentRoute;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: V2Theme.spacingSM),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: items.map((item) {
            if (item == SidebarButtonType.post) {
              return _buildPostButton(current, isSignedIn: isSignedIn);
            }
            return _buildNavButton(item, current: current, isSignedIn: isSignedIn, access: access);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPostButton(RoutePath? current, {required bool isSignedIn}) {
    final bool isSelected = SidebarButtonType.post.route == current;
    if (isSignedIn) {
      return IconButton.filledTonal(
        icon: Icon(SidebarButtonType.post.icon(active: isSelected), size: iconSize),
        tooltip: SidebarButtonType.post.tooltip(context),
        color: isSelected ? Theme.of(context).colorScheme.primary : null,
        onPressed: () => _onNavTap(SidebarButtonType.post),
      );
    }
    return SignIn(size: iconSize);
  }

  void _onNavTap(SidebarButtonType item) {
    _debounce.callOnce(() {
      final current = _currentRoute;

      // Already on this page → scroll to top
      if (current == item.route && GlacialHome.itemScrollToTop?.isAttached == true) {
        GlacialHome.itemScrollToTop?.scrollTo(
          index: 0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        return;
      }

      if (item == SidebarButtonType.post) {
        context.push(item.route.path);
      } else {
        context.go(item.route.path);
      }
    });
  }

  Future<void> _onLogout() async {
    final status = ref.read(accessStatusProvider);
    if (status == null) return;

    await Storage().logout(status, ref: ref);
    if (mounted) context.go(RoutePath.v2AccountHub.path);
  }
}

// vim: set ts=2 sw=2 sts=2 et:
