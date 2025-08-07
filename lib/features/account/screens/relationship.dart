// The account relationship widget to show the relationship between two accounts.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';

// The relationship between accounts, such as following / blocking / muting / etc
class Relationship extends ConsumerStatefulWidget {
  final AccountSchema schema;

  const Relationship({
    super.key,
    required this.schema,
  });

  @override
  ConsumerState<Relationship> createState() => _RelationshipState();
}

class _RelationshipState extends ConsumerState<Relationship> {
  final double size = tabSize;

  RelationshipSchema? schema;

  @override
  void initState() {
    super.initState();
    onRefresh();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        buildMoreActions(),
        const SizedBox(width: 8),
        buildRelationship(),
        const SizedBox(width: 8),
      ],
    );
  }

  // Build the more actions to interactive the account.
  Widget buildMoreActions() {
    return PopupMenuButton(
      icon: const Icon(Icons.more_horiz),
      tooltip: '',
      itemBuilder: (BuildContext context) {
        List<RelationshipType> actions = RelationshipType.values.where((r) => r.isMoreActions).toList();

        actions.remove(schema?.muting == true ? RelationshipType.mute : RelationshipType.unmute);
        actions.remove(schema?.blocking == true ? RelationshipType.block : RelationshipType.unblock);

        return actions.map((RelationshipType action) {
          final bool disabled = action == RelationshipType.report;
          final Color? color = action.isDangerous ? Theme.of(context).colorScheme.error : null;

          return PopupMenuItem(
            value: action,
            enabled: !disabled,
            child: ListTile(
              leading: Icon(action.icon(), size: size),
              title: Text(action.tooltip(context, account: widget.schema)),
              iconColor: disabled ? null : color,
              textColor: disabled ? null : color,
            ),
          );
        }).toList();
      },
      onSelected: (RelationshipType r) async {
        final AccessStatusSchema? status = ref.read(accessStatusProvider);
        await status?.changeRelationship(account: widget.schema, type: r);
        onRefresh();
      }
    );
  }

  // Build the relationship type icon and switch the relationship type when tapped.
  Widget buildRelationship() {
    final bool disabled = relationship == RelationshipType.blockedBy;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(animation),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      child: IconButton(
        key: ValueKey('${widget.schema.id}-${relationship.name}'),
        icon: Icon(relationship.icon(), size: size),
        tooltip: relationship.tooltip(context, account: widget.schema),
        style: IconButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: disabled ? null : onChangeRelationship,
      ),
    );
  }

  // Switch the relationship type when tapped.
  void onChangeRelationship() async {
    final AccessStatusSchema? status = ref.read(accessStatusProvider);
    await status?.changeRelationship(account: widget.schema, type: relationship);
    onRefresh();
  }

  // refresh the relationship state when the relationship is changed.
  void onRefresh() async {
    final AccessStatusSchema? status = ref.read(accessStatusProvider);
    final List<AccountSchema> accounts = [widget.schema];
    final List<RelationshipSchema> relationships = await status?.fetchRelationships(accounts) ?? [];

    setState(() => schema = relationships.firstOrNull);
  }

  RelationshipType get relationship => schema?.type ?? RelationshipType.stranger;
}

// vim: set ts=2 sw=2 sts=2 et:
