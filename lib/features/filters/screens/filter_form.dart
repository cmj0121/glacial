// The form to create or edit a filter.
import 'package:flutter/material.dart';
import 'package:duration/duration.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

// The form to create or edit a filter.
class FiltersForm extends ConsumerStatefulWidget {
  final String title;
  final FiltersSchema? schema;

  const FiltersForm({
    super.key,
    required this.title,
    this.schema,
  });

  @override
  ConsumerState<FiltersForm> createState() => _FiltersFormState();
}

class _FiltersFormState extends ConsumerState<FiltersForm> {
  late FilterFormSchema form = widget.schema?.asForm() ?? FilterFormSchema.fromTitle(widget.title);
  late FilterKeywordFormSchema keyword = FilterKeywordFormSchema.empty();

  late final FocusNode focusNode = FocusNode();
  late final TextEditingController controller = TextEditingController();
  late final TextEditingController titleController = TextEditingController(text: widget.title);
  late final TextStyle? subStyle = Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).disabledColor);
  late final AccessStatusSchema? status = ref.read(accessStatusProvider);
  late final Map<String, Future<StatusSchema?>> _statusFutures = {};

  @override
  void initState() {
    super.initState();
    // Pre-cache futures for filtered statuses
    for (final s in widget.schema?.statuses ?? []) {
      _statusFutures[s.statusId] = status?.getStatus(s.statusId, loadCache: true) ?? Future.value(null);
    }
  }

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

          ...form.keywords.where((item) => !item.destroy).toList().asMap().entries.map((entry) => FilterKeywordForm(
            key: UniqueKey(),
            schema: entry.value,
            onChanged: (item) {
              final List<FilterKeywordFormSchema> updated = List.from(form.keywords);
              updated[entry.key] = item;
              setState(() => form = form.copyWith(keywords: updated));
            },
            onDelete: () {
              List<FilterKeywordFormSchema> updated = List.from(form.keywords);
              updated[entry.key] = updated[entry.key].destroyed();
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

          ...buildFilteredStatus(),
        ],
      ),
    );
  }

  // The editable title field.
  Widget buildTitle() {
    final String text = AppLocalizations.of(context)?.txt_filter_name ?? "The name of the filter";

    return Focus(
      onFocusChange: (hasFocus) {
        if (!hasFocus) {
          setState(() => form = form.copyWith(title: titleController.text));
        }
      },
      child: ListTile(
        leading: Icon(Icons.text_fields_outlined, size: iconSize),
        title: TextField(
          controller: titleController,
          style: Theme.of(context).textTheme.titleMedium,
          decoration: InputDecoration(border: InputBorder.none),
          onSubmitted: (String value) => form = form.copyWith(title: value),
        ),
        subtitle: Text(text, style: subStyle),
      ),
    );
  }

  // The action to the filter.
  Widget buildAction() {
    return ListTile(
      leading: Icon(form.action.icon, size: iconSize),
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
    final String textExpired = AppLocalizations.of(context)?.txt_filter_expired ?? "Expired";
    final String textNever = AppLocalizations.of(context)?.txt_filter_never ?? "Never";
    final String descExpired = AppLocalizations.of(context)?.desc_filter_expiration ?? "When the filter will expire";

    final String text = index == -1 ?
        (form.expiresIn! < 0 ? textExpired : Duration(seconds: form.expiresIn ?? 0).pretty()) :
        (durations[index] == null ? textNever : "In ${durations[index]?.pretty()}");

    return ListTile(
      leading: Icon(Icons.schedule_outlined, size: iconSize),
      title: Text(text),
      subtitle: Text(descExpired, style: subStyle),
      onTap: () {
        final int next = (index + 1) % durations.length;
        setState(() => form = form.copyWith(expiresIn: durations[next]?.inSeconds ?? 0));
       },
    );
  }

  // Build the optional field for applying the filter to specific contexts.
  Widget buildContexts() {
    final List<FilterContext> contexts = FilterContext.values;
    final String text = AppLocalizations.of(context)?.desc_filter_context ?? "Where the filter should be applied";
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
      leading: Icon(Icons.ballot_rounded, size: iconSize),
      title: chips,
      subtitle: Text(text, style: subStyle),
    );
  }

  // List the filtered status if any.
  List<Widget> buildFilteredStatus() {
    if (widget.schema?.statuses?.isNotEmpty != true) {
      return [];
    }

    return [
      const Divider(),
      ...widget.schema?.statuses?.map((s) {
        return FutureBuilder(
          future: _statusFutures[s.statusId],
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) return const SizedBox.shrink();

            final StatusSchema? schema = snapshot.data;
            if (schema == null) return const SizedBox.shrink();

            return Dismissible(
              key: ValueKey(s.statusId),
              background: Container(
                alignment: Alignment.centerLeft,
                color: Theme.of(context).colorScheme.error,
                child: Icon(Icons.delete_forever_rounded, color: Theme.of(context).colorScheme.onError),
              ),
              confirmDismiss: (_) async {
                await status?.removeFilterStatus(status: s);
                return false;
              },
              child: StatusLite(schema: schema),
            );
          },
        );
      }).toList() ?? [],
    ];
  }

  // Build the submit button that can post the status or schedule the post.
  Widget buildSubmitButton() {
    final String text = AppLocalizations.of(context)?.btn_save ?? "Save";
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        icon: Icon(Icons.save_outlined, size: iconSize),
        label: Text(text),
        onPressed: canSubmit ? onSubmit : null,
      ),
    );
  }

  // Check the form can be submitted.
  bool get canSubmit =>  form.context.isNotEmpty;

  Future<void> onSubmit() async {
    if (widget.schema == null) {
      await status?.createFilter(schema: form);
    } else {
      await status?.updateFilter(id: widget.schema!.id, schema: form);
    }

    if (mounted && context.canPop()) context.pop();
  }
}

// vim: set ts=2 sw=2 sts=2 et:
