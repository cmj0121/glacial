// The system preference settings to control the app's behavior and features.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      ],
    );
  }

  // Build the engineer settings that are not meant for the general user.
  Widget buildEngineerSettings() {
    final Storage storage = Storage();

    // The list of button to clear the cache or reset the app.
    return ListView(
      children: [
        ListTile(
          title: Text(AppLocalizations.of(context)?.btn_preference_engineer_clear_cache ?? "Clear All Cache"),
          subtitle: Text(AppLocalizations.of(context)?.desc_preference_engineer_clear_cache ?? "Clear all cached data and reset the app."),
          leading: Icon(Icons.delete_outline_outlined, size: iconSize, color: Theme.of(context).colorScheme.error),
          onTap: () async {
            await storage.purge();

            if (mounted) {
              final String message = AppLocalizations.of(context)?.msg_preference_engineer_clear_cache ?? "Cache cleared successfully.";
              await showSnackbar(context, message);
            }
          },
        ),
      ],
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
