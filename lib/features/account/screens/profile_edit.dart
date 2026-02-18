// The edit page for the account profile, allowing users to edit their profile.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';

// The edit page for the account profile, allowing users to edit their profile information.
class EditProfilePage extends ConsumerStatefulWidget {
  final AccountSchema account;

  const EditProfilePage({
    super.key,
    required this.account,
  });

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
  late AccountCredentialSchema schema = widget.account.toCredentialSchema();

  late final TextEditingController nameController = TextEditingController(text: schema.displayName);
  late final TextEditingController noteController = TextEditingController(text: schema.note.trim());
  late final List<(TextEditingController, TextEditingController)> fieldControllers;

  @override
  void initState() {
    super.initState();

    controller = TabController(length: categories.length, vsync: this);

    fieldControllers = List.generate(maxFieldsCount, (index) {
      if (index < schema.fields.length) {
        final FieldSchema field = schema.fields[index];
        return (TextEditingController(text: field.name), TextEditingController(text: field.value));
      } else {
        return (TextEditingController(), TextEditingController());
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();

    nameController.dispose();
    noteController.dispose();
    for (final c in fieldControllers) {
      c.$1.dispose();
      c.$2.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onFocusChange: (_) => onSave(),
      child: buildContent(),
    );
  }

  Widget buildContent() {
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
            return buildGeneral();
          case EditProfileCategory.privacy:
            return buildPrivacy();
        }
      },
    );
  }

  // The general settings for the account profile.
  Widget buildGeneral() {
    return ListView(
      children: [
        buildImageFields(size: 200),

        const Divider(),

        ListTile(
          leading: Tooltip(
            message: AppLocalizations.of(context)?.txt_profile_general_name ?? "Display Name",
            child: Icon(Icons.text_fields_outlined, size: iconSize),
          ),
          title: TextField(
            controller: nameController,
            style: Theme.of(context).textTheme.titleMedium,
            decoration: InputDecoration(border: InputBorder.none),
            onSubmitted: (String value) => onChanged(schema: schema.copyWith(displayName: value.trim())),
          ),
        ),
        ListTile(
          leading: Tooltip(
            message: AppLocalizations.of(context)?.txt_profile_general_bio ?? "Bio",
            child: Icon(Icons.description, size: iconSize),
          ),
          title: PopUpTextField(
            controller: noteController,
            style: Theme.of(context).textTheme.titleMedium,
            decoration: InputDecoration(border: InputBorder.none),
            onSubmitted: (String value) => onChanged(schema: schema.copyWith(note: value.trim())),
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
  Widget buildPrivacy() {
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
    final (TextEditingController nameController, TextEditingController valueController) = fieldControllers[index];

    return AccessibleDismissible(
      dismissKey: UniqueKey(),
      direction: DismissDirection.startToEnd,
      dismissLabel: AppLocalizations.of(context)?.lbl_swipe_remove,
      confirmDismiss: (_) async {
        final List<FieldSchema> fields = List.from(schema.fields);
        fields.removeAt(index);
        onChanged(schema: schema.copyWith(fields: fields));
        return false;
      },
      background: Container(
        alignment: Alignment.centerLeft,
        color: Theme.of(context).colorScheme.error,
        child: Icon(Icons.delete_forever_rounded, color: Theme.of(context).colorScheme.onError),
      ),
      child: ListTile(
        leading: Icon(FieldSchema.icons[index % FieldSchema.icons.length], size: iconSize),
        title: PopUpTextField(
          controller: valueController,
          decoration: InputDecoration(border: InputBorder.none),
          onSubmitted: (String value) => onChangeItem(
            index: index,
            field: FieldSchema(name: nameController.text.trim(), value: value.trim()),
          ),
        ),
        subtitle: PopUpTextField(
          controller: nameController,
          style: labelStyle,
          decoration: InputDecoration(border: InputBorder.none),
          onSubmitted: (String value) => onChangeItem(
            index: index,
            field: FieldSchema(name: value.trim(), value: valueController.text.trim()),
          ),
        ),
      ),
    );
  }

  // Build the fixed banner of the account profile and the avatar. It will be fixed in the top
  // of the screen.
  Widget buildImageFields({required double size}) {
    final double avatarSize = 80;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        height: size,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            buildBanner(),

            Positioned(
              left: 0,
              bottom: 0,
              width: avatarSize,
              height: avatarSize,
              child: buildAvatar(avatarSize),
            ),
          ],
        ),
      ),
    );
  }

  // Build the banner image for the account profile.
  Widget buildBanner() {
    final Widget banner = schema.header == null ?
        CachedNetworkImage(
          imageUrl: widget.account.header,
          placeholder: (context, url) => ShimmerEffect(child: ColoredBox(color: Theme.of(context).colorScheme.surfaceContainerHighest)),
          errorWidget: (context, url, error) => const ImageErrorPlaceholder(),
        ) :
        Image.file(schema.header!, fit: BoxFit.cover);

    return InkWellDone(
      onTap: onChangeBanner,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: OverflowBox(
          alignment: Alignment.center,
          maxWidth: double.infinity,
          maxHeight: double.infinity,
          child: MediaHero(onTap: onChangeAvatar, child: banner),
        ),
      ),
    );
  }

  // Build the avatar image for the account profile.
  Widget buildAvatar(double size) {
    final String avatarLabel = AppLocalizations.of(context)?.lbl_avatar ?? 'Avatar';
    final Widget avatar = Semantics(
      label: avatarLabel,
      child: schema.avatar == null ?
          CachedNetworkImage(
            imageUrl: widget.account.avatar,
            placeholder: (context, url) => ShimmerEffect(child: ColoredBox(color: Theme.of(context).colorScheme.surfaceContainerHighest)),
            errorWidget: (context, url, error) => const ImageErrorPlaceholder(),
            fit: BoxFit.cover,
          ) :
          Image.file(schema.avatar!, fit: BoxFit.cover),
    );

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant, width: 2),
        color: Theme.of(context).colorScheme.surface,
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: MediaHero(onTap: onChangeAvatar, child: avatar),
      ),
    );
  }

  void onChangeItem({required int index, required FieldSchema field}) {
    List<FieldSchema> fields = List.from(schema.fields);

    index < fields.length ? fields[index] = field : fields.add(field);
    onChanged(schema: schema.copyWith(fields: fields));
  }

  Future<void> onChangeAvatar() async {
    final XFile? file = await onImagePicker();
    if (mounted) setState(() => schema = schema.copyWith(avatar: file == null ? null : File(file.path)));
  }

  Future<void> onChangeBanner() async {
    final XFile? file = await onImagePicker();
    if (mounted) setState(() => schema = schema.copyWith(header: file == null ? null : File(file.path)));
  }

  // Pop-up the image picker and return the picked image path.
  Future<XFile?> onImagePicker() async {
    final ImagePicker picker = ImagePicker();
    return await picker.pickMedia();
  }

  Future<void> onChanged({required AccountCredentialSchema schema}) async {
    final AccountCredentialSchema updatedSchema = schema.copyWith(
      displayName: nameController.text.trim(),
      note: noteController.text.trim(),
    );
    setState(() => this.schema = updatedSchema);
  }

  Future<void> onSave() async {
    final AccountSchema? account = await status?.updateAccount(schema);
    if (mounted) {
      ref.read(accessStatusProvider.notifier).state = status?.copyWith(account: account);
    }
  }
}

// vim: set ts=2 sw=2 sts=2 et:
