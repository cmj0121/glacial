// The autocomplete form for the status input field, which can suggest accounts or hashtags.
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';

// The autocomplete form for the status input field, which can suggest accounts or hashtags.
class AutoCompleteForm extends ConsumerStatefulWidget {
  final int maxSuggestions;
  final String initialText;
  final TextEditingController? controller;
  final AutocompleteFieldViewBuilder? builder;

  const AutoCompleteForm({
    super.key,
    this.maxSuggestions = 10,
    this.initialText = "",
    this.controller,
    this.builder,
  });

  @override
  ConsumerState<AutoCompleteForm> createState() => _AutoCompleteFormState();
}

class _AutoCompleteFormState extends ConsumerState<AutoCompleteForm> {
  final FocusNode focusNode = FocusNode();

  late final TextEditingController controller;

  String type = '';

  @override
  void initState() {
    super.initState();
    controller = widget.controller ?? TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      // Only dispose the controller if it was created in this widget.
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AccessStatusSchema? status = ref.read(accessStatusProvider);

    return RawAutocomplete<String>(
      textEditingController: controller,
      focusNode: focusNode,
      displayStringForOption: replaceText,
      fieldViewBuilder: widget.builder,
      optionsBuilder: (TextEditingValue value) async {
        final String text = value.text;
        final int atIndex = text.lastIndexOf("@");
        final int hashIndex = text.lastIndexOf("#");
        final int spaceIndex = text.lastIndexOf(" ");
        final int newlineIndex = text.lastIndexOf("\n");

        if (atIndex < 0 && hashIndex < 0 || (max(atIndex, hashIndex) < max(spaceIndex, newlineIndex))) {
          // If the last token is not an @ or #, return an empty list.
          return const Iterable.empty();
        }

        final String prefix = text.substring(max(atIndex, hashIndex) + 1);
        type = atIndex > hashIndex ? "accounts" : "hashtags";

        final SearchResultSchema? results = await status?.search(keyword: prefix, type: type);
        final List<String> token = (results?.hashtags ?? []).map((r) => r.name).toList();
        final List<String> suggestions = token.take(widget.maxSuggestions).toList();

        logger.d("autocomplete suggestions for '$prefix': $suggestions");
        return suggestions;
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            child: Container(
              width: 400,
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final String option = options.elementAt(index);
                  final String text = "${type == 'accounts' ? '@' : '#'}$option";
                  return ListTile(title: Text(text), onTap: () {
                    onSelected(text);
                    focusNode.requestFocus();
                  });
                },
              ),
            ),
          ),
        );
      },
    );
  }

  // Replace the text in the controller with the selected suggestion.
  String replaceText(String value) {
    // only replace the token that is being edited
    final String text = controller.text;
    final int index = text.lastIndexOf(type == 'accounts' ? '@' : '#');

    return "${text.substring(0, index)}$value ";
  }
}

// vim: set ts=2 sw=2 sts=2 et:
