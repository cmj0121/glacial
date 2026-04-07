import 'package:flutter/material.dart';
import 'package:glacial/v2/theme.dart';

/// Centers content with a max-width constraint.
/// Full-width on iPhone, centered 480px on iPad/Mac.
class V2CenteredLayout extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const V2CenteredLayout({
    super.key,
    required this.child,
    this.maxWidth = V2Theme.maxContentWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
// vim: set ts=2 sw=2 sts=2 et:
