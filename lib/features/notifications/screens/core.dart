// The Notification widget in the current selected Mastodon server.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

class GroupNotification extends ConsumerStatefulWidget {
  const GroupNotification({super.key});

  @override
  ConsumerState<GroupNotification> createState() => _GroupNotificationState();
}

class _GroupNotificationState extends ConsumerState<GroupNotification> {
  final double loadingThreshold = 180;

  late final ScrollController controller = ScrollController();
  late final ServerSchema? server = ref.read(serverProvider);

  bool isLoading = false;
  List<GroupSchema> groups = [];

  @override
  void initState() {
    super.initState();
    controller.addListener(onScroll);
    onLoad();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (server == null) {
      logger.w("No server selected, but it's required to show the notifications.");
      return const SizedBox.shrink();
    }

    return Align(
      alignment: Alignment.topCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          isLoading ? ClockProgressIndicator() : const SizedBox.shrink(),
          Flexible(child: buildContent()),
        ],
      ),
    );
  }

  // Build the notification content.
  Widget buildContent() {
    return ListView.builder(
      controller: controller,
      itemCount: groups.length,
      itemBuilder: (BuildContext context, int index) {
        final GroupSchema group = groups[index];

        return Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
          ),
          child: Padding(
            padding: EdgeInsets.only(right: 16),
            child: SingleNotification(schema: group),
          ),
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

  Future<void> onLoad() async {
    final String? maxId = groups.isNotEmpty ? groups.last.pageMaxID : null;

    if (isLoading) {
      return;
    }
    setState(() => isLoading = true);

    final String? accessToken = ref.read(accessTokenProvider);
    final GroupNotificationSchema? schema = await server?.listNotifications(accessToken: accessToken, maxId: maxId);
    setState(() => groups.addAll(schema?.groups ?? []));

    setState(() => isLoading = false);
  }
}

class SingleNotification extends ConsumerWidget {
  final GroupSchema schema;

  const SingleNotification({
    super.key,
    required this.schema,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ServerSchema? server = ref.watch(serverProvider);
    final String? accessToken = ref.watch(accessTokenProvider);

    if (server == null) {
      logger.w("No server selected, but it's required to show the notifications.");
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: buildContent(context, server: server, accessToken: accessToken),
    );
  }

  // Build the notification based on the type of the schema.
  Widget buildContent(BuildContext context, {required ServerSchema server, String? accessToken}) {
    late final Widget content;

    switch (schema.type) {
      case NotificationType.favourite:
      case NotificationType.reblog:
        content = FutureBuilder(
          future: server.getStatus(schema.statusID!, accessToken: accessToken),
          builder: (BuildContext context, AsyncSnapshot<StatusSchema?> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const ClockProgressIndicator();
            } else if (snapshot.hasError || !snapshot.hasData) {
              return const SizedBox.shrink();
            }

            final StatusSchema status = snapshot.data!;
            return ColorFiltered(
              colorFilter: ColorFilter.mode(Colors.grey, BlendMode.modulate),
              child: Status(schema: status),
            );
          },
        );

        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildHeader(context, server: server),
            Transform.scale(
              scale: 0.9,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: content,
                ),
              ),
            ),
          ],
        );
      case NotificationType.mention:
        return FutureBuilder(
          future: server.getStatus(schema.statusID!, accessToken: accessToken),
          builder: (BuildContext context, AsyncSnapshot<StatusSchema?> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const ClockProgressIndicator();
            } else if (snapshot.hasError || !snapshot.hasData) {
              return const SizedBox.shrink();
            }

            final StatusSchema status = snapshot.data!;
            return Status(schema: status);
          },
        );
      default:
        return Text("not implemented yet: ${schema.type}", style: TextStyle(color: Colors.red));
    }
  }

  // Build the related accounts based on the schema.
  Widget buildHeader(BuildContext context, {required ServerSchema server}) {
    final double iconSize = 32;
    final Storage storage = Storage();
    final List<AccountSchema?> accounts = schema.accounts.map((a) => storage.loadAccountFromCache(server, a)).toList();

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: accounts.map((account) {
        if (account == null) {
          return const SizedBox.shrink();
        }

        final Widget avatar = CachedNetworkImage(
          imageUrl: account.avatar,
          placeholder: (context, url) => const CircularProgressIndicator(),
          errorWidget: (context, url, error) => const Icon(Icons.error),
          width: iconSize,
          height: iconSize,
          fit: BoxFit.cover,
        );
        return Padding(
          padding: const EdgeInsets.only(right: 4),
          child: ClipOval(
            child: InkWellDone(
              onTap: () => context.push(RoutePath.profile.path, extra: account),
              child: avatar,
            ),
          ),
        );
      }).toList(),
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
