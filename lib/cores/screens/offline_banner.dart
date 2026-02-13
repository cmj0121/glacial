// The offline banner widget for indicating network unavailability.
import 'package:flutter/material.dart';

import 'package:glacial/l10n/app_localizations.dart';

class OfflineBanner extends StatelessWidget {
  final bool isOffline;

  const OfflineBanner({super.key, required this.isOffline});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return SizeTransition(sizeFactor: animation, child: child);
      },
      child: isOffline
          ? Container(
              key: const ValueKey('offline_banner'),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              color: Theme.of(context).colorScheme.errorContainer,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cloud_off,
                    size: 16,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context)?.txt_offline_banner ?? 'You are offline',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
