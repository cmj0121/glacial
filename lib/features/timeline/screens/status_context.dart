// Thread view widget showing status context (ancestors + descendants).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';

import 'status.dart';

/// Displays a status with its full thread context (ancestors and descendants).
class StatusContext extends ConsumerStatefulWidget {
  final StatusSchema schema;

  const StatusContext({
    super.key,
    required this.schema,
  });

  @override
  ConsumerState<StatusContext> createState() => _StatusContextState();
}

class _StatusContextState extends ConsumerState<StatusContext> {
  final ItemScrollController itemScrollController = ItemScrollController();
  late final Future<StatusContextSchema?> _contextFuture;

  @override
  void initState() {
    super.initState();
    final AccessStatusSchema? status = ref.read(accessStatusProvider);
    _contextFuture = status?.getStatusContext(schema: widget.schema) ?? Future.value(null);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<StatusContextSchema?>(
      future: _contextFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingOverlay(isLoading: true, child: SizedBox.expand());
        } else if (snapshot.hasError || snapshot.data == null) {
          return const SizedBox.shrink();
        }

        final StatusContextSchema ctx = snapshot.data!;

        // Combine all statuses and sort by creation time
        final List<StatusSchema> allStatuses = [
          ...ctx.ancestors,
          widget.schema,
          ...ctx.descendants,
        ]..sort((a, b) => a.createdAt.compareTo(b.createdAt));

        // Find the index of the selected status after sorting
        final int selectedIndex = allStatuses.indexWhere((s) => s.id == widget.schema.id);

        // Auto-scroll to selected status aligned to top
        if (selectedIndex > 0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            itemScrollController.scrollTo(
              index: selectedIndex,
              duration: const Duration(milliseconds: 300),
              alignment: 0.0,
            );
          });
        }

        return AccessibleDismissible(
          dismissKey: ValueKey(widget.schema.id),
          direction: DismissDirection.startToEnd,
          dismissLabel: AppLocalizations.of(context)?.lbl_swipe_back,
          confirmDismiss: (_) async { context.pop(); return false; },
          child: buildContent(allStatuses, selectedIndex),
        );
      }
    );
  }

  Widget buildContent(List<StatusSchema> statuses, int selectedIndex) {
    return ScrollablePositionedList.builder(
      itemScrollController: itemScrollController,
      itemCount: statuses.length,
      itemBuilder: (context, index) {
        final StatusSchema status = statuses[index];
        final bool isSelected = index == selectedIndex;

        return Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.outline)),
          ),
          child: Status(
            schema: status,
            indent: isSelected ? 0 : 1,
          ),
        );
      },
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
