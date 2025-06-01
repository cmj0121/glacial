// The self-profile feature's screens.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';

class UserProfileBuilder extends StatelessWidget {
  const UserProfileBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    final String text = AppLocalizations.of(context)?.btn_edit_profile ?? "Edit Profile";

    return IconButton(
      onPressed: () => context.push(RoutePath.userProfile.path),
      style: IconButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      icon: const Icon(Icons.edit_note_rounded),
      tooltip: text,
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
