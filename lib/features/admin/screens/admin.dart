// The Admin dashboard with tabbed reports and accounts management.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

// The admin dashboard with tabs for reports and accounts.
class AdminTab extends ConsumerStatefulWidget {
  const AdminTab({super.key});

  @override
  ConsumerState<AdminTab> createState() => _AdminTabState();
}

class _AdminTabState extends ConsumerState<AdminTab> with SingleTickerProviderStateMixin {
  final List<AdminTabType> tabs = AdminTabType.values;
  late final AccessStatusSchema? status = ref.read(accessStatusProvider);
  late final TabController controller;

  @override
  void initState() {
    super.initState();
    controller = TabController(
      length: tabs.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (status?.isSignedIn != true) {
      return NoResult(
        message: AppLocalizations.of(context)?.txt_admin_no_permission ?? "Admin access required",
      );
    }

    final RoleSchema? role = status?.account?.role;
    if (role == null || !role.hasPrivilege) {
      return NoResult(
        message: AppLocalizations.of(context)?.txt_admin_no_permission ?? "Admin access required",
      );
    }

    return SwipeTabView(
      tabController: controller,
      itemCount: tabs.length,
      tabBuilder: (context, index) {
        final AdminTabType type = tabs[index];
        final bool isSelected = controller.index == index;
        final bool hasPermission = _hasTabPermission(role, type);
        final Color color = hasPermission
            ? isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface
            : Theme.of(context).disabledColor;

        return Tooltip(
          message: type.tooltip(context),
          child: Icon(type.icon(active: isSelected), color: color, size: tabSize),
        );
      },
      itemBuilder: (context, index) {
        final AdminTabType type = tabs[index];
        final bool hasPermission = _hasTabPermission(role, type);

        if (!hasPermission) {
          return NoResult(
            message: AppLocalizations.of(context)?.txt_admin_no_permission ?? "Admin access required",
          );
        }

        switch (type) {
          case AdminTabType.reports:
            return AdminReportList(status: status!);
          case AdminTabType.accounts:
            return AdminAccountList(status: status!);
        }
      },
      onTabTappable: (index) => _hasTabPermission(role, tabs[index]),
    );
  }

  bool _hasTabPermission(RoleSchema role, AdminTabType type) {
    switch (type) {
      case AdminTabType.reports:
        return role.hasPermission(PermissionBitmap.reports);
      case AdminTabType.accounts:
        return role.hasPermission(PermissionBitmap.users);
    }
  }
}

// vim: set ts=2 sw=2 sts=2 et:
