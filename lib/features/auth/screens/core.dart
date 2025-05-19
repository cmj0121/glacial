// The SignIn button to navigate to the sign-in page of the Master server.
import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:glacial/core.dart';
import 'package:glacial/routes.dart';
import 'package:glacial/features/glacial/models/server.dart';
import 'package:glacial/features/auth/models/oauth.dart';

// The Sign In widget is used to sign in to the Mastodon server.
class SignIn extends ConsumerStatefulWidget {
  final ServerSchema schema;
  final double size;

  const SignIn({
    super.key,
    required this.schema,
    this.size = 24,
  });

  @override
  ConsumerState<SignIn> createState() => _SignInState();
}

class _SignInState extends ConsumerState<SignIn> {
  final Storage storage = Storage();

  late final StreamSubscription<Uri?> sub;
  late final String state;

  @override
  void initState() {
    super.initState();

    state = Uuid().v4();
    sub = AppLinks().uriLinkStream.listen(onHandleSignIn);
  }

  @override
  void dispose() {
    super.dispose();
    sub.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon( Icons.login, size: widget.size),
      onPressed: onSignIn,
    );
  }

  // The sign-in button is pressed, navigate to the sign-in page of the
  // Mastodon server.
  void onSignIn() async {
    final OAuth2Info info = await storage.getOAuth2Info(widget.schema.domain);
    final Map<String, dynamic> query = {
      "client_id": info.clientId,
      "response_type": "code",
      "scope": info.scopes.join(" "),
      "redirect_uri": info.redirectUri,
      "state": state,
    }
        ..removeWhere((key, value) => value == null);

    if (mounted) {
      final Uri uri = Uri.https(widget.schema.domain, "/oauth/authorize", query);
      context.push(RoutePath.webview.path, extra: uri);
    }
  }

  // The sign-in page is loaded, handle the sign-in process.
  void onHandleSignIn(Uri uri) async {
    final ServerSchema? schema = ref.read(currentServerProvider);
    final String? code = uri.queryParameters["code"];
    final String? state = uri.queryParameters["state"];

    if (schema == null || code == null) {
      logger.w("expected: schema, code, got: $schema, $code");
      return;
    }

    if (state != this.state) {
      logger.w("state mismatch, expected: $this.state, got: $state");
      return;
    }

    final OAuth2Info info = await storage.getOAuth2Info(schema.domain);
    final String? accessToken = await info.getAccessToken(schema.domain, code);

    if (mounted && accessToken != null) {
      storage.saveAccessToken(schema.domain, accessToken);
      ref.read(currentAccessTokenProvider.notifier).state = accessToken;

      logger.i("completed sign-in and gain the access token");
      context.go(RoutePath.home.path);
    }
  }
}
// vim: set ts=2 sw=2 sts=2 et:
