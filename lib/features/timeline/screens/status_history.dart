// Status edit history widget with slider navigation.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

/// Displays edit history of a status with a vertical slider for navigation.
class StatusHistory extends ConsumerStatefulWidget {
  final StatusSchema schema;

  const StatusHistory({
    super.key,
    required this.schema,
  });

  @override
  ConsumerState<StatusHistory> createState() => _StatusHistoryState();
}

class _StatusHistoryState extends ConsumerState<StatusHistory> with TickerProviderStateMixin {
  bool isDisposed = false;
  int selectedIndex = 0;
  List<StatusEditSchema> history = [];

  PageController? _pageController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => onLoad());
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: isDisposed ? const SizedBox() : Dismissible(
        key: ValueKey(widget.schema.id),
        direction: DismissDirection.startToEnd,
        confirmDismiss: (_) async { onDismiss(); return false; },
        child: buildContent(),
      ),
    );
  }

  Widget buildContent() {
    if (history.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        Flexible(
          child: PageView(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            children: List.generate(history.length, (index) => buildHistory(index)),
            onPageChanged: (index) => setState(() => selectedIndex = index),
          ),
        ),
        buildSlider(),
      ],
    );
  }

  Widget buildSlider() {
    return SfSlider.vertical(
      min: 0,
      max: history.length - 1,
      value: selectedIndex.toDouble(),
      interval: 1,
      showTicks: true,
      onChanged: (dynamic value) => setState(() => selectedIndex = value.toInt()),
    );
  }

  Widget buildHistory(int index) {
    final StatusEditSchema schema = history[index];
    return Align(
      key: ValueKey(selectedIndex),
      alignment: Alignment.topLeft,
      child: StatusEdit(schema: schema),
    );
  }

  Future<void> onLoad() async {
    final AccessStatusSchema? status = ref.read(accessStatusProvider);
    final List<StatusEditSchema> history = await status?.fetchHistory(schema: widget.schema) ?? [];

    if (mounted) {
      setState(() {
        this.history = history;
        selectedIndex = history.isEmpty ? 0 : history.length - 1;
      });
      _pageController = PageController(initialPage: selectedIndex, keepPage: true);
    }
  }

  void onDismiss() {
    setState(() => isDisposed = true);
    context.pop();
  }
}

/// Single edit entry in the status history.
class StatusEdit extends StatelessWidget {
  final StatusEditSchema schema;

  const StatusEdit({
    super.key,
    required this.schema,
  });

  @override
  Widget build(BuildContext context) {
    const double headerHeight = 48.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(flex: 10, child: Account(schema: schema.account, size: headerHeight)),
        const SizedBox(height: 8),
        Text(schema.createdAt.toLocal().toString(), style: TextStyle(color: Theme.of(context).hintColor)),
        const Divider(),
        HtmlDone(html: schema.content, emojis: schema.emojis),
        Poll(schema: schema.poll),
        Attachments(schemas: schema.attachments),

      ],
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
