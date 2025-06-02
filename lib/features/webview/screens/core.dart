// The webview widget to show the website embedded in the app.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';

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

    // #docregion platform_features
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) async {
            final Uri uri = Uri.parse(request.url);

            switch (uri.scheme) {
              case 'glacial':
                final String? accessToken = await Storage().gainAccessToken(uri);
                final ServerSchema? schema = ref.read(currentServerProvider);

                if (schema != null && accessToken != null) {
                  ref.read(currentAccessTokenProvider.notifier).state = accessToken;
                  ref.read(currentUserProvider.notifier).state = await schema.getAuthUser(accessToken);

                  logger.i("gain access token from ${schema.domain}");
                }

                if (mounted) {
                  // always back to the previous screen
                  context.pop();
                }

                return NavigationDecision.prevent;
              default:
                return NavigationDecision.navigate;
            }
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
        child: WebViewWidget(controller: controller),
      ),
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
