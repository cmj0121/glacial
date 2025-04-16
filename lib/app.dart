import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class GlacialApp extends StatefulWidget {
  const GlacialApp({super.key});

  @override
  State<GlacialApp> createState() => _GlacialAppState();
}

class _GlacialAppState extends State<GlacialApp> {
  String? title;

  @override
  void initState() {
    super.initState();
    load();
  }

  void load() async {
    final info = await PackageInfo.fromPlatform();

    setState(() {
      title = info.appName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: title,

      // The theme mode
      themeMode: ThemeMode.dark,
      theme: ThemeData(useMaterial3: true, brightness: Brightness.light),
      darkTheme: ThemeData(useMaterial3: true, brightness: Brightness.dark),
      // The home page of the app.
      home: Glacial(),
    );
  }
}

class Glacial extends StatelessWidget {
  const Glacial({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SafeArea(child: buildContent()));
  }

  Widget buildContent() {
    return Center(child: Text("Hello, Glacial!"));
  }
}

// vim: set ts=2 sw=2 sts=2 et:
