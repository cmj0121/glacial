// The v2 welcome/landing screen with staggered entrance animation.
import 'package:flutter/material.dart';

import 'package:glacial/core.dart';
import 'package:glacial/v2/core.dart';

class V2LandingScreen extends StatefulWidget {
  const V2LandingScreen({super.key});

  @override
  State<V2LandingScreen> createState() => _V2LandingScreenState();
}

class _V2LandingScreenState extends State<V2LandingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _breathe;

  @override
  void initState() {
    super.initState();
    _breathe = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _breathe.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: V2CenteredLayout(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: V2Theme.spacingXL),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // Logo with breathing scale
                FadeSlideIn(
                  child: AnimatedBuilder(
                    animation: _breathe,
                    builder: (context, child) {
                      final scale = 1.0 + (_breathe.value * 0.03);
                      return Transform.scale(scale: scale, child: child);
                    },
                    child: Image.asset(
                      'assets/images/icon.png',
                      width: V2Theme.logoSize,
                      height: V2Theme.logoSize,
                    ),
                  ),
                ),
                const SizedBox(height: V2Theme.spacingXXL),

                // Title
                FadeSlideIn(
                  delay: const Duration(milliseconds: 200),
                  child: Text(
                    'GLACIAL',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      letterSpacing: 12,
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                ),
                const SizedBox(height: V2Theme.spacingMD),

                // Tagline
                FadeSlideIn(
                  delay: const Duration(milliseconds: 400),
                  child: Text(
                    l10n?.txt_v2_tagline ?? 'A calm space for social conversations',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: V2Theme.spacing3XL),

                // Get Started button
                FadeSlideIn(
                  delay: const Duration(milliseconds: 600),
                  child: SizedBox(
                    width: double.infinity,
                    child: Semantics(
                      button: true,
                      label: l10n?.btn_v2_get_started ?? 'Get Started',
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(vertical: V2Theme.spacingLG),
                        ),
                        onPressed: () => context.go(RoutePath.v2Servers.path),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(l10n?.btn_v2_get_started ?? 'Get Started'),
                            const SizedBox(width: V2Theme.spacingSM),
                            const Icon(Icons.arrow_forward, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const Spacer(flex: 3),

                // Footer
                FadeSlideIn(
                  delay: const Duration(milliseconds: 800),
                  child: Text(
                    'Powered by cmj',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.disabledColor,
                    ),
                  ),
                ),
                const SizedBox(height: V2Theme.spacingLG),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
