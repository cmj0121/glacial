// The system preference settings to control the app's behavior and features.
import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:duration/duration.dart';
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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: buildContent(),
          ),
        ),
      ),
    );
  }

  Widget buildContent() {
    final double size = 18;
    final String text = AppLocalizations.of(context)?.btn_reload ?? "Reload";

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Expanded(flex: 10, child: buildTabView()),
        const Spacer(),
        TextButton.icon(
          icon: Icon(Icons.refresh, size: size, color: Theme.of(context).colorScheme.secondary),
          label: Text(text, style: TextStyle(fontSize: size, color: Theme.of(context).colorScheme.secondary)),
          onPressed: () => ref.read(reloadProvider.notifier).state = !ref.read(reloadProvider),
        ),
      ],
    );
  }

  // Build the tab view that contains the settings per category.
  Widget buildTabView() {
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
        final SystemPreferenceType type = types[index];
        late final Widget child;

        switch (type) {
          case SystemPreferenceType.theme:
            child = buildSystemSettings();
          case SystemPreferenceType.engineer:
            child = buildEngineerSettings();
          case SystemPreferenceType.about:
            child = buildAppInfo();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
          child: child,
        );
      }
    );
  }

  // Build the system-wide settings that control the app's behavior and features.
  Widget buildSystemSettings() {
    final SystemPreferenceSchema schema = ref.watch(preferenceProvider) ?? SystemPreferenceSchema();
    final TextStyle? labelStyle = Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).disabledColor);

    return ListView(
      children: <Widget>[
        SwitchListTile(
          title: Text(AppLocalizations.of(context)?.txt_desc_preference_system_theme ?? "The system theme"),
          value: schema.theme == ThemeMode.dark,
          secondary: Icon(schema.theme == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode, size: iconSize),
          onChanged: (bool value) {
            final ThemeMode theme = value ? ThemeMode.dark : ThemeMode.light;
            Storage().savePreference(schema.copyWith(theme: theme), ref: ref);
          },
        ),

        const SizedBox(height: 32),

        ListTile(
          title: Text(AppLocalizations.of(context)?.txt_preference_status ?? "Status Settings"),
          subtitle: Text(
            AppLocalizations.of(context)?.desc_preference_status ?? "Control the default status settings.",
            style: labelStyle,
          ),
        ),
        SwitchListTile(
          title: Text(AppLocalizations.of(context)?.txt_preference_sensitive ?? "Sensitive Content"),
          subtitle: Text(
            AppLocalizations.of(context)?.desc_preference_sensitive ?? "Show/Hide sensitive content in statuses.",
            style: labelStyle,
          ),
          value: schema.sensitive,
          secondary: Icon(schema.sensitive ? Icons.visibility_off : Icons.visibility, size: iconSize),
          onChanged: (bool value) {
            Storage().savePreference(schema.copyWith(sensitive: value), ref: ref);
          },
        ),
        // Build the default status settings, including the visibility and spoiler text.
        ListTile(
          title: Text(schema.visibility.tooltip(context)),
          subtitle: Text(schema.visibility.description(context), style: labelStyle),
          leading: Icon(schema.visibility.icon(), size: iconSize),
          onTap: () async {
            final int index = VisibilityType.values.indexOf(schema.visibility);
            final int nextIndex = (index + 1) % VisibilityType.values.length;
            Storage().savePreference(
              schema.copyWith(visibility: VisibilityType.values[nextIndex]),
              ref: ref,
            );
          },
        ),
        // Build the reply tag settings.
        ListTile(
          title: Text(schema.replyTag.tooltip(context)),
          subtitle: Text(schema.replyTag.description(context), style: labelStyle),
          leading: Icon(schema.replyTag.icon(), size: iconSize),
          onTap: () async {
            final int index = ReplyTagType.values.indexOf(schema.replyTag);
            final int nextIndex = (index + 1) % ReplyTagType.values.length;

            Storage().savePreference(schema.copyWith(replyTag: ReplyTagType.values[nextIndex]), ref: ref);
          },
        ),
        // Build the refresh interval settings.
        ListTile(
          title: Text(AppLocalizations.of(context)?.txt_preference_refresh_interval ?? "Refresh Interval"),
          subtitle: Text(
            AppLocalizations.of(context)?.desc_preference_refresh_interval ?? "The interval to refresh the app's data.",
            style: labelStyle,
          ),
          leading: Icon(Icons.refresh, size: iconSize),
          trailing: Text(
            schema.refreshInterval.pretty(abbreviated: true, delimiter: " "),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface),
          ),
          onTap: () async {
            final List<int> intervals = const [0, 10, 30, 60, 120];

            final int index = intervals.indexOf(schema.refreshInterval.inSeconds);
            final int nextIndex = (index + 1) % intervals.length;

            Storage().savePreference(
              schema.copyWith(refreshInterval: Duration(seconds: intervals[nextIndex])),
              ref: ref,
            );
          },
        ),
      ],
    );
  }

  // Build the engineer settings that are not meant for the general user.
  Widget buildEngineerSettings() {
    final Storage storage = Storage();
    final DefaultCacheManager cacheManager = DefaultCacheManager();

    // The list of button to clear the cache or reset the app.
    return ListView(
      children: [
        ListTile(
          title: Text(AppLocalizations.of(context)?.btn_preference_engineer_clear_cache ?? "Clear All Cache"),
          subtitle: Text(AppLocalizations.of(context)?.desc_preference_engineer_clear_cache ?? "Clear all cached data."),
          leading: Icon(Icons.delete_outline_outlined, size: iconSize, color: Theme.of(context).colorScheme.error),
          onTap: () async {
            await cacheManager.emptyCache();

            if (mounted) {
              final String message = AppLocalizations.of(context)?.msg_preference_engineer_clear_cache ?? "Cache cleared successfully.";
              await showSnackbar(context, message);
            }
          },
        ),
        ListTile(
          title: Text(AppLocalizations.of(context)?.btn_preference_engineer_test_notifier ?? "Test Notification"),
          subtitle: Text(
            AppLocalizations.of(context)?.desc_preference_engineer_test_notifier ?? "Send a dummy notification to test the notification system.",
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).disabledColor),
          ),
          leading: Icon(Icons.notifications, size: iconSize, color: Theme.of(context).colorScheme.tertiary),
          onTap: () => sendDummyNotification(),
        ),
        const SizedBox(height: 16),
        ListTile(
          title: Text(AppLocalizations.of(context)?.btn_preference_engineer_reset ?? "Reset system"),
          subtitle: Text(AppLocalizations.of(context)?.desc_preference_engineer_reset ?? "Clear all settings and reset the app."),
          leading: Icon(Icons.restart_alt, size: iconSize, color: Theme.of(context).colorScheme.error),
          onTap: () async {
            await storage.purge();

            if (mounted) {
              final String message = AppLocalizations.of(context)?.msg_preference_engineer_reset ?? "Settings cleared successfully.";
              await showSnackbar(context, message);
            }
          },
        ),
      ],
    );
  }

  // Build the app information section.
  Widget buildAppInfo() {
    final PackageInfo info = Info().info!;
    final String author = "cmj <cmj@cmj.tw>";
    final String repo = "https://github.com/cmj0121";
    final String link = "https://apps.apple.com/app/6745746223";
    final TextStyle? labelStyle = Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).disabledColor);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: Icon(Icons.numbers, size: iconSize),
          title: Text("App Version"),
          subtitle: Text('${info.version} (${info.buildNumber})', style: labelStyle),
          onTap: () => launchUrl(Uri.parse(link), mode: LaunchMode.externalApplication),
        ),
        ListTile(
          leading: Icon(Icons.person, size: iconSize),
          title: Text("Author"),
          subtitle: Text(author, style: labelStyle),
          onTap: () => launchUrl(Uri.parse(repo), mode: LaunchMode.externalApplication),
        ),
        ListTile(
          leading: Icon(Icons.code, size: iconSize),
          title: Text("Repository"),
          subtitle: Text(repo, style: labelStyle),
          onTap: () => launchUrl(Uri.parse("$repo/${info.appName}"), mode: LaunchMode.externalApplication),
        ),
        ListTile(
          leading: Icon(Icons.copyright, size: iconSize),
          title: Text("Copyright"),
          subtitle: Text("© $author", style: labelStyle),
          onTap: () => launchUrl(Uri.parse("$repo/${info.appName}?tab=License-1-ov-file"), mode: LaunchMode.externalApplication),
        ),
      ],
    );
  }

  // The dummy notification to send in local device.
  Future<void> sendDummyNotification() async {
    showSnackbar(context, "Dummy notification will be sent in 5 seconds ...");

    Future.delayed(const Duration(seconds: 5), () {
      final state = WidgetsBinding.instance.lifecycleState;
      switch (state) {
        case AppLifecycleState.paused:
        case AppLifecycleState.inactive:
        case AppLifecycleState.detached:
          sendLocalNotification("...", "...", badgeNumber: 999);
          return;
        default:
          AppBadgePlus.updateBadge(0);
          showSnackbar(context, "It should not send the notification while the app is in foreground.");
          return;
      }
    });
  }
}

// vim: set ts=2 sw=2 sts=2 et:
