// The backable widget that can be used to show the back button and the optional
// title of the widget.
import 'package:flutter/material.dart';

import 'package:glacial/core.dart';

class BackableView extends StatefulWidget {
  final String? title;
  final Widget child;

  const BackableView({
    super.key,
    this.title,
    required this.child,
  });

  @override
  State<BackableView> createState() => _BackableViewState();
}

class _BackableViewState extends State<BackableView> {
  bool isDisposed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: useLiquidGlass,
      appBar: AdaptiveGlassAppBar(
        leading: AdaptiveGlassIconButton(
          icon: Icons.arrow_back_ios_new_rounded,
          onPressed: () => context.pop(),
        ),
        title: widget.title == null ? null : Text(widget.title!, style: Theme.of(context).textTheme.titleLarge),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: SafeArea(
          child: isDisposed ? const SizedBox.shrink() : buildContent(),
        ),
      ),
    );
  }

  Widget buildContent() {
    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.startToEnd,
      confirmDismiss: (_) async {
        setState(() => isDisposed = true);
        context.pop();
        return false;
      },
      child: widget.child,
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
