// The page to show and manage filters.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';

// The page to show the filters.
class Filters extends ConsumerStatefulWidget {
  const Filters({super.key});

  @override
  ConsumerState<Filters> createState() => _FiltersState();
}

class _FiltersState extends ConsumerState<Filters> {
  late final AccessStatusSchema? status = ref.read(accessStatusProvider);
  late final TextEditingController controller = TextEditingController();

  List<FiltersSchema> filters = [];

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
    return Column(
      children: [
        buildAddField(),
        Expanded(child: buildContent()),
      ],
    );
  }

  // Build the icon to add new filter.
  Widget buildAddField() {
    return ListTile(
      title: TextField(
        controller: controller,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
        ),
        onSubmitted: (_) => onCreate(),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.add, size: iconSize),
        onPressed: () => onCreate(),
      ),
    );
  }

  Widget buildContent() {
    if (filters.isEmpty) {
      return const NoResult();
    }

    return ListView.builder(
      itemCount: filters.length,
      itemBuilder: (context, index) {
        final FiltersSchema filter = filters[index];
        final Widget tile = ListTile(
          leading: Tooltip(
            message: filter.action.title(context),
            child: Icon(filter.action.icon, size: iconSize),
          ),
          title: Text(filter.title),
          onTap: () => context.push(RoutePath.editFilterForm.path, extra: filter),
        );

        return AccessibleDismissible(
          dismissKey: ValueKey(filter.id),
          dismissLabel: AppLocalizations.of(context)?.lbl_swipe_delete,
          background: Container(
            alignment: Alignment.centerLeft,
            color: Theme.of(context).colorScheme.error,
            child: Icon(Icons.delete_forever_rounded, color: Theme.of(context).colorScheme.onError),
          ),
          direction: DismissDirection.startToEnd,
          confirmDismiss: (_) async {
            final confirmed = await showConfirmDialog(
              context: context,
              title: AppLocalizations.of(context)?.txt_admin_confirm_action ?? 'Confirm',
              message: AppLocalizations.of(context)?.msg_confirm_delete_filter ?? 'Delete this filter?',
            );
            if (confirmed) onDelete(schema: filter);
            return false;
          },
          child: tile,
        );
      },
    );
  }

  Future<void> onLoad() async {
    final List<FiltersSchema> schemas = await status?.fetchFilters() ?? [];
    if (mounted) setState(() => filters = schemas);
  }

  Future<void> onCreate() async {
    await context.push(RoutePath.createFilterForm.path, extra: controller.text);
    controller.clear();
    await onLoad();
  }

  Future<void> onDelete({required FiltersSchema schema}) async {
    await status?.deleteFilter(id: schema.id);
    if (mounted) setState(() => filters.remove(schema));
  }
}

// vim: set ts=2 sw=2 sts=2 et:
