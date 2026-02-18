// The account registration page for new users.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

// The registration page to create a new account on the selected Mastodon server.
class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _reasonController = TextEditingController();

  bool _agreed = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AccessStatusSchema? status = ref.read(accessStatusProvider);
    final String domain = status?.domain ?? '';
    final bool approvalRequired = status?.server?.registration.approvalRequired ?? false;
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Server name header
            Text(
              domain,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n?.txt_register_title ?? 'Create Account',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Server rules
            if (status?.server?.rules.isNotEmpty == true) ...[
              SizedBox(
                height: 200,
                child: ServerRules(rules: status!.server!.rules),
              ),
              const SizedBox(height: 16),
            ],

            // Username
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: l10n?.txt_username ?? 'Username',
                prefixIcon: const Icon(Icons.person_outline),
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n?.err_field_required ?? 'This field is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Email
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: l10n?.txt_email ?? 'Email',
                prefixIcon: const Icon(Icons.email_outlined),
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n?.err_field_required ?? 'This field is required';
                }
                if (!value.contains('@')) {
                  return l10n?.err_invalid_email ?? 'Invalid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Password
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: l10n?.txt_password ?? 'Password',
                prefixIcon: const Icon(Icons.lock_outline),
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n?.err_field_required ?? 'This field is required';
                }
                if (value.length < 8) {
                  return l10n?.err_password_too_short ?? 'Password must be at least 8 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Confirm Password
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: l10n?.txt_confirm_password ?? 'Confirm Password',
                prefixIcon: const Icon(Icons.lock_outline),
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value != _passwordController.text) {
                  return l10n?.err_password_mismatch ?? 'Passwords do not match';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Reason (optional, shown when approval is required)
            if (approvalRequired) ...[
              TextFormField(
                controller: _reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: l10n?.txt_reason ?? 'Reason for joining',
                  prefixIcon: const Icon(Icons.note_outlined),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Agreement checkbox
            CheckboxListTile(
              value: _agreed,
              onChanged: (value) => setState(() => _agreed = value ?? false),
              title: Text(l10n?.txt_agreement ?? 'I agree to the server rules and terms of service'),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 8),

            // Error message
            if (_errorMessage != null) ...[
              Text(
                _errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ],

            // Submit button
            FilledButton(
              onPressed: _isSubmitting ? null : onRegister,
              child: _isSubmitting
                  ? const ClockProgressIndicator.small()
                  : Text(l10n?.btn_register ?? 'Register'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> onRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreed) {
      setState(() => _errorMessage = AppLocalizations.of(context)?.err_agreement_required ?? 'You must agree to the terms');
      return;
    }

    final AccessStatusSchema? status = ref.read(accessStatusProvider);
    final String? domain = status?.domain;
    if (status == null || domain == null || domain.isEmpty) {
      logger.w("No Mastodon server selected, cannot register.");
      return;
    }

    final String locale = Localizations.localeOf(context).languageCode;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      // Step 1: Get app-level token
      final String? appToken = await status.getAppToken(domain: domain);
      if (appToken == null) {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
            _errorMessage = AppLocalizations.of(context)?.err_registration_failed ?? 'Registration failed';
          });
        }
        return;
      }

      // Step 2: Register the account
      final String? accessToken = await status.registerAccount(
        domain: domain,
        appToken: appToken,
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        locale: locale,
        reason: _reasonController.text.trim(),
      );

      if (!mounted) return;

      if (accessToken != null) {
        // Save the token and redirect
        final Storage storage = Storage();
        await storage.saveAccessToken(domain, accessToken);

        final AccountSchema? account = await status.getAccountByAccessToken(accessToken);
        final AccessStatusSchema updated = status.copyWith(
          accessToken: accessToken,
          account: account,
        );

        await storage.saveAccessStatus(updated);
        ref.read(accessStatusProvider.notifier).state = updated;
        ref.read(reloadProvider.notifier).state = !ref.read(reloadProvider);

        if (mounted) {
          context.go(RoutePath.timeline.path);
        }
      } else {
        // Email confirmation required
        if (mounted) {
          setState(() {
            _isSubmitting = false;
            _errorMessage = AppLocalizations.of(context)?.txt_registration_success ?? 'Check your email to confirm your account';
          });
        }
      }
    } on Exception catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }
}

// vim: set ts=2 sw=2 sts=2 et:
