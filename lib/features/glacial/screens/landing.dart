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
    final String message = AppLocalizations.of(context)?.msg_loading_error
        ?? "Something went wrong while loading. Please try again.";
    final String retryLabel = AppLocalizations.of(context)?.btn_retry ?? "Retry";

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_outlined, size: 64, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() => error = null);
                onLoading();
              },
              icon: const Icon(Icons.refresh),
              label: Text(retryLabel),
            ),
          ],
        ),
      ),
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
    final timelinesAccess = status?.server?.config.timelinesAccess;
    final bool hasTimeline = SidebarButtonType.timeline.isAccessible(
      isSignedIn: isSignedIn, access: timelinesAccess,
    );
    final RoutePath route = !hasDomain ? RoutePath.explorer :
        hasTimeline ? RoutePath.timeline : RoutePath.trends;

    if (mounted) {
      logger.i("preloading completed, navigating to the ${route.path} page (${status?.domain}) ...");
      context.go(route.path);
    }
  }
}

// vim: set ts=2 sw=2 sts=2 et:
