// The filter selector to add a status to a filtered list.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';

// The filter selector to add the status in the filtered list.
class FilterSelector extends ConsumerStatefulWidget {
  final StatusSchema status;
  final ValueChanged<FiltersSchema>? onSelected;
  final ValueChanged<FiltersSchema>? onDeleted;

  const FilterSelector({
    super.key,
    required this.status,
    this.onSelected,
    this.onDeleted,
  });

  @override
  ConsumerState<FilterSelector> createState() => _FilterSelectorState();
}

class _FilterSelectorState extends ConsumerState<FilterSelector> {
  List<FiltersSchema> filters = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => onLoad());
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: buildContent(),
    );
  }

  Widget buildContent() {
    final String text = AppLocalizations.of(context)?.txt_filter_title ?? "Select a filter to apply";

    return Column(
      children: [
        Text(text, style: Theme.of(context).textTheme.titleSmall),
        const Divider(),
        ...filters.map((filter) => buildItem(filter)),
      ],
    );
  }

  Widget buildItem(FiltersSchema filter) {
    final String text = AppLocalizations.of(context)?.txt_filter_applied ?? "Filter already applied";
    final bool isSelected = widget.status.filtered?.any((result) => result.filter.id == filter.id) ?? false;
    final TextStyle? style = Theme.of(context).textTheme.labelMedium?.copyWith(color: Theme.of(context).disabledColor);

    return ListTile(
      leading: Tooltip(
        message: filter.action.title(context),
        child: Icon(filter.action.icon, size: iconSize),
      ),
      title: Text(filter.title),
      subtitle: isSelected ? Text(text, style: style) : null,
      onTap: () => isSelected ? widget.onDeleted?.call(filter) : widget.onSelected?.call(filter),
    );
  }

  Future<void> onLoad() async {
    final AccessStatusSchema? status = ref.read(accessStatusProvider);
    final List<FiltersSchema> schemas = await status?.fetchFilters() ?? [];

    if (mounted)  setState(() => filters = schemas);
  }
}

// vim: set ts=2 sw=2 sts=2 et:
