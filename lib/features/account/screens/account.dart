// The Status widget to show the toots from user.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

// The account widget to show the account information.
class Account extends StatelessWidget {
  final AccountSchema schema;
  final double maxHeight;
  final bool isTappable;
  final bool showStats;
  final VoidCallback? onTap;

  const Account({
    super.key,
    required this.schema,
    this.maxHeight = 52,
    this.isTappable = true,
    this.showStats = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxWidth = constraints.maxWidth;
        final bool showStats = this.showStats && maxWidth > 800;

        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: maxHeight,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              late Widget content;

              if (constraints.maxHeight < 24) {
                content = Row(
                  children: [
                    buildAvatar(),
                    const SizedBox(width: 6),
                    buildDisplayName(),
                  ]
                );
              } else {
                content = buildContent(context, showStats);
              }

              return InkWellDone(
                onTap: isTappable ? () {
                  onTap?.call();
                  context.push(RoutePath.profile.path, extra: schema);
                } : null,
                child: content,
              );
            },
          ),
        );
      },
    );
  }

  Widget buildContent(BuildContext context, bool showStats) {
    final Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildAvatar(),
        const SizedBox(width: 16),
        buildName(),

        if (showStats) ...[
          const Spacer(),
          buildStats(context),
        ],
      ],
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: content,
    );
  }

  // Build the Avatar of the user.
  Widget buildAvatar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: schema.avatar,
        placeholder: (context, url) => const CircularProgressIndicator(),
        errorWidget: (context, url, error) => const Icon(Icons.error),
        fit: BoxFit.cover,
      ),
    );
  }

  // Build the display name and the account name of the user.
  Widget buildName() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildDisplayName(),
        Text('@${schema.acct}', style: const TextStyle(color: Colors.grey), overflow: TextOverflow.ellipsis),
      ],
    );
  }

  // Build display name with the emoji
  Widget buildDisplayName() {
    final Storage storage = Storage();
    final String text = schema.displayName.isEmpty ? schema.username : schema.displayName;

    return storage.replaceEmojiToWidget(text, emojis: schema.emojis);
  }

  // The statistics of the user, such as followers, following and statuses.
  Widget buildStats(BuildContext context) {
    final int followers = schema.followersCount;
    final int following = schema.followingCount;
    final int statuses = schema.statusesCount;
    final Color color = Theme.of(context).colorScheme.onSecondaryContainer;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Badge.count(count: statuses, backgroundColor: color, child: Icon(Icons.post_add)),
        const SizedBox(width: 26),
        Badge.count(count: followers, backgroundColor: color, child: Icon(Icons.visibility)),
        const SizedBox(width: 26),
        Badge.count(count: following, backgroundColor: color, child: Icon(Icons.star)),
        const SizedBox(width: 26),
      ],
    );
  }
}

// The account profile to show the details of the user.
class AccountProfile extends ConsumerStatefulWidget {
  final AccountSchema schema;
  final double bannerHeight;
  final double avatarSize;

  const AccountProfile({
    super.key,
    required this.schema,
    this.bannerHeight = 200,
    this.avatarSize = 80,
  });

  @override
  ConsumerState<AccountProfile> createState() => _AccountProfileState();
}

class _AccountProfileState extends ConsumerState<AccountProfile> with SingleTickerProviderStateMixin {
  late final List<TimelineType> types;
  late final TabController controller;

  @override
  void initState() {
    super.initState();

    final AccountSchema? account = ref.read(accountProvider);
    final List<TimelineType> allTypes = [
      TimelineType.profile,
      TimelineType.user,
      TimelineType.pin,
      TimelineType.schedule,
      TimelineType.hashtag,
    ];

    types = allTypes.where((type) => type.supportAnonymous || account?.id == widget.schema.id).toList();
    controller = TabController(length: types.length, vsync: this);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ServerSchema? server = ref.watch(serverProvider);

    if (server == null) {
      logger.w('Server is not available, cannot build account detail');
      return const SizedBox.shrink();
    }

    return buildContent(context, server);
  }

  Widget buildContent(BuildContext context, ServerSchema server) {
    final AccountSchema? account = ref.read(accountProvider);

    return SwipeTabView(
      tabController: controller,
      itemCount: types.length,
      tabBuilder: (context, index) {
        final TimelineType type = types[index];
        final bool isSelected = controller.index == index;
        final bool isActive = type.supportAnonymous || account?.id == widget.schema.id;
        final Color color = isActive ?
            (isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface) :
            Theme.of(context).disabledColor;

        return Tooltip(
          message: type.tooltip(context),
          child: Icon(type.icon(active: isSelected), color: color, size: 32),
        );
      },
      itemBuilder: (context, index) {
        final TimelineType type = types[index];

        switch (type) {
          case TimelineType.profile:
            return buildTimelineHeader(server);
          case TimelineType.hashtag:
            return FollowedHashtags(server: server);
          default:
            return Timeline(
              schema: server,
              type: types[index],
              account: widget.schema,
            );
        }
      },
      onTabTappable: (index) => types[index].supportAnonymous || account?.id == widget.schema.id,
    );
  }

  // Build the header of the account's timeline, including the user name and
  // the banner.
  Widget buildTimelineHeader(ServerSchema server) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildBanner(),
          const SizedBox(height: 16),
          buildName(context, ref, server),
          HtmlDone(
            html: widget.schema.note,
            emojis: widget.schema.emojis,
          ),
          const Divider(thickness: 4),

          buildUserStats(),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // Build the user stats, including the followers, following and statuses.
  Widget buildUserStats() {
    final ServerSchema? server = ref.read(serverProvider);
    final int followers = widget.schema.followersCount;
    final int following = widget.schema.followingCount;
    final int statuses = widget.schema.statusesCount;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton.icon(
          label: Text('$statuses', style: const TextStyle(fontSize: 16)),
          icon: const Icon(Icons.post_add),
          onPressed: () => controller.animateTo(types.indexOf(TimelineType.user)),
        ),

        TextButton.icon(
          label: Text('$followers', style: const TextStyle(fontSize: 16)),
          icon: const Icon(Icons.visibility),
          onPressed: () => AccountRelations.show(
            context: context,
            schema: widget.schema,
            onLoadMore: server?.followers,
          ),
        ),

        TextButton.icon(
          label: Text('$following', style: const TextStyle(fontSize: 16)),
          icon: const Icon(Icons.star),
          onPressed: () => AccountRelations.show(
            context: context,
            schema: widget.schema,
            onLoadMore: server?.following,
          ),
        ),
      ],
    );
  }

  // Show the user name and the account name.
  Widget buildName(BuildContext context, WidgetRef ref, ServerSchema server) {
    final String acct = widget.schema.acct.contains('@') ? widget.schema.acct : '${widget.schema.username}@${server.domain}';
    final AccountSchema? account = ref.watch(accountProvider);

    return Row(
      children: [
        // The location of the user and show as the badge.
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(acct),
        ),

        const Spacer(),
        account?.id == widget.schema.id ? const SizedBox.shrink() : RelationshipBuilder(schema: widget.schema),
        const SizedBox(width: 12),
      ],
    );
  }

  // Build the fixed banner of the account profile and the avatar.
  // It will be fixed in the top of the screen.
  Widget buildBanner() {
    return SizedBox(
      height: widget.bannerHeight,
      child: buildBannerContent(),
    );
  }

  // Build the banner of the account profile, including the header, the
  // avatar and the metadata.
  Widget buildBannerContent() {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        buildHeader(),
        Positioned(
          left: 0,
          bottom: 0,
          width: widget.avatarSize,
          height: widget.avatarSize,
          child: buildAvatar(),
        ),
      ],
    );
  }

  // Build the header of the account profile, as the part of the banner.
  Widget buildHeader() {
    final Widget banner = CachedNetworkImage(
      imageUrl: widget.schema.header,
      placeholder: (context, url) => const CircularProgressIndicator(),
      errorWidget: (context, url, error) => const Icon(Icons.error),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: OverflowBox(
        alignment: Alignment.center,
        maxWidth: double.infinity,
        maxHeight: double.infinity,
        child: MediaHero(child: banner),
      ),
    );
  }

  // Build the Avatar of the user.
  Widget buildAvatar() {
    final Widget avatar = CachedNetworkImage(
      imageUrl: widget.schema.avatar,
      placeholder: (context, url) => const CircularProgressIndicator(),
      errorWidget: (context, url, error) => const Icon(Icons.error),
      fit: BoxFit.cover,
    );

    return Container(
      width: widget.avatarSize,
      height: widget.avatarSize,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 2),
        color: Theme.of(context).colorScheme.surface,
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: MediaHero(child: avatar),
      ),
    );
  }
}

class AccountRelations extends ConsumerStatefulWidget {
  final AccountSchema schema;
  final Function({required AccountSchema account, String? accessToken, String? maxID})? onLoadMore;

  const AccountRelations({
    super.key,
    required this.schema,
    this.onLoadMore,
  });

  @override
  ConsumerState<AccountRelations> createState() => _AccountRelationsState();

  static void show({
    required BuildContext context,
    required AccountSchema schema,
    Function({required AccountSchema account, String? accessToken, String? maxID})? onLoadMore,
  }) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: AccountRelations(schema: schema, onLoadMore: onLoadMore),
      ),
    );
  }
}

class _AccountRelationsState extends ConsumerState<AccountRelations> {
  final ScrollController controller = ScrollController();

  bool isLoading = false;
  bool isCompleted = false;
  String? maxID;
  List<AccountSchema> accounts = [];

  @override
  void initState() {
    super.initState();
    controller.addListener(onScroll);
    onLoad();
  }

  @override
  void dispose() {
    controller.removeListener(onScroll);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (accounts.isEmpty && isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (accounts.isEmpty && isCompleted) {
      final String text = "User ${widget.schema.username} hide their relations";
      final Color color = Theme.of(context).colorScheme.error;

      return Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.visibility_off, size: 48, color: Colors.grey),
                Text(text, style: TextStyle(color: color, fontSize: 16)),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: buildContent(),
    );
  }

  Widget buildContent() {
    return ListView.builder(
      controller: controller,
      itemCount: accounts.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Account(schema: accounts[index], showStats: true, onTap: () => context.pop()),
        );
      },
    );
  }

  // Handle the scroll event to load more accounts.
  void onScroll() {
    if (controller.position.pixels >= controller.position.maxScrollExtent - 100 && !isLoading) {
      onLoad();
    }
  }

  // Load the accounts from the server.
  Future<void> onLoad() async {
    final String? accessToken = ref.read(accessTokenProvider);

    if (isLoading || isCompleted) return;

    setState(() => isLoading = true);

    final (newAccounts, nextLink) = await widget.onLoadMore?.call(
      account: widget.schema,
      accessToken: accessToken,
      maxID: maxID,
    ) ?? [];

    logger.i('Loaded ${newAccounts.length} accounts for ${widget.schema.username} followers');
    setState(() {
      accounts.addAll(newAccounts);
      isLoading = false;

      maxID = getMaxIDFromNextLink(nextLink);
      isCompleted = maxID == null || maxID!.isEmpty;
    });
  }
}

// The followed hashtags widget to show the followed hashtags of the user.
class FollowedHashtags extends ConsumerStatefulWidget {
  final ServerSchema server;

  const FollowedHashtags({super.key, required this.server});

  @override
  ConsumerState<FollowedHashtags> createState() => _FollowedHashtagsState();
}

class _FollowedHashtagsState extends ConsumerState<FollowedHashtags> {
  final ScrollController controller = ScrollController();

  String? maxID;
  bool isLoading = false;
  bool isCompleted = false;
  List<HashtagSchema> hashtags = [];

  @override
  void initState() {
    super.initState();
    controller.addListener(onScroll);
    onLoad();
  }

  @override
  void dispose() {
    controller.removeListener(onScroll);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (hashtags.isEmpty && isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (hashtags.isEmpty && isCompleted) {
      return SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: buildContent(),
    );
  }

  Widget buildContent() {
    return ListView.builder(
      controller: controller,
      itemCount: hashtags.length,
      itemBuilder: (context, index) {
        final HashtagSchema hashtag = hashtags[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Hashtag(schema: hashtag),
        );
      },
    );
  }

  // Handle the scroll event to load more hashtags.
  void onScroll() {
    if (controller.position.pixels >= controller.position.maxScrollExtent - 100 && !isLoading) {
      onLoad();
    }
  }

  // Load the followed hashtags from the server.
  Future<void> onLoad() async {
    final String? accessToken = ref.read(accessTokenProvider);

    if (isLoading || isCompleted) return;
    setState(() => isLoading = true);

    final (newHashtags, nextLink) = await widget.server.followedHashtags(accessToken: accessToken, maxID: maxID);
    setState(() {
      maxID = getMaxIDFromNextLink(nextLink);
      hashtags.addAll(newHashtags);
      isLoading = false;
      isCompleted = maxID == null || maxID!.isEmpty;
    });
  }
}

// vim: set ts=2 sw=2 sts=2 et:
