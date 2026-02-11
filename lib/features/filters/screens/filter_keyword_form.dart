// The form to edit a single keyword item used in the filter form.
import 'package:flutter/material.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';

// The form to edit a single keyword item used in the filter form.
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
    return Focus(
      onFocusChange: (hasFocus) {
        if (!hasFocus && widget.onDelete != null) onSave();
      },
      child: buildContent(),
    );
  }

  Widget buildContent() {
    final bool whole = item.wholeWord;
    final bool deletable = widget.onDelete != null;

    return ListTile(
      leading: Tooltip(
        message: whole ?
          (AppLocalizations.of(context)?.btn_filter_whole_match ?? "Whole word match") :
          (AppLocalizations.of(context)?.btn_filter_partial_match ?? "Partial word match"),
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
        onPressed: deletable ? widget.onDelete : onSave,
      ),
      onTap: () {
        setState(() => item = item.copyWith(wholeWord: !item.wholeWord));
        if (widget.onDelete != null) widget.onChanged?.call(item);
      },
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
