// The SignIn button to navigate to the sign-in page of the Master server.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/routes.dart';

// The Sign In widget is used to sign in to the Mastodon server.
class SignIn extends ConsumerStatefulWidget {
  final double size;

  const SignIn({
    super.key,
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
    final Uri uri = Uri.https("example.com");
    context.push(RoutePath.webview.path, extra: uri);
  }
}
// vim: set ts=2 sw=2 sts=2 et:
