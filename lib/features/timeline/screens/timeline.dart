// The Timeline widget in the current selected Mastodon server.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/glacial/models/server.dart';
import 'package:glacial/features/timeline/models/core.dart';
import 'status.dart';

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
        return Timeline.builder(schema: schema, type: type);
      },
    );
  }
}

// The timeline widget that contains the status from the current selected
// Mastodon server.
class Timeline extends StatefulWidget {
  final ServerSchema schema;
  final TimelineType type;
  final List<StatusSchema> statuses;

  const Timeline({
    super.key,
    required this.schema,
    required this.type,
    this.statuses = const [],
  });

  @override
  State<Timeline> createState() => _TimelineState();

  static builder({required ServerSchema schema, required TimelineType type}) {
    return FutureBuilder(
      future: schema.fetchTimeline(type: type),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LinearProgressIndicator();
        } else if (snapshot.hasError) {
          final String text = AppLocalizations.of(context)?.txt_invalid_instance ?? 'Invalid instance: ${schema.domain}';
          return Text(text, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.red));
        }

        final List<StatusSchema> statuses = snapshot.data as List<StatusSchema>;
        return Timeline(schema: schema, type: type, statuses: statuses);
      },
    );
  }
}

class _TimelineState extends State<Timeline> {
  final ScrollController controller = ScrollController();
  final Storage storage = Storage();
  final double loadingThreshold = 180;

  bool isLoading = false;
  bool isCompleted = false;
  late List<StatusSchema> statuses = [];

  @override
  void initState() {
    super.initState();
    statuses = widget.statuses;
    controller.addListener(onScroll);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          isLoading ? LinearProgressIndicator() : const SizedBox.shrink(),
          Flexible(child: buildContent()),
        ],
      ),
    );
  }

  // Build the list of the statuses in the current selected Mastodon server and
  // timeline type.
  Widget buildContent() {
    return ListView.builder(
      controller: controller,
      shrinkWrap: true,
      itemCount: statuses.length,
      itemBuilder: (context, index) {
        final StatusSchema status = statuses[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Status(schema: status),
        );
      },
    );
  }


  // Detect the scroll event and load more statuses when the user scrolls to the
  // almost bottom of the list.
  void onScroll() async {
    if (controller.position.pixels >= controller.position.maxScrollExtent - loadingThreshold) {
      onLoad();
    }
  }

  // Load the statuses from the current selected Mastodon server.
  void onLoad() async {
    if (isLoading || isCompleted) {
      return;
    }

    setState(() => isLoading = true);
    final String? maxId = statuses.isNotEmpty ? statuses.last.id : null;
    final List<StatusSchema> newStatuses = await widget.schema.fetchTimeline(
      type: widget.type,
      maxId: maxId,
    );

    setState(() {
      isLoading = false;

      if (newStatuses.isEmpty) {
        isCompleted = true;
        return;
      }

      statuses.addAll(newStatuses);
    });
  }
}

// vim: set ts=2 sw=2 sts=2 et:
