// The list account widget to show the possible accounts to add to the list.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

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

class _ListAccountWidgetState extends ConsumerState<ListAccountWidget> with PaginatedListMixin {
  late final AccessStatusSchema? status = ref.read(accessStatusProvider);

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

  Future<void> onLoad() async {
    if (shouldSkipLoad) return;

    setLoading(true);

    final int count = this.accounts.length;
    final List<AccountSchema> accounts = await status?.searchAccounts(widget.name, offset: count, following: true) ?? [];

    if (mounted) {
      setState(() => this.accounts.addAll(accounts));
      markLoadComplete(isEmpty: accounts.isEmpty);
    }
  }
}

// vim: set ts=2 sw=2 sts=2 et:
