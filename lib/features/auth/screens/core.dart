// The SignIn button to navigate to the sign-in page of the Master server.
import 'dart:async';

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
}
// vim: set ts=2 sw=2 sts=2 et:
