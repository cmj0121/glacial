// The single notification widget for rendering individual notification groups.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

class SingleNotification extends ConsumerStatefulWidget {
  final GroupSchema schema;

  const SingleNotification({
    super.key,
    required this.schema,
  });

  @override
  ConsumerState<SingleNotification> createState() => _SingleNotificationState();
}

class _SingleNotificationState extends ConsumerState<SingleNotification> {
  late final AccessStatusSchema? status = ref.read(accessStatusProvider);

  Widget? _body;
  List<AccountSchema> _accounts = [];

  bool get _isMention => widget.schema.type == NotificationType.mention;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  Widget build(BuildContext context) {
    if (_body == null) {
      return const LoadingOverlay(isLoading: true, child: SizedBox(height: 72));
    }

    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final Color accent = widget.schema.type.accentColor(context);

    return Semantics(
      label: _headerText(context),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.3)),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(widget.schema.type.icon, size: 20, color: accent),
              const SizedBox(width: 10),
              _AvatarStack(accounts: _accounts, size: 20, overlap: 8),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _headerText(context),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurface,
                    height: 1.25,
                    fontWeight: _isMention ? FontWeight.w500 : null,
                  ),
                ),
              ),
            ],
          ),
          if (_body != const SizedBox.shrink()) ...[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 32),
              child: Opacity(opacity: _isMention ? 1.0 : 0.75, child: _body!),
            ),
          ],
        ],
      ),
    ));
  }

  // "Alice and N others <verb>" — returns a plain-string header.
  // Keeping it as a single string lets Flutter handle RTL wrapping and
  // avoids brittle TextSpan math just to bold a single name.
  String _headerText(BuildContext context) {
    final String verb = widget.schema.type.tooltip(context).toLowerCase();
    if (_accounts.isEmpty) return verb;

    final String primaryName = _accounts.first.displayName;
    final int extras = widget.schema.count - 1;
    if (extras <= 0) return '$primaryName  $verb';

    final String others = AppLocalizations.of(context)?.txt_notification_others(extras) ?? '+ $extras others';
    return '$primaryName $others  $verb';
  }

  Future<void> _load() async {
    late final Widget content;
    switch (widget.schema.type) {
      case NotificationType.status:
      case NotificationType.reblog:
      case NotificationType.favourite:
      case NotificationType.poll:
      case NotificationType.update:
      case NotificationType.mention:
        final StatusSchema? schema = await status?.getStatus(widget.schema.statusID, loadCache: true);
        content = schema == null ? const SizedBox.shrink() : StatusLite(schema: schema);
        break;
      case NotificationType.follow:
      case NotificationType.followRequest:
      case NotificationType.adminSignUp:
        final List<AccountSchema> accounts = await status?.getAccounts(widget.schema.accounts) ?? [];
        content = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: accounts.map((a) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Account(schema: a),
          )).toList(),
        );
        break;
      case NotificationType.adminReport:
      case NotificationType.unknown:
        logger.d('Unknown or admin-report notification: ${widget.schema.type}');
        content = const SizedBox.shrink();
        break;
    }

    await _loadAccounts();
    if (mounted) setState(() => _body = content);
  }

  Future<void> _loadAccounts() async {
    final List<AccountSchema> accounts = await status?.getAccounts(widget.schema.accounts) ?? [];
    if (mounted) setState(() => _accounts = accounts);
  }
}

// Horizontal overlapping stack of small round avatars, used inline in
// the action notification header to identify who triggered it.
class _AvatarStack extends StatelessWidget {
  static const int _maxCount = 3;

  final List<AccountSchema> accounts;
  final double size;
  final double overlap;

  const _AvatarStack({
    required this.accounts,
    required this.size,
    required this.overlap,
  });

  @override
  Widget build(BuildContext context) {
    if (accounts.isEmpty) return SizedBox(width: size, height: size);
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final List<AccountSchema> shown = accounts.take(_maxCount).toList();
    final double width = size + (shown.length - 1) * (size - overlap);

    return SizedBox(
      width: width.clamp(size, double.infinity),
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (int i = 0; i < shown.length; i++)
            Positioned(
              left: i * (size - overlap),
              child: Container(
                padding: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  shape: BoxShape.circle,
                ),
                child: AccountAvatar(schema: shown[i], size: size - 2),
              ),
            ),
        ],
      ),
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
