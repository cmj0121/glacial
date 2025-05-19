// The engineer mode to control the app with DEV purpose.
import 'package:flutter/material.dart';

import 'package:glacial/core.dart';
import 'package:glacial/routes.dart';

class EnginnerMode extends StatelessWidget {
  const EnginnerMode({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: buildContent(context),
          ),
        ),
      ),
    );
  }

  Widget buildContent(BuildContext context) {
    final Storage storage = Storage();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text("Engineering Mode", style: Theme.of(context).textTheme.headlineLarge),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.delete),
          title: const Text("Clean-up Storage"),
          onTap: () async => await storage.purge(),
        ),

        const Spacer(),
        TextButton.icon(
          icon: const Icon(Icons.refresh),
          label: const Text("Refresh"),
          onPressed: () => context.go(RoutePath.landing.path),
        ),
      ],
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
