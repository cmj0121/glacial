// The User button to navigate to the sign-in page of the Master server.
import 'package:flutter/material.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';

// The Sign-In widget to navigate to the sign-in page of the Mastodon server.
class SignIn extends StatelessWidget {
  final AccessStatusSchema status;
  final double size;

  const SignIn({
    super.key,
    required this.status,
    this.size = 48.0,
  });

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
  }
}

// vim: set ts=2 sw=2 sts=2 et:
