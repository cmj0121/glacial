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
        child: error == null ? Center(child: Flipping(child: icon)) : NoResult(message: error!),
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
    final bool hasPublicFeeds = status?.server?.config.timelinesAccess.hasPublicFeeds ?? true;
    final RoutePath route = !hasDomain ? RoutePath.explorer :
        hasPublicFeeds ? RoutePath.timeline : RoutePath.trends;

    if (mounted) {
      logger.i("preloading completed, navigating to the ${route.path} page (${status?.domain}) ...");
      context.go(route.path);
    }
  }
}

// vim: set ts=2 sw=2 sts=2 et:
