// The system preference settings to control the app's behavior and features.
import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:duration/duration.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';

class SystemPreference extends ConsumerStatefulWidget {
  const SystemPreference({super.key});

  @override
  ConsumerState<SystemPreference> createState() => _SystemPreferenceState();
}

class _SystemPreferenceState extends ConsumerState<SystemPreference> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContentWidth),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: _buildContent(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final double size = 18;
    final String text = AppLocalizations.of(context)?.btn_reload ?? "Reload";

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Expanded(flex: 10, child: _buildTabView()),
        const Spacer(),
        TextButton.icon(
          icon: Icon(Icons.refresh, size: size, color: Theme.of(context).colorScheme.secondary),
          label: Text(text, style: TextStyle(fontSize: size, color: Theme.of(context).colorScheme.secondary)),
          onPressed: () => ref.read(reloadProvider.notifier).state = !ref.read(reloadProvider),
        ),
      ],
    );
  }

  Widget _buildTabView() {
    final List<SystemPreferenceType> types = SystemPreferenceType.values;

    return SwipeTabView(
      itemCount: types.length,
      tabBuilder: (BuildContext context, int index) {
        final bool selected = index == selectedIndex;
        return Tooltip(
          message: types[index].tooltip(context),
          child: Icon(
            types[index].icon(active: selected),
            size: tabSize,
            color: selected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface,
          ),
        );
      },
      itemBuilder: (BuildContext context, int index) {
        switch (types[index]) {
          case SystemPreferenceType.theme:
            return _buildSystemSettings();
          case SystemPreferenceType.engineer:
            return _buildEngineerSettings();
          case SystemPreferenceType.about:
            return _buildAppInfo();
        }
      },
    );
  }

  // ── System settings ──────────────────────────────────────────────

  Widget _buildSystemSettings() {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final SystemPreferenceSchema schema = ref.watch(preferenceProvider) ?? SystemPreferenceSchema();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      children: [
        const SizedBox(height: 8),

        // ── APPEARANCE ──
        _sectionLabel(theme, AppLocalizations.of(context)?.txt_preference_appearance ?? 'APPEARANCE'),
        const SizedBox(height: 12),
        _toggleCard(
          theme: theme, scheme: scheme,
          title: AppLocalizations.of(context)?.txt_desc_preference_system_theme ?? 'Dark mode',
          icon: schema.theme == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
          value: schema.theme == ThemeMode.dark,
          onChanged: (v) {
            Storage().savePreference(schema.copyWith(theme: v ? ThemeMode.dark : ThemeMode.light), ref: ref);
          },
        ),
        if (schema.theme == ThemeMode.dark) ...[
          const SizedBox(height: 8),
          _toggleCard(
            theme: theme, scheme: scheme,
            title: AppLocalizations.of(context)?.txt_preference_oled_theme ?? 'OLED Dark Theme',
            subtitle: AppLocalizations.of(context)?.desc_preference_oled_theme ?? 'Pure black background',
            icon: schema.useOledTheme ? Icons.brightness_1 : Icons.brightness_1_outlined,
            value: schema.useOledTheme,
            onChanged: (v) {
              Storage().savePreference(schema.copyWith(useOledTheme: v), ref: ref);
              ref.read(reloadProvider.notifier).state = !ref.read(reloadProvider);
            },
          ),
        ],
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.4)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            leading: Icon(Icons.format_size, size: 22, color: scheme.onSurfaceVariant),
            title: Text(AppLocalizations.of(context)?.txt_preference_font_scale ?? 'Font Size'),
            subtitle: Slider(
              value: schema.fontScale,
              min: 0.8, max: 1.4, divisions: 6,
              label: '${(schema.fontScale * 100).round()}%',
              onChanged: (v) => Storage().savePreference(schema.copyWith(fontScale: v), ref: ref),
            ),
          ),
        ),
        const SizedBox(height: 8),
        _toggleCard(
          theme: theme, scheme: scheme,
          title: AppLocalizations.of(context)?.txt_preference_haptic ?? 'Haptic Feedback',
          subtitle: AppLocalizations.of(context)?.desc_preference_haptic ?? 'Vibrate on interactions',
          icon: schema.hapticFeedback ? Icons.vibration : Icons.smartphone,
          value: schema.hapticFeedback,
          onChanged: (v) => Storage().savePreference(schema.copyWith(hapticFeedback: v), ref: ref),
        ),
        const SizedBox(height: 8),
        _buildLocaleSelector(schema: schema, theme: theme, scheme: scheme),
        const SizedBox(height: 8),
        _toggleCard(
          theme: theme, scheme: scheme,
          title: AppLocalizations.of(context)?.txt_preference_in_app_browser ?? 'In-App Browser',
          subtitle: AppLocalizations.of(context)?.desc_preference_in_app_browser ?? 'Open links in WebView instead of native browser',
          icon: schema.useInAppBrowser ? Icons.web : Icons.open_in_browser,
          value: schema.useInAppBrowser,
          onChanged: (v) => Storage().savePreference(schema.copyWith(useInAppBrowser: v), ref: ref),
        ),

        const SizedBox(height: 24),

        // ── POSTING ──
        _sectionLabel(theme, AppLocalizations.of(context)?.txt_preference_status ?? 'POSTING'),
        const SizedBox(height: 12),
        _selectorCard(
          theme: theme, scheme: scheme,
          title: AppLocalizations.of(context)?.txt_preference_sensitive ?? 'Default Visibility',
          icon: schema.visibility.icon(),
          current: schema.visibility.tooltip(context),
          subtitle: schema.visibility.description(context),
          options: VisibilityType.values,
          selected: schema.visibility,
          labelOf: (v) => v.tooltip(context),
          iconOf: (v) => v.icon(),
          onSelected: (v) => Storage().savePreference(schema.copyWith(visibility: v), ref: ref),
        ),
        const SizedBox(height: 8),
        _toggleCard(
          theme: theme, scheme: scheme,
          title: AppLocalizations.of(context)?.txt_preference_sensitive ?? 'Sensitive Content',
          subtitle: AppLocalizations.of(context)?.desc_preference_sensitive ?? 'Mark media as sensitive by default',
          icon: schema.sensitive ? Icons.visibility_off : Icons.visibility,
          value: schema.sensitive,
          onChanged: (v) => Storage().savePreference(schema.copyWith(sensitive: v), ref: ref),
        ),
        const SizedBox(height: 8),
        _selectorCard(
          theme: theme, scheme: scheme,
          title: AppLocalizations.of(context)?.desc_quote_policy ?? 'Quote Policy',
          icon: schema.quotePolicy.icon,
          current: schema.quotePolicy.title(context),
          subtitle: schema.quotePolicy.description(context),
          options: QuotePolicyType.values,
          selected: schema.quotePolicy,
          labelOf: (v) => v.title(context),
          iconOf: (v) => v.icon,
          onSelected: (v) => Storage().savePreference(schema.copyWith(quotePolicy: v), ref: ref),
        ),
        const SizedBox(height: 8),
        _selectorCard(
          theme: theme, scheme: scheme,
          title: 'Reply Tags',
          icon: schema.replyTag.icon(),
          current: schema.replyTag.tooltip(context),
          subtitle: schema.replyTag.description(context),
          options: ReplyTagType.values,
          selected: schema.replyTag,
          labelOf: (v) => v.tooltip(context),
          iconOf: (v) => v.icon(),
          onSelected: (v) => Storage().savePreference(schema.copyWith(replyTag: v), ref: ref),
        ),

        const SizedBox(height: 24),

        // ── TIMELINE ──
        _sectionLabel(theme, AppLocalizations.of(context)?.txt_preference_timeline ?? 'TIMELINE'),
        const SizedBox(height: 12),
        _toggleCard(
          theme: theme, scheme: scheme,
          title: AppLocalizations.of(context)?.txt_preference_hide_replies ?? 'Hide Replies',
          subtitle: AppLocalizations.of(context)?.desc_preference_hide_replies,
          icon: schema.hideReplies ? Icons.speaker_notes_off : Icons.speaker_notes,
          value: schema.hideReplies,
          onChanged: (v) => Storage().savePreference(schema.copyWith(hideReplies: v), ref: ref),
        ),
        const SizedBox(height: 8),
        _toggleCard(
          theme: theme, scheme: scheme,
          title: AppLocalizations.of(context)?.txt_preference_hide_reblogs ?? 'Hide Reblogs',
          subtitle: AppLocalizations.of(context)?.desc_preference_hide_reblogs,
          icon: schema.hideReblogs ? Icons.repeat_on : Icons.repeat,
          value: schema.hideReblogs,
          onChanged: (v) => Storage().savePreference(schema.copyWith(hideReblogs: v), ref: ref),
        ),
        const SizedBox(height: 8),
        _toggleCard(
          theme: theme, scheme: scheme,
          title: AppLocalizations.of(context)?.txt_preference_auto_play ?? 'Auto-play Videos',
          subtitle: AppLocalizations.of(context)?.desc_preference_auto_play,
          icon: schema.autoPlayVideo ? Icons.play_circle : Icons.play_circle_outline,
          value: schema.autoPlayVideo,
          onChanged: (v) => Storage().savePreference(schema.copyWith(autoPlayVideo: v), ref: ref),
        ),
        const SizedBox(height: 8),
        _toggleCard(
          theme: theme, scheme: scheme,
          title: AppLocalizations.of(context)?.txt_preference_loaded_top ?? 'Load Newest on Launch',
          subtitle: AppLocalizations.of(context)?.desc_preference_loaded_top,
          icon: schema.loadedTop ? Icons.vertical_align_top : Icons.vertical_align_center,
          value: schema.loadedTop,
          onChanged: (v) => Storage().savePreference(schema.copyWith(loadedTop: v), ref: ref),
        ),
        const SizedBox(height: 8),
        _selectorCard<int>(
          theme: theme, scheme: scheme,
          title: AppLocalizations.of(context)?.txt_preference_refresh_interval ?? 'Refresh Interval',
          icon: Icons.refresh,
          current: schema.refreshInterval.inSeconds == 0
              ? 'Off'
              : schema.refreshInterval.pretty(abbreviated: true, delimiter: ' '),
          options: const [0, 10, 30, 60, 120],
          selected: schema.refreshInterval.inSeconds,
          labelOf: (v) => v == 0 ? 'Off' : Duration(seconds: v).pretty(abbreviated: true, delimiter: ' '),
          onSelected: (v) => Storage().savePreference(
            schema.copyWith(refreshInterval: Duration(seconds: v)), ref: ref,
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  // ── Reusable widgets ─────────────────────────────────────────────

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

  Widget _toggleCard({
    required ThemeData theme,
    required ColorScheme scheme,
    required String title,
    String? subtitle,
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
        subtitle: subtitle != null
            ? Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant))
            : null,
        value: value,
        secondary: Icon(icon, size: 22, color: scheme.onSurfaceVariant),
        onChanged: onChanged,
      ),
    );
  }

  /// A card that shows the current value and opens a bottom sheet with
  /// all options when tapped — replaces the old tap-to-cycle pattern.
  Widget _selectorCard<T>({
    required ThemeData theme,
    required ColorScheme scheme,
    required String title,
    required IconData icon,
    required String current,
    String? subtitle,
    required List<T> options,
    required T selected,
    required String Function(T) labelOf,
    IconData Function(T)? iconOf,
    required ValueChanged<T> onSelected,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Icon(icon, size: 22, color: scheme.onSurfaceVariant),
        title: Text(title, style: theme.textTheme.bodyMedium),
        subtitle: subtitle != null
            ? Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant))
            : null,
        trailing: Text(current, style: theme.textTheme.labelMedium?.copyWith(color: scheme.primary)),
        onTap: () => showAdaptiveGlassSheet(
          context: context,
          builder: (_) => SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Container(
                    width: 32, height: 2,
                    decoration: BoxDecoration(color: scheme.primary, borderRadius: BorderRadius.circular(1)),
                  ),
                  const SizedBox(height: 16),
                  ...options.map((opt) {
                    final bool isSelected = opt == selected;
                    return InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        Navigator.of(context).pop();
                        onSelected(opt);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                        child: Row(
                          children: [
                            Icon(
                              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                              size: 20, color: isSelected ? scheme.primary : scheme.outline,
                            ),
                            if (iconOf != null) ...[
                              const SizedBox(width: 12),
                              Icon(iconOf(opt), size: 18, color: scheme.onSurfaceVariant),
                            ],
                            const SizedBox(width: 12),
                            Text(labelOf(opt), style: theme.textTheme.bodyMedium),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLocaleSelector({
    required SystemPreferenceSchema schema,
    required ThemeData theme,
    required ColorScheme scheme,
  }) {
    final Locale locale = schema.locale ?? WidgetsBinding.instance.platformDispatcher.locale;
    final String text = LocaleNames.of(context)!.nameOf(locale.languageCode) ?? locale.languageCode;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Icon(Icons.translate, size: 22, color: scheme.onSurfaceVariant),
        title: Text(AppLocalizations.of(context)?.desc_preference_locale ?? 'Language'),
        trailing: Text(text, style: theme.textTheme.labelMedium?.copyWith(color: scheme.primary)),
        onTap: () => showAdaptiveGlassDialog(
          context: context,
          builder: (BuildContext ctx) {
            final List<Locale> locales = AppLocalizations.supportedLocales;
            return ListView.builder(
              shrinkWrap: true,
              itemCount: locales.length,
              itemBuilder: (BuildContext ctx, int index) {
                final Locale item = locales[index];
                final String name = '[${item.languageCode}] ${LocaleNames.of(ctx)?.nameOf(item.languageCode) ?? ""}';
                final bool selected = item.languageCode == locale.languageCode;
                return ListTile(
                  leading: selected
                      ? Icon(Icons.check, size: tabSize, color: scheme.primary)
                      : const SizedBox(width: 24),
                  title: Text(name),
                  onTap: () {
                    ctx.pop();
                    Storage().savePreference(schema.copyWith(locale: item), ref: ref);
                    ref.read(reloadProvider.notifier).state = !ref.read(reloadProvider);
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  // ── Engineer settings ────────────────────────────────────────────

  Widget _buildEngineerSettings() {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final Storage storage = Storage();
    final DefaultCacheManager cacheManager = DefaultCacheManager();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      children: [
        const SizedBox(height: 8),
        _sectionLabel(theme, AppLocalizations.of(context)?.btn_preference_engineer ?? 'DEVELOPER'),
        const SizedBox(height: 12),
        ListTile(
          title: Text(AppLocalizations.of(context)?.btn_preference_engineer_clear_cache ?? 'Clear All Cache'),
          subtitle: Text(AppLocalizations.of(context)?.desc_preference_engineer_clear_cache ?? 'Clear all cached data.',
            style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
          leading: Icon(Icons.delete_outline, size: 22, color: scheme.error),
          onTap: () async {
            await cacheManager.emptyCache();
            if (mounted) {
              showSnackbar(context, AppLocalizations.of(context)?.msg_preference_engineer_clear_cache ?? 'Cache cleared.');
            }
          },
        ),
        ListTile(
          title: Text(AppLocalizations.of(context)?.btn_preference_engineer_test_notifier ?? 'Test Notification'),
          subtitle: Text(AppLocalizations.of(context)?.desc_preference_engineer_test_notifier ?? 'Send a dummy notification.',
            style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
          leading: Icon(Icons.notifications, size: 22, color: scheme.tertiary),
          onTap: () => _sendDummyNotification(),
        ),
        const SizedBox(height: 16),
        ListTile(
          title: Text(AppLocalizations.of(context)?.btn_preference_engineer_reset ?? 'Reset System'),
          subtitle: Text(AppLocalizations.of(context)?.desc_preference_engineer_reset ?? 'Clear all settings and reset.',
            style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
          leading: Icon(Icons.restart_alt, size: 22, color: scheme.error),
          onTap: () async {
            final bool confirmed = await showConfirmDialog(
              context: context,
              title: AppLocalizations.of(context)?.btn_preference_engineer_reset ?? 'Reset',
              message: AppLocalizations.of(context)?.msg_confirm_reset ?? 'This cannot be undone.',
            );
            if (!confirmed || !mounted) return;
            await storage.purge();
            if (mounted) {
              showSnackbar(context, AppLocalizations.of(context)?.msg_preference_engineer_reset ?? 'Reset complete.');
            }
          },
        ),
      ],
    );
  }

  // ── About ────────────────────────────────────────────────────────

  Widget _buildAppInfo() {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final PackageInfo info = Info().info!;
    final String author = 'cmj <cmj@cmj.tw>';
    final String repo = 'https://github.com/cmj0121';
    final String link = 'https://apps.apple.com/app/6745746223';
    final TextStyle? sub = theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      children: [
        const SizedBox(height: 8),
        _sectionLabel(theme, AppLocalizations.of(context)?.btn_preference_about ?? 'ABOUT'),
        const SizedBox(height: 12),
        ListTile(
          leading: Icon(Icons.numbers, size: 22, color: scheme.onSurfaceVariant),
          title: Text(AppLocalizations.of(context)?.txt_about_app_version ?? 'App Version'),
          subtitle: Text('${info.version} (${info.buildNumber})', style: sub),
          onTap: () => launchUrl(Uri.parse(link), mode: LaunchMode.externalApplication),
        ),
        ListTile(
          leading: Icon(Icons.person, size: 22, color: scheme.onSurfaceVariant),
          title: Text(AppLocalizations.of(context)?.txt_about_author ?? 'Author'),
          subtitle: Text(author, style: sub),
          onTap: () => launchUrl(Uri.parse(repo), mode: LaunchMode.externalApplication),
        ),
        ListTile(
          leading: Icon(Icons.code, size: 22, color: scheme.onSurfaceVariant),
          title: Text(AppLocalizations.of(context)?.txt_about_repository ?? 'Repository'),
          subtitle: Text(repo, style: sub),
          onTap: () => launchUrl(Uri.parse('$repo/${info.appName}'), mode: LaunchMode.externalApplication),
        ),
        ListTile(
          leading: Icon(Icons.copyright, size: 22, color: scheme.onSurfaceVariant),
          title: Text(AppLocalizations.of(context)?.txt_about_copyright ?? 'Copyright'),
          subtitle: Text('© $author', style: sub),
          onTap: () => launchUrl(Uri.parse('$repo/${info.appName}?tab=License-1-ov-file'), mode: LaunchMode.externalApplication),
        ),
      ],
    );
  }

  Future<void> _sendDummyNotification() async {
    showSnackbar(context, AppLocalizations.of(context)?.msg_test_notification_pending ?? 'Test notification in 5 seconds...');
    Future.delayed(const Duration(seconds: 5), () {
      final state = WidgetsBinding.instance.lifecycleState;
      switch (state) {
        case AppLifecycleState.paused:
        case AppLifecycleState.inactive:
        case AppLifecycleState.detached:
          sendLocalNotification('...', '...', badgeNumber: 999);
          return;
        default:
          AppBadgePlus.updateBadge(0);
          showSnackbar(context, AppLocalizations.of(context)?.msg_test_notification_foreground ?? 'Notifications require background.');
          return;
      }
    });
  }
}

// vim: set ts=2 sw=2 sts=2 et:
