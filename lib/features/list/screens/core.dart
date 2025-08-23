// The account List widget that shows the grouped accounts of the a list timeline
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

// The list view to show the current list view.
class ListTimelineTab extends ConsumerStatefulWidget {
  const ListTimelineTab({super.key});

  @override
  ConsumerState<ListTimelineTab> createState() => _ListTimelineTabState();
}

class _ListTimelineTabState extends ConsumerState<ListTimelineTab> with TickerProviderStateMixin {
  late final AccessStatusSchema? status = ref.read(accessStatusProvider);
  late final TextEditingController controller = TextEditingController();

  bool loaded = false;
  List<ListSchema> lists = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => onLoad());
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildListField(),
          Flexible(child: buildListView()),
        ],
      ),
    );
  }

  // Build the input field to create a new list by name
  Widget buildListField() {
    return ListTile(
      title: TextField(
        controller: controller,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          hintText: AppLocalizations.of(context)?.desc_create_list ?? "Create a new list",
          hintStyle: TextStyle(color: Theme.of(context).colorScheme.outline),
        ),
        onSubmitted: (_) => onSubmitted(),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.playlist_add, size: iconSize),
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        onPressed: onSubmitted,
      ),
    );
  }

  // Show the list of the list timeline as labels and allow to remove them
  // by swiping them away.
  Widget buildListView() {
    if (lists.isEmpty) {
      final String message = AppLocalizations.of(context)?.txt_no_result ?? "No results found";
      return loaded ? NoResult(message: message, icon: Icons.coffee) : const ClockProgressIndicator();
    }

    return ListView.builder(
      itemCount: lists.length,
      itemBuilder: (context, index) => LiteTimeline.label(schema: lists[index], onRemove: () => onRemove(index)),
    );
  }

  void onSubmitted() async {
    final String name = controller.text.trim();
    if (name.isEmpty) return;

    await status?.createList(title: name);
    controller.clear();
    onLoad();
  }

  void onLoad() async {
    final List<ListSchema> lists = await status?.getLists() ?? [];
    setState(() {
      this.lists = lists;
      loaded = true;
    });
  }

  void onRemove(int index) async {
    if (index < 0 || index >= lists.length) return;

    final String id = lists[index].id;
    await status?.deleteList(id);
    setState(() => lists.removeAt(index));
  }
}

// The specified list view of the account group.
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
              hoverColor: Colors.transparent,
              focusColor: Colors.transparent,
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

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildHeader(),
        const Divider(),
        Flexible(
          child: Dismissible(
            key: UniqueKey(),
            direction: DismissDirection.startToEnd,
            child: showMembers ? buildMembers() : buildTimeline(),
            onDismissed: (_) => context.pop(),
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
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
          onPressed: () => setState(() => showMembers = !showMembers),
        ),
        IconButton(
          icon: Icon(schema.replyPolicy.icon, size: tabSize),
          tooltip: schema.replyPolicy.tooltip(context),
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
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
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
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
    return FutureBuilder(
      future: status?.getListAccounts(schema.id),
      builder: (context, AsyncSnapshot<List<AccountSchema>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Align(
            alignment: Alignment.topCenter,
            child: const ClockProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return NoResult();
        }

        final List<AccountSchema> accounts = snapshot.data ?? [];
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
                hoverColor: Colors.transparent,
                focusColor: Colors.transparent,
                onPressed: () async {
                  await status?.removeAccountsFromList(schema.id, [account.id]);
                  onReload();
                },
              ),
            );
          },
        );
      },
    );
  }

  // Pop-up the dialog and find the possibble accounts to add to the list.
  void onSearchAccount(String name) async {
    if (name.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: ListAccountWidget(
          name: name,
          onSelected: (account) async {
            await status?.addAccountsToList(schema.id, [account.id]);
            onReload();
          }
        ),
      ),
    );
  }

  void onReload() async {
    final ListSchema? schema = await status?.getList(this.schema.id);
    setState(() => this.schema = schema ?? this.schema);
  }
}

// The list account widget to show the possible accounts to add to the list.
class ListAccountWidget extends ConsumerStatefulWidget {
  final String name;
  final ValueChanged<AccountSchema>? onSelected;

  const ListAccountWidget({
    super.key,
    required this.name,
    this.onSelected,
  });

  @override
  ConsumerState<ListAccountWidget> createState() => _ListAccountWidgetState();
}

class _ListAccountWidgetState extends ConsumerState<ListAccountWidget> {
  late final AccessStatusSchema? status = ref.read(accessStatusProvider);

  bool isLoading = false;
  bool isCompleted = false;
  List<AccountSchema> accounts = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => onLoad());
  }

  @override
  Widget build(BuildContext context) {
    if (isCompleted && accounts.isEmpty) {
      final String message = AppLocalizations.of(context)?.txt_no_result ?? "No results found";
      return NoResult(message: message, icon: Icons.coffee);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isLoading) const ClockProgressIndicator(),
        Flexible(
          child: ListView.builder(
            itemCount: accounts.length,
            itemBuilder: (context, index) => AccountLite(
              schema: accounts[index],
              onTap: () => widget.onSelected?.call(accounts[index]),
            ),
          ),
        ),
      ],
    );
  }

  void onLoad() async {
    if (isLoading || isCompleted) return;

    setState(() => isLoading = true);

    final int count = this.accounts.length;
    final List<AccountSchema> accounts = await status?.searchAccounts(widget.name, offset: count, following: true) ?? [];

    setState(() {
      isLoading = false;
      isCompleted = accounts.isEmpty;
      this.accounts.addAll(accounts);
    });
  }
}

// vim: set ts=2 sw=2 sts=2 et:
