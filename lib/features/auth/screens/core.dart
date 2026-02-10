// The User button to navigate to the sign-in page of the Master server.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';

export 'register.dart';

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
    final AccessStatusSchema? status = ref.read(accessStatusProvider);
    final bool registrationEnabled = status?.server?.registration.enabled ?? false;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.filledTonal(
          icon: const Icon(Icons.person_outline),
          tooltip: AppLocalizations.of(context)?.btn_sidebar_sign_in ?? 'Sign In',
          color: Theme.of(context).colorScheme.onPrimaryContainer,
          onPressed: onSignIn,
        ),
        if (registrationEnabled) ...[
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => context.push(RoutePath.register.path),
            child: Text(
              AppLocalizations.of(context)?.btn_register ?? 'Create Account',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ],
    );
  }

  // Get the register application and navigate to the sign-in page based on the
  // current selected Mastodon server.
  Future<void> onSignIn() async {
    final AccessStatusSchema? status = ref.read(accessStatusProvider);
    final String? domain = status?.domain;

    if (status == null || domain == null || domain.isEmpty) {
      logger.w("No Mastodon server selected, cannot sign in.");
      return;
    }

    final Uri uri = await status.authorize(domain: domain, state: state);
    if (mounted) {
      context.push(RoutePath.webview.path, extra: uri);
    }
  }
}

// vim: set ts=2 sw=2 sts=2 et:
