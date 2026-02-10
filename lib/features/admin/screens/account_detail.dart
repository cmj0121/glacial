// The admin account detail with moderation actions.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

class AdminAccountDetail extends ConsumerStatefulWidget {
  final AdminAccountSchema schema;

  const AdminAccountDetail({
    super.key,
    required this.schema,
  });

  @override
  ConsumerState<AdminAccountDetail> createState() => _AdminAccountDetailState();
}

class _AdminAccountDetailState extends ConsumerState<AdminAccountDetail> {
  late final AccessStatusSchema? status = ref.read(accessStatusProvider);
  late AdminAccountSchema adminAccount = widget.schema;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAccount(),
          const Divider(),
          _buildDetails(),
          const Divider(),
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildAccount() {
    return InkWellDone(
      onTap: () => context.push(RoutePath.profile.path, extra: adminAccount.account),
      child: Account(schema: adminAccount.account),
    );
  }

  Widget _buildDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (adminAccount.email.isNotEmpty)
          _detailRow(Icons.email, adminAccount.email),
        if (adminAccount.ip != null)
          _detailRow(Icons.computer, adminAccount.ip!),
        if (adminAccount.locale != null)
          _detailRow(Icons.language, adminAccount.locale!),
        _detailRow(Icons.calendar_today, adminAccount.createdAt.toIso8601String().split('T').first),
        _detailRow(Icons.check_circle, adminAccount.confirmed
            ? AppLocalizations.of(context)?.txt_admin_account_confirmed ?? 'Confirmed'
            : AppLocalizations.of(context)?.txt_admin_account_unconfirmed ?? 'Unconfirmed'),
        _detailRow(Icons.verified, adminAccount.approved
            ? AppLocalizations.of(context)?.txt_admin_account_approved ?? 'Approved'
            : AppLocalizations.of(context)?.txt_admin_account_not_approved ?? 'Not approved'),
        if (adminAccount.role != null)
          _detailRow(Icons.badge, adminAccount.role!.name),
      ],
    );
  }

  Widget _detailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }

  Widget _buildActions() {
    final List<AdminActionType> actions = _availableActions();

    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: actions.map((action) {
        return ElevatedButton.icon(
          icon: Icon(action.icon),
          label: Text(action.label(context)),
          style: action.isDangerous
              ? ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.errorContainer,
                  foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
                )
              : null,
          onPressed: () => _onAction(action),
        );
      }).toList(),
    );
  }

  List<AdminActionType> _availableActions() {
    switch (adminAccount.status) {
      case AdminAccountStatus.pending:
        return [AdminActionType.approve, AdminActionType.reject];
      case AdminAccountStatus.active:
        return [AdminActionType.silence, AdminActionType.suspend];
      case AdminAccountStatus.disabled:
        return [AdminActionType.enable];
      case AdminAccountStatus.silenced:
        return [AdminActionType.unsilence, AdminActionType.suspend];
      case AdminAccountStatus.suspended:
        return [AdminActionType.unsuspend];
    }
  }

  Future<void> _onAction(AdminActionType action) async {
    if (status == null) return;

    if (action.isDangerous) {
      final bool? confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppLocalizations.of(context)?.txt_admin_confirm_action ?? 'Confirm Action'),
          content: Text(AppLocalizations.of(context)?.desc_admin_confirm_action ?? 'This action cannot be easily undone. Are you sure?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(AppLocalizations.of(context)?.btn_close ?? 'Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              child: Text(action.label(context)),
            ),
          ],
        ),
      );

      if (confirmed != true) return;
    }

    late AdminAccountSchema updated;

    switch (action) {
      case AdminActionType.approve:
        updated = await status!.approveAccount(adminAccount.id);
        break;
      case AdminActionType.reject:
        updated = await status!.rejectAccount(adminAccount.id);
        break;
      case AdminActionType.suspend:
        await status!.performAccountAction(adminAccount.id, type: 'suspend');
        updated = await status!.getAdminAccount(adminAccount.id);
        break;
      case AdminActionType.silence:
        await status!.performAccountAction(adminAccount.id, type: 'silence');
        updated = await status!.getAdminAccount(adminAccount.id);
        break;
      case AdminActionType.enable:
        updated = await status!.enableAccount(adminAccount.id);
        break;
      case AdminActionType.unsilence:
        updated = await status!.unsilenceAccount(adminAccount.id);
        break;
      case AdminActionType.unsuspend:
        updated = await status!.unsuspendAccount(adminAccount.id);
        break;
      case AdminActionType.unsensitive:
        updated = await status!.unsensitiveAccount(adminAccount.id);
        break;
      default:
        return;
    }

    if (mounted) {
      setState(() => adminAccount = updated);
    }
  }
}

// vim: set ts=2 sw=2 sts=2 et:
