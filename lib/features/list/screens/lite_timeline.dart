// The specified list view of the account group.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

enum _ListView { timeline, members }

class LiteTimeline extends ConsumerStatefulWidget {
  final ListSchema schema;

  const LiteTimeline({
    super.key,
    required this.schema,
  });

  // Back-compat label widget used by a few widget tests. New production
  // code uses the card-style row in ListTimelineTab instead.
  static Widget label({required ListSchema schema, void Function()? onRemove}) {
    return Builder(
      builder: (context) {
        final TextStyle? style = Theme.of(context).textTheme.labelLarge;
        return InkWellDone(
          onTap: () => context.push(RoutePath.listItem.path, extra: schema),
          child: ListTile(
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Tooltip(
                  message: schema.replyPolicy.tooltip(context),
                  child: Icon(schema.replyPolicy.icon, size: tabSize),
                ),
                const SizedBox(width: 8),
                Tooltip(
                  message: schema.exclusive ?
                    AppLocalizations.of(context)?.txt_list_exclusive ?? "Exclusive List" :
                    AppLocalizations.of(context)?.txt_list_inclusive ?? "Non-Exclusive List",
                  child: Icon(schema.exclusive ? Icons.remove_circle_outline : Icons.check_circle, size: tabSize),
                ),
              ],
            ),
            title: Text(schema.title, style: style, overflow: TextOverflow.ellipsis),
            trailing: IconButton(
              icon: Icon(Icons.delete_forever_rounded, size: tabSize, color: Theme.of(context).colorScheme.error),
              onPressed: onRemove,
            ),
          ),
        );
      },
    );
  }

  @override
  ConsumerState<LiteTimeline> createState() => _LiteTimelineState();
}

class _LiteTimelineState extends ConsumerState<LiteTimeline> {
  late final AccessStatusSchema? status = ref.read(accessStatusProvider);
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  late ListSchema schema = widget.schema;
  _ListView _view = _ListView.timeline;
  Future<List<AccountSchema>>? _membersFuture;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(context),
        Flexible(
          child: AccessibleDismissible(
            dismissKey: UniqueKey(),
            direction: DismissDirection.startToEnd,
            dismissLabel: AppLocalizations.of(context)?.lbl_swipe_back,
            confirmDismiss: (_) async { context.pop(); return false; },
            child: _view == _ListView.members ? _buildMembers() : _buildTimeline(),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final AppLocalizations? l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: SegmentedButton<_ListView>(
                  segments: <ButtonSegment<_ListView>>[
                    ButtonSegment(
                      value: _ListView.timeline,
                      icon: const Icon(Icons.dynamic_feed_rounded, size: 18),
                      label: Text(l10n?.btn_list_timeline ?? 'Timeline'),
                    ),
                    ButtonSegment(
                      value: _ListView.members,
                      icon: const Icon(Icons.group_rounded, size: 18),
                      label: Text(l10n?.btn_list_members ?? 'Members'),
                    ),
                  ],
                  selected: {_view},
                  showSelectedIcon: false,
                  style: ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onSelectionChanged: (selected) {
                    setState(() {
                      _view = selected.first;
                      if (_view == _ListView.members && _membersFuture == null) {
                        _membersFuture = status?.getListAccounts(schema.id);
                      }
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.tune_rounded, size: 22),
                tooltip: l10n?.txt_list_settings ?? 'List settings',
                onPressed: _openSettingsSheet,
              ),
            ],
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            child: _view == _ListView.members
                ? Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocus,
                      decoration: InputDecoration(
                        hintText: l10n?.desc_list_search_following ?? 'Search following accounts to add',
                        isDense: true,
                        prefixIcon: Icon(Icons.person_search_rounded, size: 20, color: scheme.primary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: scheme.outlineVariant),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: scheme.outlineVariant),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: scheme.primary, width: 1.5),
                        ),
                      ),
                      onSubmitted: (value) => _onSearchAccount(value.trim()),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    if (status == null) {
      logger.w("No server selected, but it's required to show the list timeline.");
      return const SizedBox.shrink();
    }
    return Timeline(type: TimelineType.list, status: status!, listId: schema.id);
  }

  Widget _buildMembers() {
    return FutureBuilder<List<AccountSchema>>(
      future: _membersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingOverlay(isLoading: true, child: SizedBox.expand());
        } else if (snapshot.hasError || snapshot.data == null) {
          return const NoResult();
        }

        final List<AccountSchema> accounts = snapshot.data!;
        if (accounts.isEmpty) {
          final String message = AppLocalizations.of(context)?.txt_no_result ?? 'No results found';
          return NoResult(message: message, icon: Icons.coffee);
        }

        return ListView.separated(
          padding: EdgeInsets.zero,
          itemCount: accounts.length,
          separatorBuilder: (_, _) => Divider(
            height: 1,
            thickness: 1,
            color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
          itemBuilder: (context, index) {
            final AccountSchema account = accounts[index];
            return AccessibleDismissible(
              dismissKey: ValueKey('member_${account.id}'),
              direction: DismissDirection.endToStart,
              dismissLabel: AppLocalizations.of(context)?.lbl_swipe_remove,
              background: _removeBackground(context),
              secondaryBackground: _removeBackground(context),
              onDismissed: (_) async {
                await status?.removeAccountsFromList(schema.id, [account.id]);
                if (mounted) setState(() => _membersFuture = status?.getListAccounts(schema.id));
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: AccountLite(schema: account),
              ),
            );
          },
        );
      },
    );
  }

  Widget _removeBackground(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      color: scheme.errorContainer,
      child: Icon(Icons.person_remove_rounded, color: scheme.onErrorContainer, size: 22),
    );
  }

  Future<void> _openSettingsSheet() async {
    await showAdaptiveGlassSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _ListSettingsSheet(
        schema: schema,
        onReplyPolicyChanged: (policy) async {
          await status?.updateList(id: schema.id, title: schema.title, replyPolicy: policy);
          await _reload();
        },
        onExclusiveChanged: (value) async {
          await status?.updateList(id: schema.id, title: schema.title, exclusive: value);
          await _reload();
        },
      ),
    );
  }

  Future<void> _onSearchAccount(String name) async {
    if (name.isEmpty) return;
    showAdaptiveGlassDialog(
      context: context,
      builder: (context) => ListAccountWidget(
        name: name,
        onSelected: (account) async {
          await status?.addAccountsToList(schema.id, [account.id]);
          _searchController.clear();
          setState(() => _membersFuture = status?.getListAccounts(schema.id));
        }
      ),
    );
  }

  Future<void> _reload() async {
    final ListSchema? next = await status?.getList(schema.id);
    if (mounted && next != null) setState(() => schema = next);
  }
}

class _ListSettingsSheet extends StatefulWidget {
  final ListSchema schema;
  final Future<void> Function(ReplyPolicyType) onReplyPolicyChanged;
  final Future<void> Function(bool) onExclusiveChanged;

  const _ListSettingsSheet({
    required this.schema,
    required this.onReplyPolicyChanged,
    required this.onExclusiveChanged,
  });

  @override
  State<_ListSettingsSheet> createState() => _ListSettingsSheetState();
}

class _ListSettingsSheetState extends State<_ListSettingsSheet> {
  late ReplyPolicyType _policy = widget.schema.replyPolicy;
  late bool _exclusive = widget.schema.exclusive;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final AppLocalizations? l10n = AppLocalizations.of(context);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n?.txt_list_settings ?? 'List settings',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Container(
              width: 32,
              height: 2,
              decoration: BoxDecoration(
                color: scheme.primary,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
            const SizedBox(height: 24),
            _sectionLabel(context, l10n?.txt_list_reply_policy ?? 'Reply policy'),
            const SizedBox(height: 10),
            ...ReplyPolicyType.values.map((policy) {
              final bool selected = policy == _policy;
              return InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: selected ? null : () async {
                  setState(() => _policy = policy);
                  await widget.onReplyPolicyChanged(policy);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                  child: Row(
                    children: [
                      Icon(
                        selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                        size: 20,
                        color: selected ? scheme.primary : scheme.outline,
                      ),
                      const SizedBox(width: 12),
                      Icon(policy.icon, size: 18, color: scheme.onSurfaceVariant),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(policy.label(context), style: theme.textTheme.bodyMedium),
                            Text(
                              policy.tooltip(context),
                              style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
            _sectionLabel(context, l10n?.txt_list_exclusivity ?? 'Home feed'),
            const SizedBox(height: 6),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _exclusive,
              title: Text(
                _exclusive
                    ? l10n?.txt_list_short_exclusive ?? 'Exclusive'
                    : l10n?.txt_list_short_inclusive ?? 'Inclusive',
                style: theme.textTheme.bodyMedium,
              ),
              subtitle: Text(
                _exclusive
                    ? l10n?.desc_list_exclusive_on ?? "Hide members' posts from Home timeline"
                    : l10n?.desc_list_exclusive_off ?? "Show members' posts on Home timeline",
                style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
              onChanged: (value) async {
                setState(() => _exclusive = value);
                await widget.onExclusiveChanged(value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String text) {
    final ThemeData theme = Theme.of(context);
    return Text(
      text.toUpperCase(),
      style: theme.textTheme.labelSmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
