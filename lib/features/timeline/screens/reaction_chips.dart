// The reaction chips row that displays emoji reactions on a status.
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';

// Displays emoji reaction chips for a status, with tap-to-toggle.
class ReactionChips extends ConsumerWidget {
  final StatusSchema schema;
  final ValueChanged<StatusSchema>? onReload;

  const ReactionChips({
    super.key,
    required this.schema,
    this.onReload,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (schema.reactions.isEmpty) return const SizedBox.shrink();

    final AccessStatusSchema? status = ref.read(accessStatusProvider);
    final bool isSignedIn = status?.accessToken?.isNotEmpty == true;

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: schema.reactions.map((r) => _ReactionChip(
          reaction: r,
          isSignedIn: isSignedIn,
          onToggle: () => _onToggle(ref, status, r),
        )).toList(),
      ),
    );
  }

  Future<void> _onToggle(WidgetRef ref, AccessStatusSchema? status, ReactionSchema reaction) async {
    if (status == null) return;

    try {
      final bool enabled = ref.read(preferenceProvider)?.hapticFeedback ?? true;
      if (enabled) HapticFeedback.lightImpact();

      final StatusSchema updated = reaction.me
          ? await status.removeStatusReaction(schema, reaction.name)
          : await status.addStatusReaction(schema, reaction.name);

      onReload?.call(updated);
    } catch (e) {
      logger.e('Failed to toggle reaction: $e');
    }
  }
}

class _ReactionChip extends StatelessWidget {
  final ReactionSchema reaction;
  final bool isSignedIn;
  final VoidCallback onToggle;

  const _ReactionChip({
    required this.reaction,
    required this.isSignedIn,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: reaction.url != null
          ? CachedNetworkImage(imageUrl: reaction.url!, width: 16, height: 16)
          : Text(reaction.name, style: const TextStyle(fontSize: 14)),
      label: Text('${reaction.count}'),
      backgroundColor: reaction.me ? Theme.of(context).colorScheme.primaryContainer : null,
      onPressed: isSignedIn ? onToggle : null,
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
