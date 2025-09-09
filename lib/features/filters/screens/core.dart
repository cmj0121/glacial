// Create and manage filters.
import 'package:flutter/material.dart';
import 'package:duration/duration.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';

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
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        onPressed: () => onCreate(),
      ),
    );
  }

  Widget buildContent() {
    if (filters.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListView.builder(
      itemCount: filters.length,
      itemBuilder: (context, index) {
        final FiltersSchema filter = filters[index];

        return ListTile(
          leading: Tooltip(
            message: filter.action.title(context),
            child: Icon(filter.action.icon, size: iconSize),
          ),
          title: Text(filter.title),
        );
      },
    );
  }

  Future<void> onLoad() async {
    final List<FiltersSchema> schemas = await status?.fetchFilters() ?? [];
    setState(() => filters = schemas);
  }

  void onCreate() async {
    await context.push(RoutePath.filterForm.path, extra: controller.text);
    controller.clear();
    await onLoad();
  }
}

class FiltersForm extends ConsumerStatefulWidget {
  final String title;

  const FiltersForm({
    super.key,
    required this.title,
  });

  @override
  ConsumerState<FiltersForm> createState() => _FiltersFormState();
}

class _FiltersFormState extends ConsumerState<FiltersForm> {
  late FilterFormSchema form = FilterFormSchema.fromTitle(widget.title);
  late FilterKeywordFormSchema keyword = FilterKeywordFormSchema.empty();

  late final FocusNode focusNode = FocusNode();
  late final TextEditingController controller = TextEditingController();
  late final TextEditingController titleController = TextEditingController(text: widget.title);
  late final TextStyle? subStyle = Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).disabledColor);

  final List<Duration?> durations = [
    null,
    const Duration(minutes: 30),
    const Duration(hours: 1),
    const Duration(hours: 6),
    const Duration(hours: 12),
    const Duration(days: 1),
    const Duration(days: 7),
  ];

  @override
  void dispose() {
    focusNode.dispose();
    controller.dispose();
    titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(flex: 10, child: buildContent()),
          const Spacer(),
          buildSubmitButton(),
        ],
      ),
    );
  }

  Widget buildContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          buildTitle(),
          buildAction(),
          buildExpiration(),
          buildContexts(),

          ...form.keywords.asMap().entries.map((entry) => FilterKeywordForm(
            key: UniqueKey(),
            schema: entry.value,
            onChanged: (item) {
              final List<FilterKeywordFormSchema> updated = List.from(form.keywords);
              updated[entry.key] = item;
              setState(() => form = form.copyWith(keywords: updated));
            },
            onDelete: () {
              List<FilterKeywordFormSchema> updated = List.from(form.keywords);
              updated.removeAt(entry.key);
              setState(() => form = form.copyWith(keywords: updated));
            },
          )),

          // The new keyword item.
          FilterKeywordForm(
            key: UniqueKey(),
            schema: keyword,
            focusNode: focusNode,
            onChanged: (item) {
              final List<FilterKeywordFormSchema> updated = List.from(form.keywords)..add(item);

              setState((){
                form = form.copyWith(keywords: updated);
                keyword = FilterKeywordFormSchema.empty();
              });
              focusNode.requestFocus();
            }
          ),
        ],
      ),
    );
  }

  // The editable title field.
  Widget buildTitle() {
    return Focus(
      onFocusChange: (hasFocus) {
        if (!hasFocus) {
          setState(() => form = form.copyWith(title: titleController.text));
        }
      },
      child: ListTile(
        leading: Tooltip(
          message: "Filter name",
          child: Icon(Icons.text_fields_outlined, size: iconSize),
        ),
        title: TextField(
          controller: titleController,
          style: Theme.of(context).textTheme.titleMedium,
          decoration: InputDecoration(border: InputBorder.none),
          onSubmitted: (String value) => form = form.copyWith(title: value),
        ),
        subtitle: Text("The name of the filter", style: subStyle),
      ),
    );
  }

  // The action to the filter.
  Widget buildAction() {
    return ListTile(
      leading: Tooltip(
        message: "Action",
        child: Icon(form.action.icon, size: iconSize),
      ),
      title: Text(form.action.title(context)),
      subtitle: Text(form.action.desc(context), style: subStyle),
      onTap: () {
        final int index = FilterAction.values.indexOf(form.action);
        final int next = (index + 1) % FilterAction.values.length;
        setState(() => form = form.copyWith(action: FilterAction.values[next]));
      },
    );
  }

  // The expiration time of the filter.
  Widget buildExpiration() {
    final int index = durations.indexWhere((d) => d?.inSeconds == form.expiresIn);

    return ListTile(
      leading: Tooltip(
        message: "Expiration",
        child: Icon(Icons.schedule_outlined, size: iconSize),
      ),
      title: Text(durations[index] == null ? "Never" : "In ${durations[index]?.pretty()}"),
      subtitle: Text("When the filter will expire", style: subStyle),
      onTap: () {
        final int next = (index + 1) % durations.length;
        setState(() => form = form.copyWith(expiresIn: durations[next]?.inSeconds ?? 0));
       },
    );
  }

  // Build the optional field for applying the filter to specific contexts.
  Widget buildContexts() {
    final List<FilterContext> contexts = FilterContext.values;
    final Widget chips = Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: contexts.map((item) {
      final bool selected = form.context.contains(item);
        return FilterChip(
          label: Text(item.title(context), overflow: TextOverflow.ellipsis),
          tooltip: item.tooltip(context),
          selected: selected,
          avatar: const SizedBox.shrink(),
          selectedColor: Theme.of(context).colorScheme.primaryContainer,
          onSelected: (bool value) {
            final List<FilterContext> updated = List.from(form.context);
            value ? updated.add(item) : updated.remove(item);
            setState(() => form = form.copyWith(context: updated));
          },
        );
      }).toList(),
    );

    return ListTile(
      leading: Tooltip(
        message: "Contexts",
        child: Icon(Icons.ballot_rounded, size: iconSize),
      ),
      title: chips,
      subtitle: Text("Where the filter should be applied", style: subStyle),
    );
  }

  // Build the submit button that can post the status or schedule the post.
  Widget buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        icon: Icon(Icons.save_outlined, size: iconSize),
        label: Text("Save Filter"),
        onPressed: canSubmit() ? onSubmit : null,
      ),
    );
  }

  // Check the form can be submitted.
  bool canSubmit() {
    return form.context.isNotEmpty;
  }

  void onSubmit() async {
    final AccessStatusSchema? status = ref.read(accessStatusProvider);
    status?.createFilter(schema: form);

    if (mounted && context.canPop())  context.pop();
  }
}

class FilterKeywordForm extends StatefulWidget {
  final FilterKeywordFormSchema schema;
  final FocusNode? focusNode;
  final TextEditingController? controller;
  final ValueChanged<FilterKeywordFormSchema>? onChanged;
  final VoidCallback? onDelete;

  const FilterKeywordForm({
    super.key,
    required this.schema,
    this.focusNode,
    this.controller,
    this.onChanged,
    this.onDelete,
  });

  @override
  State<FilterKeywordForm> createState() => _FilterKeywordFormState();
}

class _FilterKeywordFormState extends State<FilterKeywordForm> {
  late FilterKeywordFormSchema item = widget.schema;
  late final TextEditingController controller = widget.controller ?? TextEditingController(text: widget.schema.keyword);

  @override
  void dispose() {
    if(widget.controller == null) controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool whole = item.wholeWord;
    final bool deletable = widget.onDelete != null;

    return ListTile(
      leading: Tooltip(
        message: whole ? "Whole word" : "Partial match",
        child: Icon(whole ? Icons.code_outlined : Icons.code_off_outlined, size: iconSize),
      ),
      title: TextField(
        controller: controller,
        focusNode: widget.focusNode,
        decoration: InputDecoration(border: const OutlineInputBorder()),
        onSubmitted: (value) => onSave(),
      ),
      trailing: IconButton(
        icon: Icon(
          deletable ? Icons.delete_outline : Icons.add,
          size: iconSize,
          color: deletable ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.primary,
        ),
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        onPressed: deletable ? widget.onDelete : onSave,
      ),
      onTap: () => setState(() => item = item.copyWith(wholeWord: !item.wholeWord)),
    );
  }

  // Save the current value to the item and notify the parent widget.
  void onSave() {
    final String value = controller.text.trim();
    if (value.isEmpty) return;

    setState(() => item = item.copyWith(keyword: value));
    widget.onChanged?.call(item);
  }
}

// vim: set ts=2 sw=2 sts=2 et:
