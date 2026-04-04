// The landing page that shows the app icon during preloading.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';

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
        child: error == null
            ? Center(child: Flipping(child: icon))
            : buildError(context),
      ),
    );
  }

  Widget buildError(BuildContext context) {
    final String changeServer = AppLocalizations.of(context)?.btn_change_server ?? "Change server";

    return ErrorState(
      message: AppLocalizations.of(context)?.msg_server_unreachable
          ?? "Server is unreachable. Check your connection or try a different server.",
      onRetry: () {
        setState(() => error = null);
        onLoading();
      },
      onSecondaryAction: () => context.go(RoutePath.v2Servers.path),
      secondaryLabel: changeServer,
    );
  }

  // Called when the preloading is completed, it will navigate to the next page.
  Future<void> onLoading() async {
    final Storage storage = Storage();

    try {
      await storage.loadPreference(ref: ref);
      await storage.loadAccessStatus(ref: ref);
    } catch (e) {
      setState(() => error = e.toString());
      return ;
    }

    final AccessStatusSchema? status = ref.read(accessStatusProvider);
    final bool hasDomain = status?.domain?.isNotEmpty == true;
    final bool isSignedIn = status?.isSignedIn == true;

    if (!hasDomain) {
      if (mounted) {
        logger.i("preloading completed, no domain → v2 welcome");
        context.go(RoutePath.v2Welcome.path);
      }
      return;
    }

    final timelinesAccess = status?.server?.config.timelinesAccess;
    final bool hasTimeline = SidebarButtonType.timeline.isAccessible(
      isSignedIn: isSignedIn, access: timelinesAccess,
    );
    final RoutePath route = hasTimeline ? RoutePath.timeline : RoutePath.trends;

    if (mounted) {
      logger.i("preloading completed, navigating to ${route.path} (${status?.domain})");
      context.go(route.path);

      final SharedContentSchema? shared = ShareReceiver.consumePendingContent();
      if (shared != null && shared.hasContent && isSignedIn) {
        context.push(RoutePath.postShared.path, extra: shared);
      }
    }
  }
}

// vim: set ts=2 sw=2 sts=2 et:
