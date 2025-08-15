// The Account profile widget to show the details of the user.import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';


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

    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 16),
      child: buildContent(context, status!.server!),
    );
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
      itemBuilder: (context, index) {
        final AccountProfileType type = types[index];

        switch (type) {
          case AccountProfileType.profile:
            return ProfilePage(
              schema: widget.schema,
              onStatusesTap: () => controller.animateTo(AccountProfileType.post.index),
              onFollowersTap: () => controller.animateTo(AccountProfileType.followers.index),
              onFollowingTap: () => controller.animateTo(AccountProfileType.following.index),
            );
          case AccountProfileType.followers:
            return AccountList(loader: ({String? maxId}) =>
              status?.fetchFollowers(account: widget.schema, maxId: maxId) ?? Future.value((<AccountSchema>[], null))
            );
          case AccountProfileType.following:
            return AccountList(loader: ({String? maxId}) =>
              status?.fetchFollowing(account: widget.schema, maxId: maxId) ?? Future.value((<AccountSchema>[], null))
            );
          case AccountProfileType.post:
          case AccountProfileType.pin:
          case AccountProfileType.schedule:
            return Timeline(
              status: status!,
              type: type.timelineType,
              account: widget.schema,
            );
          case AccountProfileType.hashtag:
            return const FollowedHashtags();
          case AccountProfileType.mute:
            return AccountList(loader: status?.fetchMutedAccounts);
          case AccountProfileType.block:
            return AccountList(loader: status?.fetchBlockedAccounts);
        }
      }
    );
  }

  bool get isSelfProfile => widget.schema.id == status?.account?.id;
}

// The user profile page to show the details of the user.
class ProfilePage extends ConsumerWidget {
  final AccountSchema schema;
  final double bannerHeight;
  final double avatarSize;
  final VoidCallback? onStatusesTap;
  final VoidCallback? onFollowersTap;
  final VoidCallback? onFollowingTap;

  const ProfilePage({
    super.key,
    required this.schema,
    this.bannerHeight = 200,
    this.avatarSize = 80,
    this.onStatusesTap,
    this.onFollowersTap,
    this.onFollowingTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AccessStatusSchema? status = ref.read(accessStatusProvider);

    if (status == null || status.domain == null) {
      logger.w("No server selected, but it's required to show the profile page.");
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildBanner(context),
          const SizedBox(height: 16),
          buildAccountName(context, status),
          UserStatistics(
            schema: schema,
            onStatusesTap: onStatusesTap,
            onFollowersTap: onFollowersTap,
            onFollowingTap: onFollowingTap,
          ),
          const Divider(thickness: 4),
          buildAccountInfo(context, status),
        ],
      ),
    );
  }

  // Build the fixed banner of the account profile and the avatar. It will be fixed in the top
  // of the screen.
  Widget buildBanner(BuildContext context) {
    final Widget banner = CachedNetworkImage(
      imageUrl: schema.header,
      placeholder: (context, url) => const ClockProgressIndicator(),
      errorWidget: (context, url, error) => const Icon(Icons.error),
    );

    return SizedBox(
      height: bannerHeight,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: OverflowBox(
              alignment: Alignment.center,
              maxWidth: double.infinity,
              maxHeight: double.infinity,
              child: MediaHero(child: banner),
            ),
          ),
          Positioned(
            left: 0,
            bottom: 0,
            width: avatarSize,
            height: avatarSize,
            child: buildAvatar(context),
          ),
        ],
      ),
    );
  }

  // Build the Avatar of the user.
  Widget buildAvatar(BuildContext context) {
    final Widget avatar = CachedNetworkImage(
      imageUrl: schema.avatar,
      placeholder: (context, url) => const ClockProgressIndicator(),
      errorWidget: (context, url, error) => const Icon(Icons.error),
      fit: BoxFit.cover,
    );

    return Container(
      width: avatarSize,
      height: avatarSize,
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

  // Build the account information section that shows the username, display name, and bio.
  Widget buildAccountInfo(BuildContext context, AccessStatusSchema status) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HtmlDone(html: schema.note),
        ...schema.fields.map((field) => buildField(context, field)),
      ],
    );
  }

  Widget buildField(BuildContext context, FieldSchema field) {
    return ListTile(
      title: HtmlDone(html: field.value),
      subtitle: Text(field.name, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Theme.of(context).disabledColor)),
    );
  }

  // Build the account name and relationship buttons.
  Widget buildAccountName(BuildContext context, AccessStatusSchema status) {
    final String acct = schema.acct.contains('@') ? schema.acct : '${schema.acct}@${status.domain}';
    final Widget botIcon = Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Tooltip(
        message: AppLocalizations.of(context)?.desc_profile_bot ?? "This account is a bot",
        child: Icon(Icons.smart_toy_outlined, color: Theme.of(context).colorScheme.secondary),
      ),
    );

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(acct, style: Theme.of(context).textTheme.labelSmall),
        ),
        schema.bot ? botIcon : const SizedBox.shrink(),

        const Spacer(),

        schema.id == status.account?.id ? EditProfilePage.icon() : Relationship(schema: schema),
      ],
    );
  }
}

// The simple user statistics widget to show the user statistics such as followers, following, and statuses.
class UserStatistics extends StatelessWidget {
  final AccountSchema schema;
  final VoidCallback? onFollowersTap;
  final VoidCallback? onFollowingTap;
  final VoidCallback? onStatusesTap;

  const UserStatistics({
    super.key,
    required this.schema,
    this.onFollowersTap,
    this.onFollowingTap,
    this.onStatusesTap,
  });

  @override
  Widget build(BuildContext context) {
    final int statuses = schema.statusesCount;
    final int followers = schema.followersCount;
    final int following = schema.followingCount;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton.icon(
          label: Text('$statuses'),
          icon: const Icon(Icons.post_add),
          onPressed: onStatusesTap,
        ),

        TextButton.icon(
          label: Text('$followers'),
          icon: const Icon(Icons.visibility),
          onPressed: onFollowersTap,
        ),
        TextButton.icon(
          label: Text('$following'),
          icon: const Icon(Icons.star),
          onPressed: onFollowingTap,
        ),

        buildFollowerLock(context),
        buildDiscoverable(context),
        buildIndexable(context),
      ],
    );
  }

  Widget buildFollowerLock(BuildContext context) {
    if (!schema.locked) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: Tooltip(
        message: AppLocalizations.of(context)?.desc_profile_locked ?? "Manually approved followers",
        child: Icon(Icons.lock_person, color: Theme.of(context).colorScheme.secondary, size: tabSize),
      ),
    );
  }

  Widget buildDiscoverable(BuildContext context) {
    if (schema.discoverable ?? false) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: Tooltip(
        message: AppLocalizations.of(context)?.desc_profile_discoverable ?? "Account can be discoverable in public",
        child: Icon(Icons.travel_explore, color: Theme.of(context).colorScheme.secondary, size: tabSize),
      ),
    );
  }

  Widget buildIndexable(BuildContext context) {
    if ((schema.noindex ?? false) && !schema.indexable) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: Tooltip(
        message: AppLocalizations.of(context)?.desc_profile_post_indexable ?? "Allow search engines to index your posts",
        child: Icon(Icons.search, color: Theme.of(context).colorScheme.secondary, size: tabSize),
      ),
    );
  }
}

// The edit page for the account profile, allowing users to edit their profile information.
class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();

  static Widget icon() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return IconButton(
          icon: const Icon(Icons.manage_accounts_outlined),
          style: IconButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            backgroundColor: Theme.of(context).colorScheme.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () => context.push(RoutePath.editProfile.path),
        );
      },
    );
  }
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> with SingleTickerProviderStateMixin {
  final int maxFieldsCount = 4;
  final List<EditProfileCategory> categories = EditProfileCategory.values;

  late final TabController controller;
  late final TextStyle? labelStyle = Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).disabledColor);

  late AccessStatusSchema? status = ref.read(accessStatusProvider);
  late AccountSchema? account = status?.account;
  late AccountCredentialSchema? schema = account?.toCredentialSchema();

  late final FocusNode nameFocusNode = FocusNode();
  late final FocusNode noteFocusNode = FocusNode();
  late final TextEditingController nameController = TextEditingController(text: schema?.displayName);
  late final TextEditingController noteController = TextEditingController(text: schema?.note);
  late final List<(TextEditingController, TextEditingController)> fieldControllers;

  @override
  void initState() {
    super.initState();

    controller = TabController(length: categories.length, vsync: this);

    nameFocusNode.addListener(() { if (!nameFocusNode.hasFocus) { onEditCompleted(); }});
    noteFocusNode.addListener(() { if (!noteFocusNode.hasFocus) { onEditCompleted(); }});
    fieldControllers = List.generate(maxFieldsCount, (_) => (
      TextEditingController(),
      TextEditingController(),
    ));
  }

  @override
  void dispose() {
    controller.dispose();

    nameFocusNode.dispose();
    noteFocusNode.dispose();
    nameController.dispose();
    noteController.dispose();
    fieldControllers.map(((c) {
      c.$1.dispose();
      c.$2.dispose();
    }));

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (schema == null) {
      return const SizedBox.shrink();
    }

    return buildContent(schema: schema!);
  }

  Widget buildContent({required AccountCredentialSchema schema}) {
    return SwipeTabView(
      tabController: controller,
      itemCount: categories.length,
      tabBuilder: (context, index) {
        final EditProfileCategory category = categories[index];
        final bool isSelected = controller.index == index;
        final Color color = isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface;

        return Tooltip(
          message: category.tooltip(context),
          child: Icon(category.icon(active: isSelected), color: color, size: tabSize),
        );
      },
      itemBuilder: (context, index) {
        final EditProfileCategory category = categories[index];

        switch (category) {
          case EditProfileCategory.general:
            return buildGeneral(schema: schema);
          case EditProfileCategory.privacy:
            return buildPrivacy(schema: schema);
        }
      },
    );
  }

  // The general settings for the account profile.
  Widget buildGeneral({required AccountCredentialSchema schema}) {
    return ListView(
      children: [
        ListTile(
          leading: Tooltip(
            message: AppLocalizations.of(context)?.txt_profile_general_name ?? "Display Name",
            child: Icon(CupertinoIcons.question_square, size: iconSize),
          ),
          title: TextField(
            focusNode: nameFocusNode,
            controller: nameController,
            decoration: InputDecoration(border: InputBorder.none),
            onSubmitted: (_) => onEditCompleted(),
          ),
        ),
        ListTile(
          leading: Tooltip(
            message: AppLocalizations.of(context)?.txt_profile_general_bio ?? "Bio",
            child: Icon(Icons.description, size: iconSize),
          ),
          title: TextField(
            focusNode: noteFocusNode,
            controller: noteController,
            decoration: InputDecoration(border: InputBorder.none),
            onSubmitted: (_) => onEditCompleted(),
          ),
        ),

        SwitchListTile(
          title: Text(AppLocalizations.of(context)?.txt_profile_bot ?? "This account is a bot"),
          subtitle: Text(
            AppLocalizations.of(context)?.desc_profile_bot ?? "This account is a bot",
            style: labelStyle,
          ),
          value: schema.bot,
          secondary: Icon(schema.bot ? Icons.smart_toy_outlined : Icons.person, size: iconSize),
          onChanged: (bool value) => onChanged(schema: schema.copyWith(bot: value)),
        ),

        ...List.generate(schema.fields.length, (index) => buildFieldItem(index)),
        if (schema.fields.length < 4) buildFieldItem(schema.fields.length),
      ],
    );
  }

  // The privacy related settings for the account profile.
  Widget buildPrivacy({required AccountCredentialSchema schema}) {
    return ListView(
      children: [
        SwitchListTile(
          title: Text(AppLocalizations.of(context)?.txt_profile_locked ?? "Locked Account"),
          subtitle: Text(
            AppLocalizations.of(context)?.desc_profile_locked ?? "Manually approved followers",
            style: labelStyle,
          ),
          value: schema.locked,
          secondary: Icon(schema.locked ? Icons.lock_person : Icons.lock_open, size: iconSize),
          onChanged: (bool value) => onChanged(schema: schema.copyWith(locked: value)),
        ),
        SwitchListTile(
          title: Text(AppLocalizations.of(context)?.txt_profile_discoverable ?? "Discoverable in Public"),
          subtitle: Text(
            AppLocalizations.of(context)?.desc_profile_discoverable ?? "Account can be discoverable in public",
            style: labelStyle,
          ),
          value: schema.discoverable,
          secondary: Icon(schema.discoverable ? Icons.travel_explore : Icons.disabled_by_default_rounded, size: iconSize),
          onChanged: (bool value) => onChanged(schema: schema.copyWith(discoverable: value)),
        ),
        SwitchListTile(
          title: Text(AppLocalizations.of(context)?.txt_profile_post_indexable ?? "Indexable by Search Engines"),
          subtitle: Text(
            AppLocalizations.of(context)?.desc_profile_post_indexable ?? "Allow search engines to index your posts",
            style: labelStyle,
          ),
          value: schema.indexable,
          secondary: Icon(schema.indexable ? Icons.search : Icons.disabled_by_default_rounded, size: iconSize),
          onChanged: (bool value) => onChanged(schema: schema.copyWith(indexable: value)),
        ),
        SwitchListTile(
          title: Text(AppLocalizations.of(context)?.txt_profile_hide_collections ?? "Hide Collections"),
          subtitle: Text(
            AppLocalizations.of(context)?.desc_profile_hide_collections ?? "Hide collections from the profile",
            style: labelStyle,
          ),
          value: !schema.hideCollections,
          secondary: Icon(schema.hideCollections ? Icons.visibility_off : Icons.private_connectivity, size: iconSize),
          onChanged: (bool value) => onChanged(schema: schema.copyWith(hideCollections: !value)),
        ),
      ],
    );
  }

  // Build the attribute field item for the account profile. It allows users to add custom fields
  // to their profile, such as custom attributes or additional information.
  Widget buildFieldItem(int index) {
    final FieldSchema? field = index >= (schema?.fields.length ?? -1) ? null : schema?.fields[index];
    final (TextEditingController nameController, TextEditingController valueController) = fieldControllers[index];

    nameController.text = field?.name ?? '';
    valueController.text = field?.value ?? '';

    final List<IconData> icons = [
      Icons.looks_one_rounded,
      Icons.looks_two_rounded,
      Icons.looks_3_rounded,
      Icons.looks_4_rounded,
      Icons.looks_5_rounded,
      Icons.looks_6_rounded,
    ];

    return Focus(
      onFocusChange: (focused) {
        if (focused) { return; }
        onFieldEditCompleted(index);
      },
      child: ListTile(
        leading: Icon(icons[index % icons.length], size: iconSize),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: TextField(
                controller: nameController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => onFieldEditCompleted(index),
              ),
            ),
            Flexible(
              child: TextField(
                controller: valueController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => onFieldEditCompleted(index),
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
          onPressed: () {
            if (index >= (schema?.fields.length ?? 0)) {
              return;
            }

            final List<FieldSchema> fields = List.from(schema!.fields);
            fields.removeAt(index);
            onChanged(schema: schema!.copyWith(fields: fields));
          },
        ),
      ),
    );
  }

  // The callback to check the attribute field input and update the schema.
  void onFieldEditCompleted(int index) async {
    final (TextEditingController nameController, TextEditingController valueController) = fieldControllers[index];

    final String name = nameController.text.trim();
    final String value = valueController.text.trim();
    final List<FieldSchema> fields = List.from(schema!.fields);

    if (name.isEmpty || value.isEmpty) {
      if (index < (schema?.fields.length ?? 0)) {
        fields.removeAt(index);
        onChanged(schema: schema!.copyWith(fields: fields));
      }
      return;
    }

    final FieldSchema field = FieldSchema(name: name, value: value);
    index < (schema?.fields.length ?? 0) ? fields[index] = field : fields.add(field);
    onChanged(schema: schema!.copyWith(fields: fields));
  }

  // The callback to check the text field input and update the schema.
  void onEditCompleted() async {
    final String name = nameController.text.trim();
    final String note = noteController.text.trim();

    final AccountCredentialSchema? updatedSchema = schema?.copyWith(
      displayName: name.isNotEmpty ? name : null,
      note: note,
    );

    if (updatedSchema != null) { onChanged(schema: updatedSchema); }
  }

  void onChanged({required AccountCredentialSchema schema}) async {
    final AccessStatusSchema? status = ref.read(accessStatusProvider);
    final AccountSchema? account = await status?.updateAccount(schema);

    ref.read(accessStatusProvider.notifier).state = status?.copyWith(account: account);
    setState(() => this.schema = account?.toCredentialSchema() ?? schema);
  }
}

// vim: set ts=2 sw=2 sts=2 et:
