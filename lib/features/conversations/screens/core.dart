// The Conversation list screen for direct messages.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';

// The conversation tab that shows the list of direct message conversations.
class ConversationTab extends ConsumerStatefulWidget {
  const ConversationTab({super.key});

  @override
  ConsumerState<ConversationTab> createState() => _ConversationTabState();
}

class _ConversationTabState extends ConsumerState<ConversationTab> {
  @override
  Widget build(BuildContext context) {
    final AccessStatusSchema? status = ref.read(accessStatusProvider);

    if (status?.isSignedIn != true) {
      return const SizedBox.shrink();
    }

    return Center(
      child: NoResult(
        message: AppLocalizations.of(context)?.txt_no_conversations ?? "No conversations",
        icon: Icons.mail_outline,
      ),
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
