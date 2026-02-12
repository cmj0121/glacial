// The account picker bottom sheet for multi-account switching.
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';

// Bottom sheet that displays saved accounts for quick switching.
class AccountPickerSheet extends ConsumerStatefulWidget {
  final AccessStatusSchema? status;

  const AccountPickerSheet({super.key, required this.status});

  @override
  ConsumerState<AccountPickerSheet> createState() => _AccountPickerSheetState();
}

class _AccountPickerSheetState extends ConsumerState<AccountPickerSheet> {
  List<SavedAccountSchema> accounts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => onLoad());
  }

  Future<void> onLoad() async {
    final Storage storage = Storage();
    final List<SavedAccountSchema> saved = await storage.loadSavedAccounts();

    if (mounted) {
      setState(() {
        accounts = saved;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final String title = l10n?.txt_account_picker_title ?? 'Accounts';

    if (isLoading) return const ClockProgressIndicator();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: accounts.length,
              itemBuilder: (context, index) => buildAccountTile(accounts[index]),
            ),
          ),
          const SizedBox(height: 8),
          buildAddAccountButton(context),
        ],
      ),
    );
  }

  Widget buildAccountTile(SavedAccountSchema saved) {
    final bool isCurrent = widget.status?.account?.id == saved.accountId &&
        widget.status?.domain == saved.domain;

    return Dismissible(
      key: ValueKey(saved.compositeKey),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Theme.of(context).colorScheme.error,
        child: Icon(Icons.delete, color: Theme.of(context).colorScheme.onError),
      ),
      confirmDismiss: (_) async => !isCurrent,
      onDismissed: (_) => onRemoveAccount(saved),
      child: ListTile(
        leading: ClipOval(
          child: CachedNetworkImage(
            imageUrl: saved.avatar,
            width: 40,
            height: 40,
            fit: BoxFit.cover,
            placeholder: (_, __) => const SizedBox(width: 40, height: 40),
            errorWidget: (_, __, ___) => const Icon(Icons.person),
          ),
        ),
        title: Text(
          saved.displayName.isNotEmpty ? saved.displayName : saved.username,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '@${saved.username}@${saved.domain}',
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.grey),
        ),
        trailing: isCurrent ? const Icon(Icons.check_circle, color: Colors.green) : null,
        onTap: isCurrent ? null : () => onSwitchAccount(saved),
      ),
    );
  }

  Widget buildAddAccountButton(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: const Icon(Icons.person_add),
        label: Text(l10n?.btn_account_picker_add ?? 'Add Account'),
        onPressed: onAddAccount,
      ),
    );
  }

  Future<void> onAddAccount() async {
    final AccessStatusSchema? status = widget.status;
    final String? domain = status?.domain;

    if (status == null || domain == null || domain.isEmpty) {
      return;
    }

    Navigator.of(context).pop();

    // Clear webview cookies so the Mastodon server shows a fresh login
    // form instead of auto-signing-in with the previous account's session.
    await WebViewCookieManager().clearCookies();

    final Uri uri = await status.authorize(domain: domain, state: const Uuid().v4());
    if (mounted) {
      context.push(RoutePath.webview.path, extra: uri);
    }
  }

  Future<void> onSwitchAccount(SavedAccountSchema saved) async {
    final Storage storage = Storage();
    await storage.switchToAccount(saved, ref: ref);

    if (mounted) {
      final l10n = AppLocalizations.of(context);
      final String message = l10n?.msg_account_switched(saved.username) ?? 'Switched to ${saved.username}';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      Navigator.of(context).pop();

      ref.read(reloadProvider.notifier).state = !ref.read(reloadProvider);
    }
  }

  Future<void> onRemoveAccount(SavedAccountSchema saved) async {
    final Storage storage = Storage();
    await storage.removeSavedAccount(saved.compositeKey);

    if (mounted) {
      final l10n = AppLocalizations.of(context);
      final String message = l10n?.msg_account_removed ?? 'Account removed';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      setState(() {
        accounts.removeWhere((a) => a.compositeKey == saved.compositeKey);
      });
    }
  }

}

// vim: set ts=2 sw=2 sts=2 et:
