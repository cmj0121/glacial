// The relationship between accounts, such as following / blocking / muting / etc
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';

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
  late final AccessStatusSchema? status = ref.read(accessStatusProvider);

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
        buildRequest(),
        buildRelationship(),
        const SizedBox(width: 8),
        buildMoreActions(),
        const SizedBox(width: 8),
      ],
    );
  }

  // Build the more actions to interactive the account.
  Widget buildMoreActions() {
    return PopupMenuButton<Object>(
      icon: const Icon(Icons.more_horiz),
      tooltip: '',
      itemBuilder: (BuildContext context) {
        List<RelationshipType> actions = RelationshipType.values.where((r) => r.isMoreActions).toList();

        actions.remove(schema?.muting == true ? RelationshipType.mute : RelationshipType.unmute);
        actions.remove(schema?.blocking == true ? RelationshipType.block : RelationshipType.unblock);

        final String noteLabel = AppLocalizations.of(context)?.btn_relationship_note ?? "Personal note";
        final bool hasNote = schema?.note.isNotEmpty == true;
        final bool isEndorsed = schema?.endorsed == true;
        final String endorseLabel = isEndorsed
          ? (AppLocalizations.of(context)?.btn_relationship_unendorse ?? "Unfeature on profile")
          : (AppLocalizations.of(context)?.btn_relationship_endorse ?? "Feature on profile");

        return [
          PopupMenuItem<Object>(
            value: 'note',
            child: ListTile(
              leading: Icon(hasNote ? Icons.sticky_note_2 : Icons.sticky_note_2_outlined, size: size),
              title: Text(noteLabel),
              iconColor: hasNote ? Theme.of(context).colorScheme.tertiary : null,
              textColor: hasNote ? Theme.of(context).colorScheme.tertiary : null,
            ),
          ),
          PopupMenuItem<Object>(
            value: 'endorse',
            child: ListTile(
              leading: Icon(isEndorsed ? Icons.star : Icons.star_outline, size: size),
              title: Text(endorseLabel),
              iconColor: isEndorsed ? Theme.of(context).colorScheme.tertiary : null,
              textColor: isEndorsed ? Theme.of(context).colorScheme.tertiary : null,
            ),
          ),
          const PopupMenuDivider(),
          ...actions.map((RelationshipType action) {
            final bool disabled = action == RelationshipType.report;
            final Color? color = action.isDangerous ? Theme.of(context).colorScheme.error : null;

            return PopupMenuItem<Object>(
              value: action,
              enabled: !disabled,
              child: ListTile(
                leading: Icon(action.icon(), size: size),
                title: Text(action.tooltip(context, account: widget.schema)),
                iconColor: disabled ? null : color,
                textColor: disabled ? null : color,
              ),
            );
          }),
        ];
      },
      onSelected: (Object value) async {
        if (value == 'note') {
          onEditNote();
          return;
        }
        if (value == 'endorse') {
          onToggleEndorse();
          return;
        }
        if (value is RelationshipType) {
          if (value.isDangerous) {
            final l10n = AppLocalizations.of(context);
            final String message = value == RelationshipType.block
                ? (l10n?.msg_confirm_block(widget.schema.displayName) ?? 'Block this account?')
                : (l10n?.msg_confirm_mute(widget.schema.displayName) ?? 'Mute this account?');
            final confirmed = await showConfirmDialog(
              context: context,
              title: l10n?.txt_admin_confirm_action ?? 'Confirm',
              message: message,
            );
            if (!confirmed) return;
          }
          await status?.changeRelationship(account: widget.schema, type: value);
          onRefresh();
        }
      }
    );
  }

  // Show a dialog to edit the personal note for this account.
  Future<void> onEditNote() async {
    final TextEditingController controller = TextEditingController(text: schema?.note ?? '');
    final String title = AppLocalizations.of(context)?.btn_relationship_note ?? "Personal note";
    final String hint = AppLocalizations.of(context)?.desc_relationship_note ?? "Add a personal note about this account";

    final String? result = await showAdaptiveGlassDialog<String>(
      context: context,
      title: title,
      builder: (BuildContext context) {
        return TextField(
          controller: controller,
          maxLines: 4,
          autofocus: true,
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
          ),
        );
      },
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: Text(AppLocalizations.of(context)?.btn_close ?? "Close"),
        ),
        AdaptiveGlassButton(
          filled: true,
          onPressed: () => Navigator.of(context).pop(controller.text),
          child: Text(AppLocalizations.of(context)?.btn_save ?? "Save"),
        ),
      ],
    );

    controller.dispose();

    if (result != null) {
      await status?.setAccountNote(accountId: widget.schema.id, comment: result);
      onRefresh();
    }
  }

  // Toggle the endorse/unendorse state for this account.
  Future<void> onToggleEndorse() async {
    if (schema?.endorsed == true) {
      await status?.unendorseAccount(accountId: widget.schema.id);
    } else {
      await status?.endorseAccount(accountId: widget.schema.id);
    }
    onRefresh();
  }

  // Build the request button to show the request status if the account is not followed yet.
  Widget buildRequest() {
    Widget icon = Padding(
      padding: const EdgeInsets.only(right: 8),
      child: IconButton(
        icon: Icon(Icons.mark_email_unread_sharp, size: size),
        tooltip: AppLocalizations.of(context)?.btn_notification_follow_request ?? "Follow Request",
        style: IconButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () async {
          final String text = AppLocalizations.of(context)?.msg_follow_request(widget.schema.displayName) ?? "Follow request";
          showAdaptiveGlassDialog(
            context: context,
            title: text,
            builder: (BuildContext context) => const SizedBox.shrink(),
            actions: [
              TextButton.icon(
                label: Text(AppLocalizations.of(context)?.btn_follow_request_accept ?? "Accept"),
                icon: Icon(Icons.check, size: tabSize),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                ),
                onPressed: () async {
                  context.pop();
                  await status?.acceptFollowRequest(widget.schema.id);
                  onRefresh();
                }
              ),
              TextButton.icon(
                label: Text(AppLocalizations.of(context)?.btn_follow_request_reject ?? "Reject"),
                icon: Icon(Icons.close, size: tabSize),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                onPressed: () async {
                  context.pop();
                  await status?.rejectFollowRequest(widget.schema.id);
                  onRefresh();
                }
              ),
            ],
          );
        }
      ),
    );

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
      child: schema?.requestedBy == true ? icon : const SizedBox.shrink(),
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
  Future<void> onChangeRelationship() async {
    final AccessStatusSchema? status = ref.read(accessStatusProvider);
    await status?.changeRelationship(account: widget.schema, type: relationship);
    onRefresh();
  }

  // refresh the relationship state when the relationship is changed.
  Future<void> onRefresh() async {
    final AccessStatusSchema? status = ref.read(accessStatusProvider);
    final List<AccountSchema> accounts = [widget.schema];
    final List<RelationshipSchema> relationships = await status?.fetchRelationships(accounts) ?? [];

    if (mounted) setState(() => schema = relationships.firstOrNull);
  }

  RelationshipType get relationship => schema?.type ?? RelationshipType.stranger;
}

// vim: set ts=2 sw=2 sts=2 et:
