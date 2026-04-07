// The developer applications screen — create new OAuth2 apps on the current server,
// mimicking the web UI at /settings/applications/new.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';

// The available OAuth2 scopes for Mastodon applications.
const List<String> _availableScopes = [
  'read',
  'write',
  'follow',
  'push',
];

// The result of creating a new application, including the access token.
class _AppCredentials {
  final String name;
  final String clientId;
  final String clientSecret;
  final String? accessToken;
  final String redirectUri;
  final List<String> scopes;

  const _AppCredentials({
    required this.name,
    required this.clientId,
    required this.clientSecret,
    this.accessToken,
    required this.redirectUri,
    required this.scopes,
  });
}

class ApplicationsScreen extends ConsumerStatefulWidget {
  const ApplicationsScreen({super.key});

  @override
  ConsumerState<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends ConsumerState<ApplicationsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _redirectController = TextEditingController(text: 'urn:ietf:wg:oauth:2.0:oob');

  final Set<String> _selectedScopes = {'read'};
  bool _isLoading = false;
  _AppCredentials? _credentials;

  @override
  void dispose() {
    _nameController.dispose();
    _websiteController.dispose();
    _redirectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return Scaffold(
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContentWidth),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: _credentials != null
                  ? _buildCredentials(theme, scheme)
                  : _buildForm(theme, scheme),
            ),
          ),
        ),
      ),
    );
  }

  // ── Form ──────────────────────────────────────────────────────────

  Widget _buildForm(ThemeData theme, ColorScheme scheme) {
    final AppLocalizations? l10n = AppLocalizations.of(context);

    return ListView(
      children: [
        const SizedBox(height: 8),
        _sectionLabel(theme, l10n?.txt_app_new_application ?? 'NEW APPLICATION'),
        const SizedBox(height: 16),

        // App name
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: l10n?.txt_app_name ?? 'Application name',
            hintText: l10n?.txt_app_name_hint ?? 'My App',
            prefixIcon: Icon(Icons.apps, color: scheme.onSurfaceVariant),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 12),

        // Website
        TextField(
          controller: _websiteController,
          decoration: InputDecoration(
            labelText: l10n?.txt_app_website ?? 'Application website',
            hintText: 'https://example.com',
            prefixIcon: Icon(Icons.language, color: scheme.onSurfaceVariant),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          keyboardType: TextInputType.url,
        ),
        const SizedBox(height: 12),

        // Redirect URI
        TextField(
          controller: _redirectController,
          decoration: InputDecoration(
            labelText: l10n?.txt_app_redirect_uri ?? 'Redirect URI',
            prefixIcon: Icon(Icons.link, color: scheme.onSurfaceVariant),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 20),

        // Scopes
        _sectionLabel(theme, l10n?.txt_app_scopes ?? 'SCOPES'),
        const SizedBox(height: 8),
        ..._availableScopes.map((scope) => Container(
          margin: const EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(
            border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.4)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: CheckboxListTile(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: Text(scope, style: theme.textTheme.bodyMedium),
            value: _selectedScopes.contains(scope),
            onChanged: (bool? v) {
              setState(() {
                if (v == true) {
                  _selectedScopes.add(scope);
                } else {
                  _selectedScopes.remove(scope);
                }
              });
            },
          ),
        )),
        const SizedBox(height: 24),

        // Submit
        FilledButton.icon(
          onPressed: _isLoading || _nameController.text.trim().isEmpty ? null : _createApp,
          icon: _isLoading
              ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: scheme.onPrimary))
              : const Icon(Icons.add),
          label: Text(_isLoading
              ? (l10n?.btn_app_creating ?? 'Creating...')
              : (l10n?.btn_app_create ?? 'Create Application')),
        ),
        const SizedBox(height: 12),
        _manageButton(scheme),
      ],
    );
  }

  // ── Credentials result ────────────────────────────────────────────

  Widget _buildCredentials(ThemeData theme, ColorScheme scheme) {
    final AppLocalizations? l10n = AppLocalizations.of(context);
    final creds = _credentials!;

    return ListView(
      children: [
        const SizedBox(height: 8),
        _sectionLabel(theme, l10n?.txt_app_created ?? 'APPLICATION CREATED'),
        const SizedBox(height: 16),

        // Success banner
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: scheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: scheme.primary.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: scheme.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(creds.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600))),
            ],
          ),
        ),
        const SizedBox(height: 20),

        _credentialTile(theme, scheme, label: l10n?.txt_app_client_id ?? 'Client ID', value: creds.clientId),
        const SizedBox(height: 8),
        _credentialTile(theme, scheme, label: l10n?.txt_app_client_secret ?? 'Client Secret', value: creds.clientSecret),
        if (creds.accessToken != null) ...[
          const SizedBox(height: 8),
          _credentialTile(theme, scheme, label: l10n?.txt_app_access_token ?? 'Access Token', value: creds.accessToken!),
        ],
        const SizedBox(height: 8),
        _credentialTile(theme, scheme, label: l10n?.txt_app_redirect_uri ?? 'Redirect URI', value: creds.redirectUri),
        const SizedBox(height: 8),
        _credentialTile(theme, scheme, label: l10n?.txt_app_scopes ?? 'Scopes', value: creds.scopes.join(' ')),

        const SizedBox(height: 24),

        // Warning
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: scheme.errorContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: scheme.error.withValues(alpha: 0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.warning_amber, color: scheme.error, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(
                l10n?.txt_app_save_warning ?? 'Save these credentials now. The client secret will not be shown again.',
                style: theme.textTheme.bodySmall?.copyWith(color: scheme.error),
              )),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Create another
        OutlinedButton.icon(
          onPressed: () => setState(() => _credentials = null),
          icon: const Icon(Icons.add),
          label: Text(l10n?.btn_app_create_another ?? 'Create Another'),
        ),
        const SizedBox(height: 12),
        _manageButton(scheme),
      ],
    );
  }

  Widget _credentialTile(ThemeData theme, ColorScheme scheme, {required String label, required String value}) {
    final AppLocalizations? l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(label, style: theme.textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant)),
        subtitle: SelectableText(value, style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace')),
        trailing: IconButton(
          icon: Icon(Icons.copy, size: 18, color: scheme.onSurfaceVariant),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: value));
            showSnackbar(context, l10n?.msg_app_copied(label) ?? 'Copied $label');
          },
        ),
      ),
    );
  }

  Widget _sectionLabel(ThemeData theme, String text) {
    return Text(
      text.toUpperCase(),
      style: theme.textTheme.labelSmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _manageButton(ColorScheme scheme) {
    final AppLocalizations? l10n = AppLocalizations.of(context);
    final AccessStatusSchema? status = ref.read(accessStatusProvider);
    final String? domain = status?.domain;
    if (domain == null || domain.isEmpty) return const SizedBox.shrink();

    return OutlinedButton.icon(
      onPressed: () => openLink(context, Uri.parse('https://$domain/settings/applications'), ref: ref),
      icon: Icon(Icons.open_in_new, size: 18, color: scheme.onSurfaceVariant),
      label: Text(l10n?.btn_app_manage_on_server ?? 'Manage Applications on Server'),
    );
  }

  // ── API ───────────────────────────────────────────────────────────

  Future<void> _createApp() async {
    final AppLocalizations? l10n = AppLocalizations.of(context);
    final AccessStatusSchema? status = ref.read(accessStatusProvider);
    final String? domain = status?.domain;
    if (domain == null || domain.isEmpty) return;

    final String name = _nameController.text.trim();
    final String? website = _websiteController.text.trim().isEmpty ? null : _websiteController.text.trim();
    final String redirectUri = _redirectController.text.trim();
    final String scopes = _selectedScopes.join(' ');

    setState(() => _isLoading = true);

    try {
      // Step 1: Register the application via POST /api/v1/apps
      final Map<String, dynamic> body = {
        "client_name": name,
        "redirect_uris": [redirectUri],
        "scopes": scopes,
        "website": website,
      }..removeWhere((key, value) => value == null);

      final Uri uri = UriEx.handle(domain, "/api/v1/apps");
      final response = await post(uri, body: jsonEncode(body), headers: {
        "Content-Type": "application/json",
      });

      if (response.statusCode != 200) {
        throw Exception("${response.statusCode}: ${response.body}");
      }

      final Map<String, dynamic> json = jsonDecode(response.body) as Map<String, dynamic>;
      final String clientId = json['client_id'] as String;
      final String clientSecret = json['client_secret'] as String;

      // Step 2: Obtain an access token via client_credentials grant
      String? accessToken;
      try {
        final Map<String, dynamic> tokenBody = {
          "client_id": clientId,
          "client_secret": clientSecret,
          "grant_type": "client_credentials",
          "redirect_uri": redirectUri,
          "scope": scopes,
        };

        final Uri tokenUri = UriEx.handle(domain, "/oauth/token");
        final tokenResponse = await post(tokenUri, body: jsonEncode(tokenBody), headers: {
          "Content-Type": "application/json",
        });

        if (tokenResponse.statusCode == 200) {
          final Map<String, dynamic> tokenJson = jsonDecode(tokenResponse.body) as Map<String, dynamic>;
          accessToken = tokenJson['access_token'] as String?;
        }
      } catch (e) {
        logger.w("failed to obtain app token: $e");
      }

      setState(() {
        _credentials = _AppCredentials(
          name: name,
          clientId: clientId,
          clientSecret: clientSecret,
          accessToken: accessToken,
          redirectUri: redirectUri,
          scopes: _selectedScopes.toList(),
        );
      });
    } catch (e) {
      if (mounted) {
        showSnackbar(context, l10n?.msg_app_create_failed ?? 'Failed to create application');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

// vim: set ts=2 sw=2 sts=2 et:
