// The main application and define the global variables.
import 'package:flutter/material.dart';

import 'package:glacial/core.dart';
import 'package:glacial/routes.dart';

class GlacialApp extends StatelessWidget {
  const GlacialApp({super.key});

  @override
  Widget build(BuildContext context) {
    final info = Info().info;

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: info == null ? "Glacial" : '${info.appName} (v${info.version})',

      // The theme mode
      themeMode: ThemeMode.dark,
      theme: ThemeData(useMaterial3: true, brightness: Brightness.light),
      darkTheme: ThemeData(useMaterial3: true, brightness: Brightness.dark),

      // The router implementation
      routerConfig: router,
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
