// The instance info bottom sheet showing the current server details.
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

// Bottom sheet that displays detailed information about the connected server.
class InstanceInfoSheet extends StatelessWidget {
  final AccessStatusSchema? status;

  const InstanceInfoSheet({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final ServerSchema? server = status?.server;

    final AppLocalizations? l10n = AppLocalizations.of(context);
    final TextTheme textTheme = Theme.of(context).textTheme;

    if (server == null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: NoResult(
          message: l10n?.err_invalid_instance(status?.domain ?? '') ?? 'No server info',
          icon: Icons.info_outline,
        ),
      );
    }

    final String registrationStatus = server.registration.enabled
        ? (server.registration.approvalRequired
            ? l10n?.txt_instance_approval_required ?? 'Approval Required'
            : l10n?.txt_instance_open ?? 'Open')
        : l10n?.txt_instance_closed ?? 'Closed';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n?.btn_drawer_instance_info ?? 'About This Server', style: textTheme.titleMedium),
          const SizedBox(height: 16),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                buildThumbnail(context, server),
                const SizedBox(height: 12),
                Text(server.title, style: textTheme.headlineSmall),
                const SizedBox(height: 4),
                Text(server.domain, style: textTheme.bodySmall),
                const SizedBox(height: 12),
                Text(server.desc, style: textTheme.bodyMedium),
                const SizedBox(height: 16),
                buildInfoTile(context, Icons.dns_outlined, l10n?.txt_instance_version ?? 'Version', 'v${server.version}'),
                buildInfoTile(context, Icons.people_outline, l10n?.txt_instance_active_users ?? 'Active Users (Monthly)', '${server.usage.userActiveMonthly}'),
                buildInfoTile(context, Icons.contact_mail_outlined, l10n?.txt_instance_contact ?? 'Contact', server.contact.email.isEmpty ? '-' : server.contact.email),
                buildInfoTile(context, Icons.language, l10n?.txt_instance_languages ?? 'Languages', server.languages.join(', ')),
                buildInfoTile(context, Icons.app_registration, l10n?.txt_instance_registration ?? 'Registration', registrationStatus),
                if (server.rules.isNotEmpty)
                  buildRulesTile(context, server.rules),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildThumbnail(BuildContext context, ServerSchema server) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: server.thumbnail,
        height: 120,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (context, url) => SizedBox(
          height: 120,
          child: ShimmerEffect(child: ColoredBox(color: Theme.of(context).colorScheme.surfaceContainerHighest)),
        ),
        errorWidget: (context, url, error) => const ImageErrorPlaceholder(),
      ),
    );
  }

  Widget buildInfoTile(BuildContext context, IconData icon, String label, String value) {
    return ListTile(
      dense: true,
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
      title: Text(label, style: Theme.of(context).textTheme.bodySmall),
      trailing: Text(value, style: Theme.of(context).textTheme.bodyMedium),
    );
  }

  Widget buildRulesTile(BuildContext context, List<RuleSchema> rules) {
    return InkWellDone(
      onTap: () => showAdaptiveGlassDialog(
        context: context,
        builder: (context) => ServerRules(rules: rules),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(Icons.rule_outlined, color: Theme.of(context).colorScheme.primary, size: 20),
        title: Text(
          AppLocalizations.of(context)?.txt_server_rules ?? 'Server Rules',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        trailing: Text('${rules.length}', style: Theme.of(context).textTheme.bodyMedium),
      ),
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
