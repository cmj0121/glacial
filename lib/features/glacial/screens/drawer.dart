// The Glacial SideDrawer widget.
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

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
    final bool isSignedIn = status?.accessToken?.isNotEmpty ?? false;
    final List<DrawerButtonType> actions = DrawerButtonType.values
        .where((a) => (a != DrawerButtonType.switchAccount && a != DrawerButtonType.drafts) || isSignedIn)
        .toList();
    final int logoutIndex = actions.indexWhere((action) => action == DrawerButtonType.logout);
    final List<Widget> children = actions.map((action) {
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
                    Text(status?.domain ?? AppLocalizations.of(context)?.txt_default_server_name ?? 'Glacial Server'),
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

  Future<void> onTap(AccessStatusSchema? status, DrawerButtonType action) async {
    final Storage storage = Storage();

    context.pop(); // Close the drawer before navigating

    switch (action) {
      case DrawerButtonType.switchAccount:
        if (mounted) {
          showAdaptiveGlassSheet(
            context: context,
            builder: (_) => AccountPickerSheet(status: status),
          );
        }
        return;
      case DrawerButtonType.drafts:
        if (mounted) {
          showAdaptiveGlassSheet(
            context: context,
            builder: (_) => DraftListSheet(status: status),
          );
        }
        return;
      case DrawerButtonType.switchServer:
        storage.saveAccessStatus((status ?? AccessStatusSchema()).copyWith(domain: ''), ref: ref);
        break;
      case DrawerButtonType.announcement:
        if (mounted) {
          showAdaptiveGlassSheet(
            context: context,
            builder: (_) => AnnouncementSheet(status: status),
          );
        }
        return;
      case DrawerButtonType.logout:
        await storage.logout(status, ref: ref);
        // always force reload the app after logout
        ref.read(reloadProvider.notifier).state = !ref.read(reloadProvider);
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

// vim: set ts=2 sw=2 sts=2 et:
