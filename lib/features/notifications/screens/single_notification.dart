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
  static const double _avatarSize = 44;

  late final AccessStatusSchema? status = ref.read(accessStatusProvider);

  Widget? _body;
  List<AccountSchema> _accounts = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  Widget build(BuildContext context) {
    if (_body == null) {
      return const LoadingOverlay(isLoading: true, child: SizedBox(height: 96));
    }

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAvatarBadge(context),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(context),
                if (_body != const SizedBox.shrink()) ...[
                  const SizedBox(height: 8),
                  _body!,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Primary avatar with a small circular badge overlay carrying the
  // notification type icon in its accent color. Matches Mastodon web.
  Widget _buildAvatarBadge(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color accent = widget.schema.type.accentColor(context);
    final AccountSchema? primary = _accounts.isNotEmpty ? _accounts.first : null;

    return SizedBox(
      width: _avatarSize,
      height: _avatarSize,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (primary != null)
            AccountAvatar(schema: primary, size: _avatarSize)
          else
            Container(
              width: _avatarSize,
              height: _avatarSize,
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(_avatarSize / 2),
              ),
            ),
          Positioned(
            bottom: -2,
            right: -2,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: accent,
                shape: BoxShape.circle,
                border: Border.all(color: scheme.surface, width: 2),
              ),
              child: Icon(
                widget.schema.type.icon,
                size: 11,
                color: _onAccent(context, accent),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _onAccent(BuildContext context, Color accent) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    if (accent == scheme.error) return scheme.onError;
    if (accent == scheme.tertiary) return scheme.onTertiary;
    return scheme.onPrimary;
  }

  // Renders: "<Name>[, <Name>] [and N others] <action label>" with the
  // action label in onSurfaceVariant.
  Widget _buildHeader(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final TextStyle? nameStyle = theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600);
    final TextStyle? labelStyle = theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant);

    if (_accounts.isEmpty) {
      return Text(widget.schema.type.tooltip(context), style: labelStyle);
    }

    final String primaryName = _accounts.first.displayName;
    final int extras = widget.schema.count - 1;
    final String othersSuffix = extras > 0
        ? ' ${AppLocalizations.of(context)?.txt_notification_others(extras) ?? '+ $extras others'}'
        : '';

    return RichText(
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        children: [
          TextSpan(text: primaryName, style: nameStyle),
          if (othersSuffix.isNotEmpty)
            TextSpan(text: othersSuffix, style: labelStyle),
          const TextSpan(text: '  '),
          TextSpan(text: widget.schema.type.tooltip(context).toLowerCase(), style: labelStyle),
        ],
      ),
    );
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
        content = schema == null
            ? const SizedBox.shrink()
            : Opacity(
                opacity: widget.schema.type == NotificationType.mention ? 1.0 : 0.75,
                child: StatusLite(schema: schema),
              );
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

// vim: set ts=2 sw=2 sts=2 et:
