// Status interaction info widget showing reblogged/favourited accounts.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

/// Tab view showing accounts that reblogged or favourited a status.
class StatusInfo extends ConsumerStatefulWidget {
  final StatusSchema schema;

  const StatusInfo({
    super.key,
    required this.schema,
  });

  @override
  ConsumerState<StatusInfo> createState() => _StatusInfoState();
}

class _StatusInfoState extends ConsumerState<StatusInfo> with SingleTickerProviderStateMixin {
  final List<StatusInteraction> actions = [StatusInteraction.reblog, StatusInteraction.favourite];
  late final TabController controller;

  @override
  void initState() {
    super.initState();
    controller = TabController(length: actions.length, vsync: this);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AccessStatusSchema? status = ref.read(accessStatusProvider);

    return Align(
      alignment: Alignment.topCenter,
      child: SwipeTabView(
        itemCount: actions.length,
        tabController: controller,
        tabBuilder: (context, index) {
          final StatusInteraction action = actions[index];
          final bool isSelected = controller.index == index;
          final bool isActive = tappable(action);
          final Color color = isActive ?
              (isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface) :
              Theme.of(context).disabledColor;

          return Tooltip(
            message: action.tooltip(context),
            child: Icon(action.icon(active: isSelected), color: color, size: tabSize),
            );
        },
        itemBuilder: (context, index) {
          final StatusInteraction action = actions[index];
          final bool isReblog = action == StatusInteraction.reblog;

          return FutureBuilder(
            future: isReblog ? status?.fetchRebloggedBy(schema: widget.schema) : status?.fetchFavouritedBy(schema: widget.schema),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const ClockProgressIndicator();
              } else if (snapshot.hasError) {
                return const SizedBox.shrink();
              }

              final List<AccountSchema> accounts = snapshot.data as List<AccountSchema>;
              return ListView.builder(
                shrinkWrap: true,
                itemCount: accounts.length,
                itemBuilder: (context, index) {
                  final AccountSchema account = accounts[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Account(schema: account),
                  );
                },
              );
            },
          );
        },
        onTabTappable: (index) => tappable(actions[index]),
      ),
    );
  }

  bool tappable(StatusInteraction action) {
    switch (action) {
      case StatusInteraction.reblog:
        return widget.schema.reblogsCount > 0;
      case StatusInteraction.favourite:
        return widget.schema.favouritesCount > 0;
      default:
        return false;
    }
  }
}

// vim: set ts=2 sw=2 sts=2 et:
