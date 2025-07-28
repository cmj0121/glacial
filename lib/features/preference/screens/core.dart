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
        Expanded(child: buildTabView()),
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
    return buildSystemSettings();
  }

  // Build the system-wide settings that control the app's behavior and features.
  Widget buildSystemSettings() {
    final SystemPreferenceSchema schema = ref.watch(preferenceProvider) ?? SystemPreferenceSchema();

    return ListView(
      children: <Widget>[
        SwitchListTile(
          title: Text(AppLocalizations.of(context)?.txt_desc_preference_system_theme ?? "The system theme"),
          value: schema.theme == ThemeMode.dark,
          secondary: Icon(schema.theme == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode),
          onChanged: (bool value) {
            final ThemeMode theme = value ? ThemeMode.dark : ThemeMode.light;
            Storage().savePreference(schema.copyWith(theme: theme), ref: ref);
          },
        ),
      ],
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
