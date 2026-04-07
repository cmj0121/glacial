// The account hub screen — shows all saved accounts across servers for quick
// selection, plus an option to add a new server/account.
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/v2/core.dart';

class V2AccountHubScreen extends ConsumerStatefulWidget {
  const V2AccountHubScreen({super.key});

  @override
  ConsumerState<V2AccountHubScreen> createState() => _V2AccountHubScreenState();
}

class _V2AccountHubScreenState extends ConsumerState<V2AccountHubScreen> {
  List<SavedAccountSchema> _accounts = [];
  bool _isLoading = true;
  String? _switchingKey;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAccounts());
  }

  Future<void> _loadAccounts() async {
    final List<SavedAccountSchema> saved = await Storage().loadSavedAccounts();
    saved.sort((a, b) => b.lastUsed.compareTo(a.lastUsed));

    if (mounted) {
      setState(() {
        _accounts = saved;
        _isLoading = false;
      });
    }
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
              children: [
                const Spacer(flex: 1),

                // Logo
                FadeSlideIn(
                  child: Image.asset(
                    'assets/images/icon.png',
                    width: V2Theme.logoSizeSM,
                    height: V2Theme.logoSizeSM,
                  ),
                ),
                const SizedBox(height: V2Theme.spacingMD),

                // Title
                FadeSlideIn(
                  delay: const Duration(milliseconds: 200),
                  child: Text(
                    'GLACIAL',
                    style: theme.textTheme.titleMedium?.copyWith(
                      letterSpacing: 8,
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                ),
                const SizedBox(height: V2Theme.spacingXXL),

                // Section heading
                FadeSlideIn(
                  delay: const Duration(milliseconds: 300),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      l10n?.txt_account_hub_title ?? 'Your Accounts',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: V2Theme.spacingSM),

                // Account list
                Expanded(
                  flex: 4,
                  child: FadeSlideIn(
                    delay: const Duration(milliseconds: 400),
                    child: _isLoading
                        ? const Center(child: ClockProgressIndicator())
                        : _buildAccountList(theme),
                  ),
                ),

                const SizedBox(height: V2Theme.spacingLG),

                // Add account button
                FadeSlideIn(
                  delay: const Duration(milliseconds: 600),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(vertical: V2Theme.spacingLG),
                      ),
                      icon: const Icon(Icons.person_add, size: 18),
                      label: Text(l10n?.btn_account_hub_add ?? 'Add Account'),
                      onPressed: () => context.push(RoutePath.v2Servers.path),
                    ),
                  ),
                ),

                const Spacer(flex: 1),

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

  Widget _buildAccountList(ThemeData theme) {
    // Group by domain.
    final Map<String, List<SavedAccountSchema>> grouped = {};
    for (final account in _accounts) {
      grouped.putIfAbsent(account.domain, () => []).add(account);
    }
    final List<String> domains = grouped.keys.toList()..sort();

    return ListView.builder(
      itemCount: domains.length,
      itemBuilder: (context, index) {
        final String domain = domains[index];
        final List<SavedAccountSchema> domainAccounts = grouped[domain]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (domains.length > 1) ...[
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 4, left: 4),
                child: Text(
                  domain,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
            ...domainAccounts.map((saved) => _buildAccountTile(theme, saved)),
          ],
        );
      },
    );
  }

  Widget _buildAccountTile(ThemeData theme, SavedAccountSchema saved) {
    final bool isSwitching = _switchingKey == saved.compositeKey;
    final l10n = AppLocalizations.of(context);

    return AccessibleDismissible(
      dismissKey: ValueKey(saved.compositeKey),
      direction: DismissDirection.endToStart,
      dismissLabel: l10n?.lbl_swipe_remove,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: theme.colorScheme.error,
        child: Icon(Icons.delete, color: theme.colorScheme.onError),
      ),
      onDismissed: (_) => _onRemoveAccount(saved),
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(V2Theme.borderRadius),
        ),
        child: ListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(V2Theme.borderRadius)),
          leading: ClipOval(
            child: CachedNetworkImage(
              imageUrl: saved.avatar,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              placeholder: (_, _) => const SizedBox(width: 40, height: 40),
              errorWidget: (_, _, _) => const Icon(Icons.person),
            ),
          ),
          title: Text(
            saved.displayName.isNotEmpty ? saved.displayName : saved.username,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            '@${saved.username}@${saved.domain}',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: theme.hintColor),
          ),
          trailing: isSwitching
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : Icon(Icons.chevron_right, size: 18, color: theme.colorScheme.onSurfaceVariant),
          onTap: isSwitching ? null : () => _onSwitchAccount(saved),
        ),
      ),
    );
  }

  Future<void> _onSwitchAccount(SavedAccountSchema saved) async {
    setState(() => _switchingKey = saved.compositeKey);

    try {
      final Storage storage = Storage();
      await storage.switchToAccount(saved, ref: ref);

      final AccessStatusSchema? status = ref.read(accessStatusProvider);
      final bool isSignedIn = status?.isSignedIn == true;

      if (!isSignedIn) {
        // Token was expired/revoked — switchToAccount already cleaned up.
        if (mounted) {
          final l10n = AppLocalizations.of(context);
          showSnackbar(context, l10n?.msg_account_hub_expired ?? 'Session expired. Account removed.');
          await _loadAccounts();
          if (_accounts.isEmpty && mounted) {
            context.go(RoutePath.v2Welcome.path);
          }
        }
        return;
      }

      if (!mounted) return;

      // Determine destination route (same logic as LandingPage).
      final timelinesAccess = status?.server?.config.timelinesAccess;
      final bool hasTimeline = SidebarButtonType.timeline.isAccessible(
        isSignedIn: isSignedIn, access: timelinesAccess,
      );
      final RoutePath route = hasTimeline ? RoutePath.timeline : RoutePath.trends;
      context.go(route.path);

      // Handle shared content pass-through.
      final SharedContentSchema? shared = ShareReceiver.consumePendingContent();
      if (shared != null && shared.hasContent && isSignedIn) {
        context.push(RoutePath.postShared.path, extra: shared);
      }
    } catch (e) {
      logger.e("Failed to switch account: $e");
      if (mounted) {
        showSnackbar(context, AppLocalizations.of(context)?.msg_network_error ?? 'Something went wrong. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _switchingKey = null);
    }
  }

  Future<void> _onRemoveAccount(SavedAccountSchema saved) async {
    await Storage().removeSavedAccount(saved.compositeKey);

    if (mounted) {
      final l10n = AppLocalizations.of(context);
      showSnackbar(context, l10n?.msg_account_removed ?? 'Account removed');
      setState(() {
        _accounts.removeWhere((a) => a.compositeKey == saved.compositeKey);
      });

      if (_accounts.isEmpty) {
        context.go(RoutePath.v2Welcome.path);
      }
    }
  }
}

// vim: set ts=2 sw=2 sts=2 et:
