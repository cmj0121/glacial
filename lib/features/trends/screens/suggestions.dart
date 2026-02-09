// The standalone suggestions screen showing suggested accounts with swipe-to-dismiss.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

// A standalone list of suggested accounts with swipe-to-dismiss.
class SuggestionList extends ConsumerStatefulWidget {
  const SuggestionList({super.key});

  @override
  ConsumerState<SuggestionList> createState() => _SuggestionListState();
}

class _SuggestionListState extends ConsumerState<SuggestionList> with PaginatedListMixin {
  late final AccessStatusSchema? status = ref.read(accessStatusProvider);

  List<SuggestionSchema> suggestions = [];

  @override
  void initState() {
    super.initState();
    onLoad();
  }

  @override
  Widget build(BuildContext context) {
    if (status?.server == null) {
      logger.w("No server selected, but it's required to show suggestions.");
      return const SizedBox.shrink();
    }

    if (suggestions.isEmpty && isLoading) {
      return const ClockProgressIndicator();
    } else if (suggestions.isEmpty && isCompleted) {
      final String message = AppLocalizations.of(context)?.txt_no_result ?? "No results found";
      return NoResult(message: message, icon: Icons.coffee);
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: buildContent(),
    );
  }

  Widget buildContent() {
    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final SuggestionSchema suggestion = suggestions[index];
        final Widget child = Tooltip(
          message: suggestion.source.tooltip(context),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Account(schema: suggestion.account),
          ),
        );

        return Dismissible(
          key: ValueKey(suggestion.account.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            color: Theme.of(context).colorScheme.error,
            child: const Icon(Icons.person_remove, color: Colors.white),
          ),
          confirmDismiss: (_) async {
            setState(() => suggestions.removeAt(index));
            status?.removeSuggestion(suggestion.account.id);
            return false;
          },
          child: child,
        );
      },
    );
  }

  Future<void> onLoad() async {
    if (shouldSkipLoad) return;

    setLoading(true);

    final List<SuggestionSchema> result = await status?.fetchSuggestion() ?? [];

    if (mounted) {
      setState(() => suggestions.addAll(result));
      markLoadComplete(isEmpty: result.isEmpty);
    }
  }
}

// vim: set ts=2 sw=2 sts=2 et:
