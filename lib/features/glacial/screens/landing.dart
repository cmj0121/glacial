// The Landing page to show the app icon and flip it.
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/routes.dart';
import 'package:glacial/features/glacial/models/server.dart';
import 'server.dart';

// The landing page that shows the icon of the app and flips intermittently.
class LandingPage extends ConsumerStatefulWidget {
  final Duration duration;

  const LandingPage({
    super.key,
    this.duration = const Duration(milliseconds: 800),
  });

  @override
  ConsumerState<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends ConsumerState<LandingPage> with SingleTickerProviderStateMixin {
  final Storage storage = Storage();
  static const int _engineerModeClickThreshold = 5;

  late final AnimationController controller;
  late final Animation<double> animation;

  bool flipX = true;
  int clickCount = 0;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(duration: widget.duration, vsync: this)
      ..repeat(reverse: true);

    animation = Tween<double>(begin: 0, end: pi).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
    ))
      ..addListener(() => setState(() {}))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          flipX = !flipX;
          controller.reset();
          controller.forward();
        }
      });

    controller.forward();
    preload();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          // The callback when the user clicks the icon, and may entry to the
          // engineer mode.
          child: InkWellDone(
            onTap: () => setState(() => clickCount++),
            child: buildContent(),
          ),
        ),
      ),
    );
  }

  Widget buildContent() {
    final Widget image = Image.asset('assets/images/logo.png');
    final Matrix4 transform = Matrix4.identity();
    transform.setEntry(3, 2, 0.001);
    flipX ? transform.rotateY(animation.value) : transform.rotateX(animation.value);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Transform(
          transform: transform,
          alignment: Alignment.center,
          child: image,
        );
      },
    );
  }

  // preload the necessary resources and navigate to the home page
  // if completed
  void preload() async {
    final String? server = await storage.loadLastServer();
    final String? accessToken = await storage.loadAccessToken(server);
    late ServerSchema? schema;

    schema = server == null ? null : await fetch(server);
    logger.i("preloading server schema from $server to $schema ...");

    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) {
      logger.i("completely preloaded ...");

      ref.read(currentServerProvider.notifier).state = schema;
      ref.read(currentAccessTokenProvider.notifier).state = accessToken;

      if (clickCount >= engineerModeClickCount) {
        logger.i("entering engineer mode ...");
        context.go(RoutePath.engineer.path);
        return;
      }
      context.go(schema == null ? RoutePath.explorer.path : RoutePath.home.path);
    }
  }
}

// vim: set ts=2 sw=2 sts=2 et:
