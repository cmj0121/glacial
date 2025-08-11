// The User button to navigate to the sign-in page of the Master server.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';

// The Sign-In widget to navigate to the sign-in page of the Mastodon server.
class SignIn extends ConsumerStatefulWidget {
  final double size;

  const SignIn({
    super.key,
    this.size = 48.0,
  });

  @override
  ConsumerState<SignIn> createState() => _SignInState();
}

class _SignInState extends ConsumerState<SignIn> {
  late final String state = const Uuid().v4();

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      icon: const Icon(Icons.person_outline),
      tooltip: AppLocalizations.of(context)?.btn_sidebar_sign_in ?? 'Sign In',
      color: Theme.of(context).colorScheme.onPrimaryContainer,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      onPressed: onSignIn,
    );
  }

  // Get the register application and navigate to the sign-in page based on the
  // current selected Mastodon server.
  void onSignIn() async {
    final AccessStatusSchema? status = ref.read(accessStatusProvider);
    final String? domain = status?.domain;

    if (domain == null || domain.isEmpty) {
      logger.w("No Mastodon server selected, cannot sign in.");
      return;
    }

    final Storage storage = Storage();
    final OAuth2Info info = await storage.getOAuth2Info(domain);
    final Map<String, dynamic> query = {
      "client_id": info.clientId,
      "response_type": "code",
      "scope": info.scopes.join(" "),
      "redirect_uri": info.redirectUri,
      "state": state,
    }
        ..removeWhere((key, value) => value == null);

    storage.saveStateServer(state, domain);

    if (mounted) {
      final Uri uri = UriEx.handle(domain, "/oauth/authorize", query);
      context.push(RoutePath.webview.path, extra: uri);
    }
  }
}

// vim: set ts=2 sw=2 sts=2 et:
