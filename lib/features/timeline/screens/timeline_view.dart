// The timeline widget that contains the status from the current selected Mastodon server.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

class Timeline extends StatefulWidget {
  final TimelineType type;
  final AccessStatusSchema status;
  final SystemPreferenceSchema? pref;
  final AccountSchema? account;
  final String? hashtag;
  final String? listId;
  final VoidCallback? onDeleted;

  const Timeline({
    super.key,
    required this.type,
    required this.status,
    this.pref,
    this.account,
    this.hashtag,
    this.listId,
    this.onDeleted,
  });

  @override
  State<Timeline> createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> with PaginatedListMixin {
  final double loadingThreshold = 180;
  late final ItemScrollController itemScrollController = ItemScrollController();
  late final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();

  Timer? timer;
  Timer? _markerDebounce;
  String? maxId;

  StreamSubscription<StreamingEvent>? _streamSubscription;
  VoidCallback? _streamingUnsubscribe;

  bool _isOffline = false;

  List<StatusSchema> unreaded = [];
  List<StatusSchema> statuses = [];

  @override
  void initState() {
    super.initState();

    itemPositionsListener.itemPositions.addListener(_onPositionChange);

    GlacialHome.itemScrollToTop = itemScrollController;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final Duration? refreshInterval = widget.pref?.refreshInterval;

      if (refreshInterval != null && refreshInterval.inSeconds > 0) {
        final int interval = refreshInterval.inSeconds;

        timer = Timer.periodic(Duration(seconds: interval), (Timer timer) async {
          onLoadUnreaded();
        });
      }

      _loadCachedTimeline();
      onLoad();
      _initStreaming();
    });
  }

  void _initStreaming() {
    final StreamType? streamType = streamTypeForTimeline(widget.type);
    if (streamType == null || widget.status.domain == null) return;

    final service = getStreamingService(
      widget.status.domain!,
      accountId: widget.status.account?.id,
      accessToken: widget.status.accessToken,
    );

    _streamingUnsubscribe = service.subscribe(
      streamType,
      tag: widget.hashtag,
      listId: widget.listId,
    );

    _streamSubscription = service.events.listen(_onStreamingEvent);
  }

  Future<void> _loadCachedTimeline() async {
    final String? key = widget.status.compositeKey;
    if (key == null) return;

    final String? cached = await Storage().loadCachedTimeline(key, widget.type.name);
    if (cached == null || !mounted) return;

    // Only use cache if we haven't loaded network data yet.
    if (statuses.isNotEmpty) return;

    final List<dynamic> json = jsonDecode(cached) as List<dynamic>;
    final List<StatusSchema> parsed = json
        .map((e) => StatusSchema.fromJson(e))
        .where((s) => s.filterAction != FilterAction.hide)
        .toList();

    if (parsed.isNotEmpty && mounted) {
      setState(() => statuses = parsed);
    }
  }

  void _onStreamingEvent(StreamingEvent event) {
    if (!mounted) return;

    switch (event.type) {
      case StreamingEventType.update:
        final StatusSchema? status = event.status;
        if (status == null) return;
        final existingIds = {...statuses.map((s) => s.id), ...unreaded.map((s) => s.id)};
        if (existingIds.contains(status.id)) return;
        setState(() => unreaded.insert(0, status));

      case StreamingEventType.delete:
        final String? id = event.deletedStatusId;
        if (id == null) return;
        setState(() {
          statuses.removeWhere((s) => s.id == id);
          unreaded.removeWhere((s) => s.id == id);
        });

      case StreamingEventType.statusUpdate:
        final StatusSchema? status = event.status;
        if (status == null) return;
        setState(() {
          final int idx = statuses.indexWhere((s) => s.id == status.id);
          if (idx >= 0) statuses[idx] = status;
          final int uidx = unreaded.indexWhere((s) => s.id == status.id);
          if (uidx >= 0) unreaded[uidx] = status;
        });

      default:
        break;
    }
  }

  @override
  void dispose() {
    itemPositionsListener.itemPositions.removeListener(_onPositionChange);
    _streamSubscription?.cancel();
    _streamingUnsubscribe?.call();
    timer?.cancel();
    _markerDebounce?.cancel();
    super.dispose();
  }

  void _onPositionChange() {
    final List<ItemPosition> positions = itemPositionsListener.itemPositions.value.toList();
    final int? lastIndex = positions.isNotEmpty ? positions.last.index : null;

    if (lastIndex != null && lastIndex > statuses.length - 5) onLoad();

    // Save read position for home timeline with debouncing.
    if (widget.type == TimelineType.home && widget.status.isSignedIn) {
      final int? firstIndex = positions.isNotEmpty ? positions.first.index : null;
      if (firstIndex != null && firstIndex < statuses.length) {
        _saveMarkerDebounced(statuses[firstIndex].id);
      }
    }
  }

  void _saveMarkerDebounced(String statusId) {
    _markerDebounce?.cancel();
    _markerDebounce = Timer(const Duration(seconds: 3), () {
      widget.status.setMarker(id: statusId, type: TimelineMarkerType.home);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isCompleted && !isLoading && statuses.isEmpty) {
      final String message = AppLocalizations.of(context)?.txt_no_result ?? "No results found";
      return NoResult(message: message, icon: Icons.coffee);
    }

    return Align(
      alignment: Alignment.topCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (statuses.isNotEmpty) buildLoadingIndicator(),
          OfflineBanner(isOffline: _isOffline),
          buildUnreadedBanner(),
          Flexible(child: buildContent()),
        ],
      ),
    );
  }

  // Build the unreaded count widget and the list of statuses.
  Widget buildUnreadedBanner() {
    final TextStyle? style = Theme.of(context).textTheme.labelLarge;

    if (unreaded.isEmpty) return const SizedBox.shrink();
    final String text = AppLocalizations.of(context)?.btn_timeline_unread(unreaded.length) ?? "Unreaded ${unreaded.length}";

    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        icon: const Icon(Icons.mark_email_unread, size: tabSize),
        label: Text(text, style: style),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
        ),
        onPressed: onClickUnreaded,
      ),
    );
  }

  // Build the list of the statuses and optionally header widget.
  Widget buildContent() {
    if (statuses.isEmpty) {
      if (isLoading || !isCompleted) {
        return const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: SkeletonTimeline(),
        );
      }
      return const SizedBox.shrink();
    }

    return CustomMaterialIndicator(
      onRefresh: onRefresh,
      indicatorBuilder: (_, __) => const ClockProgressIndicator(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: ScrollablePositionedList.builder(
          itemScrollController: itemScrollController,
          itemPositionsListener: itemPositionsListener,
          shrinkWrap: true,
          itemCount: statuses.length,
          itemBuilder: (context, index) {
            final StatusSchema status = statuses[index];
            final Widget child = Status(
              key: ValueKey('status_${status.id}'),
              schema: status,
              onDeleted: () {
                setState(() => statuses.removeAt(index));
                widget.onDeleted?.call();
              }
            );

            return Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.outline)),
              ),
              child: child,
            );
          },
        ),
      ),
    );
  }

  // Show the unreaded statuses when the user taps on the unreaded banner and keep the current
  // scroll position.
  Future<void> onClickUnreaded() async {
    final List<ItemPosition> positions = itemPositionsListener.itemPositions.value.toList();
    final int newIndex = widget.pref?.loadedTop == true ? 0 : (unreaded.length + positions.first.index);

    setState(() {
      statuses.insertAll(0, unreaded);
      unreaded.clear();
    });

    // Scroll to the old position after the new statuses are added.
    WidgetsBinding.instance.addPostFrameCallback((_) => itemScrollController.jumpTo(index: newIndex));
  }

  // Clean-up and refresh the timeline when the user pulls down the list.
  Future<void> onRefresh() async {
    setState(() => unreaded.clear());
    await refreshList(onLoad);
  }

  // Load the statuses from the current selected Mastodon server.
  Future<void> onLoad() async {
    if (shouldSkipLoad) return;

    setLoading(true);

    try {
      final (schemas, newMaxId) = await widget.status.fetchTimeline(
        widget.type,
        account: widget.type == TimelineType.schedule ? widget.status.account : widget.account,
        tag: widget.hashtag,
        listId: widget.listId,
        maxId: maxId,
        compositeKey: widget.status.compositeKey,
      );

      // Check the new statuses is repeating the old ones to avoid infinite loading.
      final existingIds = statuses.map((s) => s.id).toSet();
      final bool isRepeat = schemas.isNotEmpty && schemas.every((s) => existingIds.contains(s.id));

      if (mounted) {
        setState(() {
          // On first-page refresh, replace cached data with fresh network data.
          if (maxId == null && isRefresh) {
            statuses = schemas;
          } else {
            statuses.addAll(isRepeat ? [] : schemas);
          }
          maxId = isRepeat ? null : (newMaxId ?? (schemas.isNotEmpty ? schemas.last.id : null));
          if (_isOffline) _isOffline = false;
        });
        markLoadComplete(isEmpty: isRepeat || schemas.isEmpty);
      }
    } on SocketException {
      if (mounted) {
        setState(() => _isOffline = true);
        markLoadComplete(isEmpty: statuses.isEmpty);
      }
    } on HttpTimeoutException {
      if (mounted) {
        setState(() => _isOffline = true);
        markLoadComplete(isEmpty: statuses.isEmpty);
      }
    }
  }

  // Load the possible unreaded statuses when the app is resumed.
  Future<void> onLoadUnreaded() async {
    String? minId = unreaded.isEmpty ?
        (statuses.isNotEmpty ? statuses.first.id : null) :
        unreaded.first.id;

    if (minId == null) return;

    while (true) {
      final List<StatusSchema> schemas = await onLoadUnreadedMore(minId);

      if (schemas.isEmpty) break;

      setState(() => unreaded.insertAll(0, schemas));
      minId = schemas.first.id;

      await Future.delayed(const Duration(milliseconds: 750));
    }
  }

  Future<List<StatusSchema>> onLoadUnreadedMore(String? minId) async {
    final (schema, _) = await widget.status.fetchTimeline(
      widget.type,
      account: widget.type == TimelineType.schedule ? widget.status.account : widget.account,
      tag: widget.hashtag,
      listId: widget.listId,
      minId: minId,
    );

    return schema;
  }
}

// vim: set ts=2 sw=2 sts=2 et:
