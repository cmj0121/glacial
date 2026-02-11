// The timeline tab that shows the all possible timelines in the current
// selected Mastodon server.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

class TimelineTab extends ConsumerStatefulWidget {
  final TimelineType initialType;

  const TimelineTab({
    super.key,
    this.initialType = TimelineType.local,
  });

  @override
  ConsumerState<TimelineTab> createState() => _TimelineTabState();
}

class _TimelineTabState extends ConsumerState<TimelineTab> with TickerProviderStateMixin {
  // Exclude TimelineType.hashtag from the timeline tab as hashtag timelines are handled differently
  // or are not supported in the current implementation.
  final List<TimelineType> types = TimelineType.values.where((type) => type.inTimelineTab).toList();

  late final TabController controller;

  @override
  void initState() {
    super.initState();
    controller = TabController(
      length: types.length,
      initialIndex: 0,
      vsync: this,
    );

    controller.index = types.indexWhere((type) => type == widget.initialType);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AccessStatusSchema? status = ref.read(accessStatusProvider);

    if (status == null || status.domain == null) {
      logger.w("No server selected, but it's required to show the timeline.");
      return const SizedBox.shrink();
    }

    return buildContent(context, status);
  }

  Widget buildContent(BuildContext context, AccessStatusSchema status) {
    final bool isSignIn = status.accessToken?.isNotEmpty == true;
    final SystemPreferenceSchema? pref = ref.watch(preferenceProvider);

    return SwipeTabView(
      key: ValueKey('${status.domain}_timeline}'),
      tabController: controller,
      itemCount: types.length,
      tabBuilder: (context, index) {
        final TimelineType type = types[index];
        final bool isSelected = controller.index == index;
        final bool isActivate = isSignIn || type.supportAnonymous;
        final Color color = isActivate ?
            isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface :
            Theme.of(context).disabledColor;

        return Tooltip(
          message: type.tooltip(context),
          child: Icon(type.icon(active: isSelected), color: color, size: tabSize),
        );
      },
      itemBuilder: (context, index) => Timeline(
        type: types[index],
        status: status,
        pref: pref,
        onDeleted: () => context.pop(),
      ),
      onTabTappable: (index) => isSignIn || types[index].supportAnonymous,
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
