// The Account profile widget to show the details of the user.import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';


// The account profile to show the details of the user.
class AccountProfile extends ConsumerStatefulWidget {
  final AccountSchema schema;

  const AccountProfile({
    super.key,
    required this.schema,
  });

  @override
  ConsumerState<AccountProfile> createState() => _AccountProfileState();
}

class _AccountProfileState extends ConsumerState<AccountProfile> with SingleTickerProviderStateMixin {
  late final AccessStatusSchema? status = ref.read(accessStatusProvider);
  late final List<AccountProfileType> types;
  late final TabController controller;

  @override
  void initState() {
    super.initState();

    types = AccountProfileType.values.where((type) => type.selfProfile || isSelfProfile).toList();
    controller = TabController(length: types.length, vsync: this);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (status?.server == null) {
      logger.w("No server selected, but it's required to show the account profile.");
      return const SizedBox.shrink();
    }

    return buildContent(context, status!.server!);
  }

  Widget buildContent(BuildContext context, ServerSchema server) {
    return SwipeTabView(
      tabController: controller,
      itemCount: types.length,
      tabBuilder: (context, index) {
        final AccountProfileType type = types[index];
        final bool isSelected = controller.index == index;
        final Color color = isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface;

        return Tooltip(
          message: type.tooltip(context),
          child: Icon(type.icon(active: isSelected), color: color, size: tabSize),
        );
      },
      itemBuilder: (context, index) => const WIP(),
    );
  }

  bool get isSelfProfile => widget.schema.id == status?.account?.id;
}
// vim: set ts=2 sw=2 sts=2 et:
