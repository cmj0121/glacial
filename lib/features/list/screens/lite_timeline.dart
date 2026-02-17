// The specified list view of the account group.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

class LiteTimeline extends ConsumerStatefulWidget {
  final ListSchema schema;

  const LiteTimeline({
    super.key,
    required this.schema,
  });

  // Render the label of the list timeline, which is a ListTile with
  // the title of the list and a tap handler to navigate to the list timeline.
  static Widget label({required ListSchema schema, void Function()? onRemove}) {
    return LayoutBuilder(
      builder: (context, constraints) {
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

  late ListSchema schema = widget.schema;
  late bool showMembers = false;
  Future<List<AccountSchema>>? _membersFuture;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildHeader(),
        const Divider(),
        Flexible(
          child: AccessibleDismissible(
            dismissKey: UniqueKey(),
            direction: DismissDirection.startToEnd,
            dismissLabel: AppLocalizations.of(context)?.lbl_swipe_back,
            confirmDismiss: (_) async { context.pop(); return false; },
            child: showMembers ? buildMembers() : buildTimeline(),
          ),
        ),
      ],
    );
  }

  // Build the header of the list timeline, which includes the input field to add
  // a new account to the list and change the property of the current list.
  Widget buildHeader() {
    final Widget searchBar = TextField(
      decoration: InputDecoration(
        enabled: showMembers,
        border: InputBorder.none,
        hintText: AppLocalizations.of(context)?.desc_list_search_following ?? "Search following accounts to add",
        hintStyle: TextStyle(color: showMembers ? Theme.of(context).colorScheme.outline : Theme.of(context).colorScheme.surface),
      ),
      onSubmitted: (value) => onSearchAccount(value.trim()),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(flex: 10, child: searchBar),
        const Spacer(),
        IconButton(
          icon: Icon(
            showMembers ? Icons.group_add_sharp : Icons.group,
            size: tabSize,
            color: showMembers ? Theme.of(context).colorScheme.primary : null,
          ),
          onPressed: () => setState(() {
            showMembers = !showMembers;
            if (showMembers) _membersFuture = status?.getListAccounts(schema.id);
          }),
        ),
        IconButton(
          icon: Icon(schema.replyPolicy.icon, size: tabSize),
          tooltip: schema.replyPolicy.tooltip(context),
          onPressed: () async {
            final int index = ReplyPolicyType.values.indexOf(schema.replyPolicy);
            final int nextIndex = (index + 1) % ReplyPolicyType.values.length;
            await status?.updateList(id: schema.id, title: schema.title, replyPolicy: ReplyPolicyType.values[nextIndex]);
            onReload();
          }
        ),
        IconButton(
          icon: Icon(schema.exclusive ? Icons.remove_circle : Icons.check_circle, size: tabSize),
          tooltip: schema.exclusive ?
            AppLocalizations.of(context)?.txt_list_exclusive ?? "Exclusive List" :
            AppLocalizations.of(context)?.txt_list_inclusive ?? "Non-Exclusive List",
          onPressed: () async {
            await status?.updateList(id: schema.id, title: schema.title, exclusive: !schema.exclusive);
            onReload();
          }
        ),
      ],
    );
  }

  // Build the timeline of the list.
  Widget buildTimeline() {
    if (status == null) {
      logger.w("No server selected, but it's required to show the list timeline.");
      return const SizedBox.shrink();
    }

    return Timeline(type: TimelineType.list, status: status!, listId: schema.id);
  }

  // Build the list of the accounts in the list.
  Widget buildMembers() {
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
          final String message = AppLocalizations.of(context)?.txt_no_result ?? "No results found";
          return NoResult(message: message, icon: Icons.coffee);
        }

        return ListView.builder(
          itemCount: accounts.length,
          itemBuilder: (context, index) {
            final AccountSchema account = accounts[index];
            return ListTile(
              title: AccountLite(schema: account),
              trailing: IconButton(
                icon: Icon(Icons.delete_forever_rounded, size: tabSize, color: Theme.of(context).colorScheme.error),
                onPressed: () async {
                  await status?.removeAccountsFromList(schema.id, [account.id]);
                  if (mounted) setState(() => _membersFuture = status?.getListAccounts(schema.id));
                },
              ),
            );
          },
        );
      },
    );
  }

  // Pop-up the dialog and find the possibble accounts to add to the list.
  Future<void> onSearchAccount(String name) async {
    if (name.isEmpty) return;

    showAdaptiveGlassDialog(
      context: context,
      builder: (context) => ListAccountWidget(
        name: name,
        onSelected: (account) async {
          await status?.addAccountsToList(schema.id, [account.id]);
          onReload();
        }
      ),
    );
  }

  Future<void> onReload() async {
    final ListSchema? schema = await status?.getList(this.schema.id);
    if (mounted) setState(() => this.schema = schema ?? this.schema);
  }
}

// vim: set ts=2 sw=2 sts=2 et:
