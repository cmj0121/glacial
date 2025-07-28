// The system preference settings to control the app's behavior and features.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';

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
    final double size = 24;
    final String text = AppLocalizations.of(context)?.btn_exit ?? "Exit";

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const Spacer(),
        TextButton.icon(
          icon: Icon(Icons.exit_to_app, size: size),
          label: Text(text, style: TextStyle(fontSize: size)),
          onPressed: () => context.go(RoutePath.landing.path),
        ),
      ],
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
