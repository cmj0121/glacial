// Profile extras: familiar followers and featured tags widgets.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

// Show the familiar followers (people you follow who also follow this account).
class FamiliarFollowers extends ConsumerStatefulWidget {
  final AccountSchema schema;
  final double avatarSize;

  const FamiliarFollowers({
    super.key,
    required this.schema,
    this.avatarSize = 24,
  });

  @override
  ConsumerState<FamiliarFollowers> createState() => _FamiliarFollowersState();
}

class _FamiliarFollowersState extends ConsumerState<FamiliarFollowers> {
  late final AccessStatusSchema? status = ref.read(accessStatusProvider);

  List<AccountSchema> accounts = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => onLoad());
  }

  @override
  Widget build(BuildContext context) {
    if (accounts.isEmpty) return const SizedBox.shrink();

    final String label = AppLocalizations.of(context)?.txt_familiar_followers ?? "Also followed by";

    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 4),
      child: Row(
        children: [
          ...accounts.take(5).map((a) => Padding(
            padding: const EdgeInsets.only(right: 4),
            child: AccountAvatar(schema: a, size: widget.avatarSize),
          )),
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).disabledColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> onLoad() async {
    if (status?.isSignedIn != true) return;

    final List<AccountSchema> result = await status?.fetchFamiliarFollowers(
      accountId: widget.schema.id,
    ) ?? [];

    if (mounted) setState(() => accounts = result);
  }
}

// Show the featured hashtags on a user's profile.
class FeaturedTags extends ConsumerStatefulWidget {
  final AccountSchema schema;

  const FeaturedTags({super.key, required this.schema});

  @override
  ConsumerState<FeaturedTags> createState() => _FeaturedTagsState();
}

class _FeaturedTagsState extends ConsumerState<FeaturedTags> {
  late final AccessStatusSchema? status = ref.read(accessStatusProvider);

  List<FeaturedTagSchema> tags = [];

  bool get isSelf => widget.schema.id == status?.account?.id;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => onLoad());
  }

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty && !isSelf) return const SizedBox.shrink();

    final String label = AppLocalizations.of(context)?.txt_featured_tags ?? "Featured tags";

    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (tags.isNotEmpty) Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).disabledColor),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              ...tags.map((tag) => InputChip(
                label: Text('#${tag.name}'),
                deleteIcon: isSelf ? const Icon(Icons.close, size: 16) : null,
                onDeleted: isSelf ? () => onRemove(tag) : null,
                onPressed: () => context.push(RoutePath.hashtag.path, extra: tag.name),
              )),
              if (isSelf) ActionChip(
                avatar: const Icon(Icons.add, size: 16),
                label: Text(label),
                onPressed: onAdd,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> onLoad() async {
    final List<FeaturedTagSchema> result = await status?.fetchAccountFeaturedTags(
      accountId: widget.schema.id,
    ) ?? [];

    if (mounted) setState(() => tags = result);
  }

  Future<void> onAdd() async {
    final TextEditingController controller = TextEditingController();
    final String? name = await showAdaptiveGlassDialog<String>(
      context: context,
      title: AppLocalizations.of(context)?.txt_featured_tags ?? "Featured tags",
      builder: (context) => TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(
          prefixText: '#',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context)?.btn_close ?? "Close"),
        ),
        AdaptiveGlassButton(
          filled: true,
          onPressed: () => Navigator.of(context).pop(controller.text.trim()),
          child: Text(AppLocalizations.of(context)?.btn_save ?? "Save"),
        ),
      ],
    );
    controller.dispose();

    if (name != null && name.isNotEmpty && mounted) {
      await status?.featureTag(name);
      if (mounted) await onLoad();
    }
  }

  Future<void> onRemove(FeaturedTagSchema tag) async {
    setState(() => tags.removeWhere((t) => t.id == tag.id));
    await status?.unfeatureTag(tag.id);
  }
}

// vim: set ts=2 sw=2 sts=2 et:
