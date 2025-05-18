// The Timeline widget in the current selected Mastodon server.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/glacial/models/server.dart';
import 'package:glacial/features/timeline/models/timeline.dart';

// The timeline type button to show the timeline type in the tab bar.
class TimelineTypeButton extends StatelessWidget {
  final TimelineType type;
  final double size;
  final VoidCallback? onPressed;

  const TimelineTypeButton({
    super.key,
    required this.type,
    this.size = 32,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon,size: size),
      tooltip: type.name,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      onPressed: onPressed,
    );
  }

  IconData get icon {
    switch (type) {
      case TimelineType.home:
        return Icons.home_outlined;
      case TimelineType.local:
        return Icons.groups_outlined;
      case TimelineType.federal:
        return Icons.account_tree_outlined;
      case TimelineType.public:
        return Icons.public_outlined;
      case TimelineType.bookmarks:
        return Icons.bookmarks_outlined;
      case TimelineType.favourites:
        return Icons.star_outline_outlined;
    }
  }
}

// The timeline tab that shows the all possible timelines in the current
// selected Mastodon server.
class TimelineTab extends ConsumerStatefulWidget {
  const TimelineTab({super.key});

  @override
  ConsumerState<TimelineTab> createState() => _TimelineTabState();
}

class _TimelineTabState extends ConsumerState<TimelineTab> with SingleTickerProviderStateMixin {
  final List<TimelineType> types = TimelineType.values;
  late final ServerSchema? schema;

  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    schema = ref.read(currentServerProvider);
  }

  @override
  Widget build(BuildContext context) {
    final ServerSchema? schema = ref.read(currentServerProvider);

    if (schema == null) {
      logger.w("No server selected, but it's required to show the timeline.");
      throw Exception("No server selected");
    }

    return SlideTabView(
      tabs: types,
      tabBuilder: (index) => types[index].supportAnonymous,
      itemBuilder: (context, index) {
        final TimelineType type = types[index];
        return Text("${type.name} Timeline");
      },
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
