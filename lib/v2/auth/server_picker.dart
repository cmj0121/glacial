// The v2 server selection screen with live search from joinmastodon.org directory.
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/v2/core.dart';

class V2ServerPicker extends ConsumerStatefulWidget {
  final List<CuratedServer>? initialServers;

  const V2ServerPicker({super.key, this.initialServers});

  @override
  ConsumerState<V2ServerPicker> createState() => _V2ServerPickerState();
}

class _V2ServerPickerState extends ConsumerState<V2ServerPicker>
    with SingleTickerProviderStateMixin {
  static const String _directoryUrl = 'https://api.joinmastodon.org/servers';

  final TextEditingController controller = TextEditingController();
  late final AnimationController _exitController;
  List<CuratedServer> _allServers = [];
  ServerSchema? _serverInfo;
  bool _isLoading = false;
  bool _isFetchingDirectory = true;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    if (widget.initialServers != null) {
      _allServers = widget.initialServers!;
      _isFetchingDirectory = false;
    } else {
      _fetchDirectory();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    _exitController.dispose();
    super.dispose();
  }

  Future<void> _fetchDirectory() async {
    try {
      final response = await get(Uri.parse(_directoryUrl));
      if (response.statusCode == 200 && mounted) {
        final List<dynamic> json = jsonDecode(response.body) as List<dynamic>;
        setState(() {
          _allServers = json
              .map((e) => CuratedServer.fromJson(e as Map<String, dynamic>))
              .toList();
          _isFetchingDirectory = false;
        });
        return;
      }
    } catch (e) {
      logger.w('Failed to fetch server directory: $e');
    }

    if (mounted) {
      setState(() {
        _allServers = V2Theme.curatedServers;
        _isFetchingDirectory = false;
      });
    }
  }

  List<CuratedServer> get _filteredServers {
    if (_query.isEmpty) return _allServers;
    final q = _query.toLowerCase();
    return _allServers.where((s) =>
        s.domain.toLowerCase().contains(q) ||
        s.description.toLowerCase().contains(q) ||
        (s.language?.toLowerCase().contains(q) ?? false) ||
        (s.category?.toLowerCase().contains(q) ?? false)
    ).toList();
  }

  bool get _looksLikeDomain => _query.contains('.');

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.txt_v2_choose_server ?? 'Choose your server'),
      ),
      body: AnimatedBuilder(
        animation: _exitController,
        builder: (context, child) {
          final progress = _exitController.value;
          return Opacity(
            opacity: 1.0 - progress,
            child: Transform.scale(
              scale: 1.0 - (progress * 0.05),
              child: child,
            ),
          );
        },
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bool isWide = constraints.maxWidth >= V2Theme.wideBreakpoint;
              if (isWide && _serverInfo != null) {
                return _buildWideLayout(theme, l10n);
              }
              return _buildNarrowLayout(theme, l10n);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField(ThemeData theme, AppLocalizations? l10n) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search),
        hintText: l10n?.txt_v2_server_hint ?? 'Search or enter server URL',
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(V2Theme.borderRadiusFull),
          borderSide: BorderSide.none,
        ),
        suffixIcon: _query.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  controller.clear();
                  setState(() {
                    _query = '';
                    _serverInfo = null;
                  });
                },
              )
            : null,
      ),
      onChanged: (value) => setState(() {
        _query = value.trim();
        _serverInfo = null;
      }),
      onSubmitted: (_) => _onSubmit(),
    );
  }

  Widget _buildListHeader(ThemeData theme, AppLocalizations? l10n) {
    return Row(
      children: [
        Text(
          l10n?.txt_v2_popular_servers ?? 'Popular Servers',
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        if (_query.isNotEmpty && !_isLoading && !_isFetchingDirectory) ...[
          const Spacer(),
          Text(
            '${_filteredServers.length}',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  // Narrow layout (iPhone): search + list, server info replaces list
  Widget _buildNarrowLayout(ThemeData theme, AppLocalizations? l10n) {
    return V2CenteredLayout(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: V2Theme.spacingLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: V2Theme.spacingLG),
            _buildSearchField(theme, l10n),
            const SizedBox(height: V2Theme.spacingXL),
            if (_serverInfo == null) ...[
              _buildListHeader(theme, l10n),
              const Divider(),
            ],
            Expanded(child: _buildBody(theme)),
            const SizedBox(height: V2Theme.spacingLG),
          ],
        ),
      ),
    );
  }

  // Wide layout (iPad/Mac): server list on left, detail panel on right
  Widget _buildWideLayout(ThemeData theme, AppLocalizations? l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: V2Theme.spacingLG),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left panel: search + server list
          SizedBox(
            width: 340,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: V2Theme.spacingLG),
                _buildSearchField(theme, l10n),
                const SizedBox(height: V2Theme.spacingXL),
                _buildListHeader(theme, l10n),
                const SizedBox(height: V2Theme.spacingSM),
                Expanded(child: _buildServerList(theme, showChevron: false)),
              ],
            ),
          ),
          const SizedBox(width: V2Theme.spacingXL),
          // Right panel: server info detail in a card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: V2Theme.spacingLG, bottom: V2Theme.spacingLG),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(V2Theme.borderRadiusLG),
                ),
                clipBehavior: Clip.antiAlias,
                child: FadeSlideIn(
                  key: ValueKey(_serverInfo?.domain),
                  child: _buildServerInfoWide(theme),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServerList(ThemeData theme, {bool showChevron = true}) {
    if (_isLoading || _isFetchingDirectory) {
      return const Center(child: CircularProgressIndicator());
    }

    final servers = _filteredServers;

    if (servers.isEmpty && _query.isNotEmpty) {
      return _buildEmptyState(theme);
    }

    return ListView.builder(
      itemCount: servers.length,
      itemBuilder: (context, index) {
        return FadeSlideIn(
          delay: Duration(milliseconds: 50 * (index.clamp(0, 10))),
          child: _buildServerCard(servers[index], theme, showChevron: showChevron),
        );
      },
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.dns_outlined, size: 48, color: theme.disabledColor),
          const SizedBox(height: V2Theme.spacingLG),
          Text(
            AppLocalizations.of(context)?.txt_v2_no_match ?? 'No matching servers',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.disabledColor),
          ),
          if (_looksLikeDomain) ...[
            const SizedBox(height: V2Theme.spacingLG),
            FilledButton.tonalIcon(
              icon: const Icon(Icons.travel_explore),
              label: Text(_query),
              onPressed: () => _onSelectServer(_query),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_serverInfo != null) return FadeSlideIn(child: _buildServerInfo(theme));
    return _buildServerList(theme);
  }

  Widget _buildServerCard(CuratedServer server, ThemeData theme, {bool showChevron = true}) {
    final bool isSelected = _serverInfo?.domain == server.domain;
    final Widget avatar = server.thumbnail != null && server.thumbnail!.isNotEmpty
        ? CircleAvatar(
            radius: 20,
            backgroundImage: CachedNetworkImageProvider(server.thumbnail!),
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
          )
        : CircleAvatar(
            radius: 20,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            child: Icon(Icons.public, size: 20, color: theme.colorScheme.onSurfaceVariant),
          );

    return Padding(
      padding: const EdgeInsets.only(bottom: V2Theme.spacingSM),
      child: Tooltip(
        message: server.description,
        waitDuration: const Duration(milliseconds: 500),
        child: Material(
          color: isSelected
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.4)
              : theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(V2Theme.borderRadius),
          child: InkWell(
            borderRadius: BorderRadius.circular(V2Theme.borderRadius),
            hoverColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            onTap: () => _onSelectServer(server.domain),
            child: Container(
              padding: const EdgeInsets.all(V2Theme.spacingMD),
              decoration: isSelected
                  ? BoxDecoration(
                      borderRadius: BorderRadius.circular(V2Theme.borderRadius),
                      border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                    )
                  : null,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  avatar,
                  const SizedBox(width: V2Theme.spacingMD),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          server.domain,
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: V2Theme.spacingXS),
                        Text(
                          server.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: V2Theme.spacingSM),
                        Row(
                          children: [
                            if (server.language != null)
                              _buildBadge(server.language!, theme),
                            if (server.language != null)
                              const SizedBox(width: V2Theme.spacingXS),
                            _buildBadge('${server.users} users', theme),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (showChevron)
                    Padding(
                      padding: const EdgeInsets.only(top: V2Theme.spacingXS),
                      child: Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServerInfo(ThemeData theme) {
    final schema = _serverInfo!;

    return SingleChildScrollView(
      child: InkWell(
        borderRadius: BorderRadius.circular(V2Theme.borderRadius),
        onTap: () => _onConfirmServer(schema),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (schema.thumbnail.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(V2Theme.borderRadius),
                child: CachedNetworkImage(
                  imageUrl: schema.thumbnail,
                  width: double.infinity,
                  height: 160,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => ShimmerEffect(
                    child: Container(height: 160, color: theme.colorScheme.surfaceContainerHighest),
                  ),
                  errorWidget: (context, url, error) => const SizedBox.shrink(),
                ),
              ),
            const SizedBox(height: V2Theme.spacingLG),
            Text(schema.title, style: theme.textTheme.headlineSmall),
            const SizedBox(height: V2Theme.spacingSM),
            Text(schema.desc, style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            )),
            const SizedBox(height: V2Theme.spacingLG),
            Wrap(
              spacing: V2Theme.spacingSM,
              runSpacing: V2Theme.spacingXS,
              children: [
                _buildBadge('v${schema.version}', theme),
                _buildBadge('MAU: ${schema.usage.userActiveMonthly}', theme),
                ...schema.languages.map((lang) => _buildBadge(lang, theme)),
              ],
            ),
            if (schema.contact.email.isNotEmpty) ...[
              const SizedBox(height: V2Theme.spacingLG),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.contact_mail_rounded, color: theme.colorScheme.primary),
                title: Text(schema.contact.email, style: theme.textTheme.bodySmall),
              ),
            ],
            const SizedBox(height: V2Theme.spacingXL),
            Center(
              child: Text(
                AppLocalizations.of(context)?.txt_v2_tap_to_select ?? 'Tap to select this server',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Server info for wide layout — taller thumbnail with gradient overlay
  Widget _buildServerInfoWide(ThemeData theme) {
    final schema = _serverInfo!;

    return InkWell(
      borderRadius: BorderRadius.circular(V2Theme.borderRadiusLG),
      onTap: () => _onConfirmServer(schema),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tall thumbnail with gradient overlay and title
            if (schema.thumbnail.isNotEmpty)
              SizedBox(
                height: 200,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: schema.thumbnail,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => ShimmerEffect(
                        child: Container(color: theme.colorScheme.surfaceContainerHighest),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                      ),
                    ),
                    // Gradient overlay at bottom
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              theme.colorScheme.surfaceContainerLow,
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Title on gradient
                    Positioned(
                      bottom: V2Theme.spacingMD,
                      left: V2Theme.spacingXL,
                      right: V2Theme.spacingXL,
                      child: Text(
                        schema.title,
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              const SizedBox(height: V2Theme.spacingXL),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: V2Theme.spacingXL),
                child: Text(schema.title, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
              ),
            ],
            Padding(
              padding: const EdgeInsets.all(V2Theme.spacingXL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(schema.desc, style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.5,
                  )),
                  const SizedBox(height: V2Theme.spacingXL),
                  Wrap(
                    spacing: V2Theme.spacingSM,
                    runSpacing: V2Theme.spacingSM,
                    children: [
                      _buildBadge('v${schema.version}', theme),
                      _buildBadge('MAU: ${schema.usage.userActiveMonthly}', theme),
                      ...schema.languages.map((lang) => _buildBadge(lang, theme)),
                    ],
                  ),
                  if (schema.contact.email.isNotEmpty) ...[
                    const SizedBox(height: V2Theme.spacingXL),
                    Row(
                      children: [
                        Icon(Icons.contact_mail_rounded, size: V2Theme.iconSizeSM, color: theme.colorScheme.primary),
                        const SizedBox(width: V2Theme.spacingSM),
                        Text(schema.contact.email, style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ],
                  const SizedBox(height: V2Theme.spacingXXL),
                  // CTA — tap hint with icon
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: V2Theme.spacingXL,
                        vertical: V2Theme.spacingMD,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(V2Theme.borderRadiusFull),
                        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.touch_app_outlined, size: 18, color: theme.colorScheme.primary),
                          const SizedBox(width: V2Theme.spacingSM),
                          Text(
                            AppLocalizations.of(context)?.txt_v2_tap_to_select ?? 'Tap to select this server',
                            style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: V2Theme.spacingSM,
        vertical: V2Theme.spacingXS,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(V2Theme.borderRadiusFull),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Text(text, style: theme.textTheme.labelSmall),
    );
  }

  void _onSubmit() {
    if (_query.isEmpty) return;
    if (_looksLikeDomain) {
      _onSelectServer(_query);
    }
  }

  Future<void> _onSelectServer(String domain) async {
    if (domain == _serverInfo?.domain) return;

    setState(() {
      _serverInfo = null;
      _isLoading = true;
    });

    try {
      final schema = await ServerSchema.fetch(domain);
      if (mounted) {
        controller.text = domain;
        setState(() {
          _query = domain;
          _serverInfo = schema;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        showSnackbar(context, e.toString());
      }
    }
  }

  Future<void> _onConfirmServer(ServerSchema schema) async {
    await _exitController.forward();
    final RoutePath route = await selectServer(schema: schema, ref: ref);
    if (!mounted) return;

    // OAuth lives on the home shell (SignIn button replaces the post slot
    // when not signed in), so always land there — popping back to the hub
    // strands users who picked a server they have no saved account on yet.
    context.go(route.path);
  }
}

// vim: set ts=2 sw=2 sts=2 et:
