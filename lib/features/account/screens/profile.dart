// The self-profile feature's screens.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';

class UserProfileBuilder extends StatelessWidget {
  const UserProfileBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    final String text = AppLocalizations.of(context)?.btn_edit_profile ?? "Edit Profile";

    return TextButton.icon(
      onPressed: () => context.push(RoutePath.userProfile.path),
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.all<Color>(Theme.of(context).colorScheme.onSurface),
        backgroundColor: WidgetStateProperty.all<Color>(Theme.of(context).colorScheme.inversePrimary),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
      icon: const Icon(Icons.edit_note_rounded),
      label: Text(text),
    );
  }
}

class UserProfile extends ConsumerWidget {
  const UserProfile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Text("profile"),
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
