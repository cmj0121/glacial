// The edit page for the account profile, allowing users to edit their profile.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';

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
          tooltip: AppLocalizations.of(context)?.btn_edit_profile ?? 'Edit profile',
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
  static const double _maxWidth = 680;
  static const int _bioMaxLength = 500;
  final int maxFieldsCount = 4;
  final List<EditProfileCategory> categories = EditProfileCategory.values;

  late final TabController controller;

  late AccessStatusSchema? status = ref.read(accessStatusProvider);
  late AccountCredentialSchema schema = widget.account.toCredentialSchema();

  late final TextEditingController nameController = TextEditingController(text: schema.displayName);
  late final TextEditingController noteController = TextEditingController(text: schema.note.trim());
  late final List<(TextEditingController, TextEditingController)> fieldControllers;

  bool _saving = false;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    controller = TabController(length: categories.length, vsync: this);
    nameController.addListener(_markDirty);
    noteController.addListener(_markDirty);
    fieldControllers = List.generate(maxFieldsCount, (index) {
      if (index < schema.fields.length) {
        final FieldSchema field = schema.fields[index];
        return (TextEditingController(text: field.name), TextEditingController(text: field.value));
      }
      return (TextEditingController(), TextEditingController());
    });
  }

  @override
  void dispose() {
    nameController.removeListener(_markDirty);
    noteController.removeListener(_markDirty);
    controller.dispose();
    nameController.dispose();
    noteController.dispose();
    for (final c in fieldControllers) {
      c.$1.dispose();
      c.$2.dispose();
    }
    super.dispose();
  }

  void _markDirty() {
    if (!_dirty) setState(() => _dirty = true);
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onFocusChange: (_) => _onSave(),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxWidth),
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
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
        switch (categories[index]) {
          case EditProfileCategory.general:
            return _buildGeneral();
          case EditProfileCategory.privacy:
            return _buildPrivacy();
          case EditProfileCategory.defaults:
            return _buildDefaults();
        }
      },
    );
  }

  Widget _buildGeneral() {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        const SizedBox(height: 12),
        _buildImageZone(theme, scheme),
        const SizedBox(height: 24),
        _sectionLabel(theme, AppLocalizations.of(context)?.btn_profile_general_info ?? 'GENERAL INFO'),
        const SizedBox(height: 12),
        _buildTextField(
          controller: nameController,
          icon: Icons.text_fields_outlined,
          hint: AppLocalizations.of(context)?.txt_profile_general_name ?? 'Display Name',
          onSubmitted: (v) => _onChanged(schema: schema.copyWith(displayName: v.trim())),
        ),
        const SizedBox(height: 8),
        _buildTextField(
          controller: noteController,
          icon: Icons.description_outlined,
          hint: AppLocalizations.of(context)?.txt_profile_general_bio ?? 'Bio',
          maxLines: 4,
          isPopUp: true,
          onSubmitted: (v) => _onChanged(schema: schema.copyWith(note: v.trim())),
        ),
        _buildBioCounter(theme, scheme),
        const SizedBox(height: 8),
        _buildToggleCard(
          theme: theme,
          scheme: scheme,
          title: AppLocalizations.of(context)?.txt_profile_bot ?? 'Bot account',
          subtitle: AppLocalizations.of(context)?.desc_profile_bot ?? 'Mark this account as a bot',
          icon: schema.bot ? Icons.smart_toy : Icons.person,
          value: schema.bot,
          onChanged: (v) => _onChanged(schema: schema.copyWith(bot: v)),
        ),
        const SizedBox(height: 24),
        _buildFieldsSection(theme, scheme),
        const SizedBox(height: 24),
        _buildSaveButton(scheme),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildPrivacy() {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        const SizedBox(height: 12),
        _sectionLabel(theme, AppLocalizations.of(context)?.btn_profile_privacy ?? 'PRIVACY SETTINGS'),
        const SizedBox(height: 12),
        _buildToggleCard(
          theme: theme,
          scheme: scheme,
          title: AppLocalizations.of(context)?.txt_profile_locked ?? 'Locked Account',
          subtitle: AppLocalizations.of(context)?.desc_profile_locked ?? 'Manually approved followers',
          icon: schema.locked ? Icons.lock_person : Icons.lock_open,
          value: schema.locked,
          onChanged: (v) => _onChanged(schema: schema.copyWith(locked: v)),
        ),
        const SizedBox(height: 8),
        _buildToggleCard(
          theme: theme,
          scheme: scheme,
          title: AppLocalizations.of(context)?.txt_profile_discoverable ?? 'Discoverable',
          subtitle: AppLocalizations.of(context)?.desc_profile_discoverable ?? 'Account can be discoverable in public',
          icon: schema.discoverable ? Icons.travel_explore : Icons.visibility_off,
          value: schema.discoverable,
          onChanged: (v) => _onChanged(schema: schema.copyWith(discoverable: v)),
        ),
        const SizedBox(height: 8),
        _buildToggleCard(
          theme: theme,
          scheme: scheme,
          title: AppLocalizations.of(context)?.txt_profile_post_indexable ?? 'Indexable',
          subtitle: AppLocalizations.of(context)?.desc_profile_post_indexable ?? 'Allow search engines to index',
          icon: schema.indexable ? Icons.search : Icons.search_off,
          value: schema.indexable,
          onChanged: (v) => _onChanged(schema: schema.copyWith(indexable: v)),
        ),
        const SizedBox(height: 8),
        _buildToggleCard(
          theme: theme,
          scheme: scheme,
          title: AppLocalizations.of(context)?.txt_profile_hide_collections ?? 'Hide Collections',
          subtitle: AppLocalizations.of(context)?.desc_profile_hide_collections ?? 'Hide collections from the profile',
          icon: schema.hideCollections ? Icons.visibility_off : Icons.visibility,
          value: !schema.hideCollections,
          onChanged: (v) => _onChanged(schema: schema.copyWith(hideCollections: !v)),
        ),
        const SizedBox(height: 24),
        _buildSaveButton(scheme),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildDefaults() {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final AppLocalizations? l10n = AppLocalizations.of(context);
    final String currentPrivacy = schema.sourcePrivacy ?? 'public';
    final VisibilityType currentVisibility = VisibilityType.values.firstWhere(
      (v) => v.name == currentPrivacy,
      orElse: () => VisibilityType.public,
    );

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        const SizedBox(height: 12),
        _sectionLabel(theme, l10n?.txt_profile_default_visibility ?? 'DEFAULT VISIBILITY'),
        const SizedBox(height: 12),
        ...VisibilityType.values.map((vis) {
          final bool selected = vis == currentVisibility;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: selected ? scheme.primary : scheme.outlineVariant.withValues(alpha: 0.4),
                  width: selected ? 1.5 : 1,
                ),
                borderRadius: BorderRadius.circular(12),
                color: selected ? scheme.primary.withValues(alpha: 0.06) : null,
              ),
              child: ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                leading: Icon(vis.icon(), size: 22, color: selected ? scheme.primary : scheme.onSurfaceVariant),
                title: Text(vis.tooltip(context), style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: selected ? FontWeight.w600 : null,
                  color: selected ? scheme.primary : null,
                )),
                subtitle: Text(vis.description(context), style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                trailing: selected
                    ? Icon(Icons.check_circle, size: 20, color: scheme.primary)
                    : null,
                onTap: () => _onChanged(schema: schema.copyWith(sourcePrivacy: vis.name)),
              ),
            ),
          );
        }),
        const SizedBox(height: 24),
        _sectionLabel(theme, l10n?.txt_profile_default_media ?? 'MEDIA'),
        const SizedBox(height: 12),
        _buildToggleCard(
          theme: theme,
          scheme: scheme,
          title: l10n?.txt_profile_sensitive_media ?? 'Mark media as sensitive',
          subtitle: l10n?.desc_profile_sensitive_media ?? 'Hide media behind a warning by default',
          icon: (schema.sourceSensitive ?? false) ? Icons.warning_amber : Icons.image,
          value: schema.sourceSensitive ?? false,
          onChanged: (v) => _onChanged(schema: schema.copyWith(sourceSensitive: v)),
        ),
        const SizedBox(height: 24),
        _sectionLabel(theme, l10n?.txt_profile_default_language ?? 'LANGUAGE'),
        const SizedBox(height: 12),
        _buildTextField(
          controller: TextEditingController(text: schema.sourceLanguage ?? ''),
          icon: Icons.translate,
          hint: l10n?.txt_profile_language_hint ?? 'ISO 639-1 (e.g. en, ja, zh)',
          onSubmitted: (v) => _onChanged(schema: schema.copyWith(sourceLanguage: v.trim().isEmpty ? null : v.trim())),
        ),
        const SizedBox(height: 24),
        _buildSaveButton(scheme),
        const SizedBox(height: 24),
      ],
    );
  }

  // Privacy/bot toggles wrapped in a subtle card for visual grouping.
  Widget _buildToggleCard({
    required ThemeData theme,
    required ColorScheme scheme,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(title, style: theme.textTheme.bodyMedium),
        subtitle: Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
        value: value,
        secondary: Icon(icon, size: 22, color: scheme.onSurfaceVariant),
        onChanged: onChanged,
      ),
    );
  }

  // Bio character counter — subtle right-aligned text.
  Widget _buildBioCounter(ThemeData theme, ColorScheme scheme) {
    final int remaining = _bioMaxLength - noteController.text.length;
    final Color color = remaining < 0
        ? scheme.error
        : remaining < 50
            ? scheme.tertiary
            : scheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.only(top: 4, right: 4),
      child: Align(
        alignment: Alignment.centerRight,
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 150),
          style: theme.textTheme.labelSmall!.copyWith(color: color),
          child: Text('$remaining'),
        ),
      ),
    );
  }

  // Banner + avatar with camera-icon overlay and live display name.
  Widget _buildImageZone(ThemeData theme, ColorScheme scheme) {
    final double avatarSize = 72;
    return SizedBox(
      height: 180,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Banner
          Positioned.fill(
            bottom: avatarSize / 2 - 10,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: _onChangeBanner,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    schema.header == null
                        ? CachedNetworkImage(
                            imageUrl: widget.account.header,
                            fit: BoxFit.cover,
                            placeholder: (_, _) => ShimmerEffect(child: ColoredBox(color: scheme.surfaceContainerHighest)),
                            errorWidget: (_, _, _) => const ImageErrorPlaceholder(),
                          )
                        : Image.file(schema.header!, fit: BoxFit.cover),
                    // Gradient scrim
                    Positioned(
                      left: 0, right: 0, bottom: 0, height: 72,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black.withValues(alpha: 0.55)],
                          ),
                        ),
                      ),
                    ),
                    // Live display name preview
                    Positioned(
                      left: avatarSize + 12,
                      right: 40,
                      bottom: 10,
                      child: ListenableBuilder(
                        listenable: nameController,
                        builder: (context, _) => Text(
                          nameController.text.isNotEmpty ? nameController.text : widget.account.acct,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 8,
                      bottom: 8,
                      child: _cameraChip(scheme),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Avatar
          Positioned(
            left: 12,
            bottom: 0,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: _onChangeAvatar,
              child: SizedBox(
                width: avatarSize,
                height: avatarSize,
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: scheme.surface, width: 3),
                        shape: BoxShape.circle,
                        color: scheme.surface,
                      ),
                      child: ClipOval(
                        child: schema.avatar == null
                            ? CachedNetworkImage(
                                imageUrl: widget.account.avatar,
                                fit: BoxFit.cover,
                                placeholder: (_, _) => ShimmerEffect(child: ColoredBox(color: scheme.surfaceContainerHighest)),
                                errorWidget: (_, _, _) => const ImageErrorPlaceholder(),
                              )
                            : Image.file(schema.avatar!, fit: BoxFit.cover),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: _cameraChip(scheme, small: true),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cameraChip(ColorScheme scheme, {bool small = false}) {
    final double size = small ? 22 : 28;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.85),
        shape: BoxShape.circle,
        border: Border.all(color: scheme.outlineVariant, width: 1),
      ),
      child: Icon(Icons.camera_alt, size: size * 0.55, color: scheme.onSurface),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    int maxLines = 1,
    bool isPopUp = false,
    required ValueChanged<String> onSubmitted,
  }) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    final decoration = InputDecoration(
      hintText: hint,
      isDense: true,
      prefixIcon: Icon(icon, size: 20, color: scheme.onSurfaceVariant),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: scheme.primary, width: 1.5),
      ),
    );

    if (isPopUp) {
      return PopUpTextField(
        controller: controller,
        decoration: decoration,
        onSubmitted: onSubmitted,
      );
    }

    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: decoration,
      onSubmitted: onSubmitted,
    );
  }

  // Custom fields section with add-field affordance.
  Widget _buildFieldsSection(ThemeData theme, ColorScheme scheme) {
    final bool canAdd = schema.fields.length < maxFieldsCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _sectionLabel(theme, AppLocalizations.of(context)?.txt_profile_custom_fields ?? 'CUSTOM FIELDS'),
            ),
            if (canAdd)
              TextButton.icon(
                icon: Icon(Icons.add, size: 16, color: scheme.primary),
                label: Text(
                  AppLocalizations.of(context)?.txt_profile_add_field ?? 'Add',
                  style: theme.textTheme.labelSmall?.copyWith(color: scheme.primary),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () {
                  final List<FieldSchema> fields = List.from(schema.fields);
                  fields.add(const FieldSchema(name: '', value: ''));
                  _onChanged(schema: schema.copyWith(fields: fields));
                },
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (schema.fields.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                AppLocalizations.of(context)?.txt_profile_no_fields ?? 'No custom fields yet',
                style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ),
          )
        else
          ...List.generate(schema.fields.length, (i) => _buildFieldItem(i, theme, scheme)),
      ],
    );
  }

  Widget _buildFieldItem(int index, ThemeData theme, ColorScheme scheme) {
    final (nameCtl, valueCtl) = fieldControllers[index];

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AccessibleDismissible(
        dismissKey: UniqueKey(),
        direction: DismissDirection.startToEnd,
        dismissLabel: AppLocalizations.of(context)?.lbl_swipe_remove,
        background: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          color: scheme.errorContainer,
          child: Icon(Icons.delete_forever_rounded, color: scheme.onErrorContainer, size: 22),
        ),
        confirmDismiss: (_) async {
          final List<FieldSchema> fields = List.from(schema.fields);
          if (index < fields.length) fields.removeAt(index);
          _onChanged(schema: schema.copyWith(fields: fields));
          return false;
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameCtl,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)?.txt_profile_field_label ?? 'Label',
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  border: InputBorder.none,
                ),
                onSubmitted: (v) => _onChangeField(index, FieldSchema(name: v.trim(), value: valueCtl.text.trim())),
              ),
              const SizedBox(height: 4),
              PopUpTextField(
                controller: valueCtl,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)?.txt_profile_field_value ?? 'Value',
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  border: InputBorder.none,
                ),
                onSubmitted: (v) => _onChangeField(index, FieldSchema(name: nameCtl.text.trim(), value: v.trim())),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Prominent save button at the bottom of each tab.
  Widget _buildSaveButton(ColorScheme scheme) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        icon: _saving
            ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: scheme.onPrimary))
            : const Icon(Icons.check, size: 18),
        label: Text(AppLocalizations.of(context)?.btn_save ?? 'Save'),
        onPressed: _saving ? null : _onSave,
      ),
    );
  }

  Widget _sectionLabel(ThemeData theme, String text) {
    return Text(
      text.toUpperCase(),
      style: theme.textTheme.labelSmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );
  }

  void _onChangeField(int index, FieldSchema field) {
    final List<FieldSchema> fields = List.from(schema.fields);
    index < fields.length ? fields[index] = field : fields.add(field);
    _onChanged(schema: schema.copyWith(fields: fields));
  }

  Future<void> _onChangeAvatar() async {
    final XFile? file = await _pickImage();
    if (file != null && mounted) setState(() => schema = schema.copyWith(avatar: File(file.path)));
  }

  Future<void> _onChangeBanner() async {
    final XFile? file = await _pickImage();
    if (file != null && mounted) setState(() => schema = schema.copyWith(header: File(file.path)));
  }

  Future<XFile?> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    return await picker.pickMedia();
  }

  void _onChanged({required AccountCredentialSchema schema}) {
    final AccountCredentialSchema updated = schema.copyWith(
      displayName: nameController.text.trim(),
      note: noteController.text.trim(),
    );
    setState(() {
      this.schema = updated;
      _dirty = true;
    });
  }

  Future<void> _onSave() async {
    if (_saving || !_dirty) return;
    setState(() => _saving = true);
    try {
      final AccountSchema? account = await status?.updateAccount(schema);
      if (mounted) {
        ref.read(accessStatusProvider.notifier).state = status?.copyWith(account: account);
        setState(() => _dirty = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context)?.btn_save ?? 'Saved'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          width: 160,
        ));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

// vim: set ts=2 sw=2 sts=2 et:
