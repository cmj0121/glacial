// The webview widget to show the website embedded in the app.
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';

/// Determines navigation decision for a given URL scheme.
/// Returns `true` if the scheme is a deep link (e.g. 'glacial') that should be prevented.
@visibleForTesting
bool isDeepLinkScheme(String scheme) => scheme == 'glacial';

/// Handles a navigation request by checking if the URL is a deep link.
/// If it is a deep link (glacial://), performs OAuth token exchange and returns prevent.
/// Otherwise, returns navigate to allow normal browsing.
@visibleForTesting
Future<NavigationDecision> handleNavigationRequest({
  required String url,
  required WidgetRef ref,
  VoidCallback? onComplete,
}) async {
  final Uri uri = Uri.parse(url);

  if (isDeepLinkScheme(uri.scheme)) {
    final Storage storage = Storage();
    final AccessStatusSchema status = ref.read(accessStatusProvider) ?? AccessStatusSchema();

    await storage.gainAccessToken(uri: uri, expectedServer: status.domain);
    await storage.loadAccessStatus(ref: ref);

    onComplete?.call();
    return NavigationDecision.prevent;
  }

  return NavigationDecision.navigate;
}

class WebViewPage extends ConsumerStatefulWidget {
  final Uri url;

  const WebViewPage({super.key, required this.url});

  @override
  ConsumerState<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends ConsumerState<WebViewPage> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) async {
            return handleNavigationRequest(
              url: request.url,
              ref: ref,
              onComplete: () {
                if (mounted) context.pop();
              },
            );
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url.toString()));
  }

  @override
  Widget build(BuildContext context) {
    logger.i("Loading webview for ${widget.url}");
    return Scaffold(
      appBar: AppBar(),
      body: InteractiveViewer(
        child: WebViewWidget(
          controller: controller,
          gestureRecognizers: {
            Factory<VerticalDragGestureRecognizer>(
              () => VerticalDragGestureRecognizer(),
            ),
          },
        ),
      ),
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
