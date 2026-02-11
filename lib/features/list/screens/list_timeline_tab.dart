// The list view to show the current list view.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

import 'package:glacial/features/list/screens/lite_timeline.dart';

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
  void dispose() {
    controller.dispose();
    super.dispose();
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

  Future<void> onSubmitted() async {
    final String name = controller.text.trim();
    if (name.isEmpty) return;

    await status?.createList(title: name);
    controller.clear();
    onLoad();
  }

  Future<void> onLoad() async {
    final List<ListSchema> lists = await status?.getLists() ?? [];
    if (mounted) {
      setState(() {
        this.lists = lists;
        loaded = true;
      });
    }
  }

  Future<void> onRemove(int index) async {
    if (index < 0 || index >= lists.length) return;

    final String id = lists[index].id;
    await status?.deleteList(id);
    if (mounted) setState(() => lists.removeAt(index));
  }
}

// vim: set ts=2 sw=2 sts=2 et:
