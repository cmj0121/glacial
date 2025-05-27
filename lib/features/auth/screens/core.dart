// The User button to navigate to the sign-in page of the Master server, or show
// the user profile page if already signed in.
import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/auth/models/oauth.dart';
import 'package:glacial/features/glacial/models/server.dart';
import 'package:glacial/features/timeline/models/core.dart';

// The Sign In widget is used to sign in to the Mastodon server.
class UserAvatar extends ConsumerStatefulWidget {
  final ServerSchema schema;
  final double size;

  const UserAvatar({
    super.key,
    required this.schema,
    this.size = 28,
  });

  @override
  ConsumerState<UserAvatar> createState() => _UserAvatarState();
}

class _UserAvatarState extends ConsumerState<UserAvatar> {
  final Storage storage = Storage();
  final Debouncer debouncer = Debouncer();

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
    final String? accessToken = ref.watch(currentAccessTokenProvider);

    return IconButton(
      icon: buildAvatar(accessToken),
      onPressed: accessToken == null ? () => debouncer.call(onSignIn) : null,
    );
  }

  Widget buildAvatar(String? accessToken) {
    final ServerSchema? schema = ref.read(currentServerProvider);

    if (accessToken == null || schema == null) {
      return Icon(Icons.help_outlined, size: widget.size);
    }

    final AccountSchema? account = ref.watch(currentUserProvider);
    return account == null ? Icon(Icons.error, size: widget.size) : buildUserAvatar(account);
  }

  // Build the user avartar with the size of the widget.
  Widget buildUserAvatar(AccountSchema account) {
    return InkWellDone(
      onTap: () => context.push(RoutePath.userProfile.path, extra: account),
      onDoubleTap: onSignOut,
      child: ClipOval(
        child: CachedNetworkImage(
          width: widget.size,
          height: widget.size,
          imageUrl: account.avatar,
          placeholder: (context, url) => const SizedBox.shrink(),
          errorWidget: (context, url, error) => const Icon(Icons.error),
          fit: BoxFit.cover,
        ),
      ),
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

    storage.saveToOAuthState(state, widget.schema);
    if (mounted) {
      final Uri uri = UriEx.handle(widget.schema.domain, "/oauth/authorize", query);
      context.push(RoutePath.webview.path, extra: uri);
    }
  }

  // The sign-up button is pressed, clean-up the authorization code and
  // refresh the page.
  void onSignOut() async {
    final DateTime now = DateTime.now();
    final ServerSchema? schema = ref.read(currentServerProvider);

    if (schema == null) {
      logger.w("expected: schema, got: $schema");
      return;
    }

    storage.saveAccessToken(schema.domain, null);
    ref.read(currentAccessTokenProvider.notifier).state = null;
    ref.read(currentUserProvider.notifier).state = null;
    if (mounted) {
      logger.i("sign out and clean up the access token");
      context.go(RoutePath.timeline.path, extra: now);
    }
  }
}

// vim: set ts=2 sw=2 sts=2 et:
