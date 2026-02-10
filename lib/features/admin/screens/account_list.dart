// The paginated admin account list with filter chips.
import 'package:flutter/material.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

class AdminAccountList extends StatefulWidget {
  final AccessStatusSchema status;

  const AdminAccountList({
    super.key,
    required this.status,
  });

  @override
  State<AdminAccountList> createState() => _AdminAccountListState();
}

class _AdminAccountListState extends State<AdminAccountList> with PaginatedListMixin {
  List<AdminAccountSchema> accounts = [];
  AdminAccountStatus? selectedStatus;
  AdminAccountOrigin? selectedOrigin;

  @override
  void initState() {
    super.initState();
    onLoad();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildFilterChips(),
          buildLoadingIndicator(),
          Flexible(child: buildContent()),
        ],
      ),
    );
  }

  Widget buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            FilterChip(
              label: Text(_statusLabel(null)),
              selected: selectedStatus == null,
              onSelected: (_) => _onStatusFilter(null),
            ),
            const SizedBox(width: 8),
            ...AdminAccountStatus.values.map((status) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(_statusLabel(status)),
                  selected: selectedStatus == status,
                  onSelected: (_) => _onStatusFilter(status),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  String _statusLabel(AdminAccountStatus? status) {
    if (status == null) {
      return AppLocalizations.of(context)?.btn_search ?? 'All';
    }

    switch (status) {
      case AdminAccountStatus.active:
        return AppLocalizations.of(context)?.txt_admin_account_active ?? 'Active';
      case AdminAccountStatus.pending:
        return AppLocalizations.of(context)?.txt_admin_account_pending ?? 'Pending';
      case AdminAccountStatus.disabled:
        return AppLocalizations.of(context)?.txt_admin_account_disabled ?? 'Disabled';
      case AdminAccountStatus.silenced:
        return AppLocalizations.of(context)?.txt_admin_account_silenced ?? 'Silenced';
      case AdminAccountStatus.suspended:
        return AppLocalizations.of(context)?.txt_admin_account_suspended ?? 'Suspended';
    }
  }

  void _onStatusFilter(AdminAccountStatus? status) {
    setState(() {
      selectedStatus = status;
      accounts.clear();
    });
    resetPagination();
    onLoad();
  }

  Widget buildContent() {
    if (accounts.isEmpty && !isLoading) {
      return NoResult(
        message: AppLocalizations.of(context)?.txt_admin_no_accounts ?? "No accounts found",
      );
    }

    return ListView.builder(
      itemCount: accounts.length,
      itemBuilder: (context, index) {
        final AdminAccountSchema adminAccount = accounts[index];
        return _buildAccountTile(adminAccount);
      },
    );
  }

  Widget _buildAccountTile(AdminAccountSchema adminAccount) {
    return AdaptiveGlassCard(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      onTap: () => context.push(RoutePath.adminAccount.path, extra: adminAccount),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(child: Account(schema: adminAccount.account)),
            const SizedBox(width: 8),
            Chip(
              label: Text(
                _statusLabel(adminAccount.status),
                style: Theme.of(context).textTheme.labelSmall,
              ),
              backgroundColor: _statusColor(adminAccount.status),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(AdminAccountStatus status) {
    switch (status) {
      case AdminAccountStatus.active:
        return Theme.of(context).colorScheme.primaryContainer;
      case AdminAccountStatus.pending:
        return Theme.of(context).colorScheme.tertiaryContainer;
      case AdminAccountStatus.disabled:
        return Theme.of(context).colorScheme.surfaceContainerHighest;
      case AdminAccountStatus.silenced:
        return Theme.of(context).colorScheme.secondaryContainer;
      case AdminAccountStatus.suspended:
        return Theme.of(context).colorScheme.errorContainer;
    }
  }

  Future<void> onLoad() async {
    if (shouldSkipLoad) return;

    setLoading(true);

    final List<AdminAccountSchema> newAccounts = await widget.status.fetchAdminAccounts(
      status: selectedStatus,
      origin: selectedOrigin,
    );

    if (mounted) {
      setState(() => accounts.addAll(newAccounts));
      markLoadComplete(isEmpty: newAccounts.isEmpty);
    }
  }
}

// vim: set ts=2 sw=2 sts=2 et:
