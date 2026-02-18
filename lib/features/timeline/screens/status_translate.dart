// Translation widget for status content.
import 'package:flutter/material.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';

/// Displays a translate button and inline translation when toggled.
class TranslateView extends StatefulWidget {
  final StatusSchema schema;
  final AccessStatusSchema? status;
  final List<EmojiSchema> emojis;
  final ValueChanged<String?>? onLinkTap;

  const TranslateView({
    super.key,
    required this.schema,
    this.status,
    this.emojis = const [],
    this.onLinkTap,
  });

  @override
  State<TranslateView> createState() => _TranslateViewState();
}

class _TranslateViewState extends State<TranslateView> {
  TranslationSchema? translation;
  bool isLoading = false;
  bool isVisible = false;

  @override
  Widget build(BuildContext context) {
    if (!_shouldShowTranslate) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildButton(context),
        if (isVisible && translation != null) buildTranslation(),
      ],
    );
  }

  Widget buildButton(BuildContext context) {
    final String label = isVisible
        ? AppLocalizations.of(context)?.btn_translate_hide ?? "Show original"
        : AppLocalizations.of(context)?.btn_translate_show ?? "Translate";
    final bool translationEnabled = widget.status?.server?.config.translationEnabled ?? false;

    return TextButton.icon(
      onPressed: !translationEnabled || isLoading ? null : onToggle,
      icon: isLoading
          ? const SizedBox(width: 14, height: 14, child: ClockProgressIndicator.small())
          : const Icon(Icons.translate, size: 14),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  Widget buildTranslation() {
    return AdaptiveGlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(top: 4),
      borderRadius: BorderRadius.circular(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HtmlDone(
            html: translation!.content,
            emojis: widget.emojis,
            onLinkTap: (url, attributes, _) => widget.onLinkTap?.call(url),
          ),
          Text(
            translation!.provider,
            style: TextStyle(fontSize: 10, color: Theme.of(context).hintColor),
          ),
        ],
      ),
    );
  }

  Future<void> onToggle() async {
    if (isVisible) {
      setState(() => isVisible = false);
      return;
    }

    if (translation != null) {
      setState(() => isVisible = true);
      return;
    }

    setState(() => isLoading = true);

    try {
      final String targetLang = Localizations.localeOf(context).languageCode;
      final TranslationSchema result = await widget.status!.translateStatus(
        schema: widget.schema,
        targetLanguage: targetLang,
      );

      if (mounted) {
        setState(() {
          translation = result;
          isVisible = true;
          isLoading = false;
        });
      }
    } on HttpException catch (e) {
      logger.e("HTTP error translating status: ${e.statusCode} ${e.message}");
      if (mounted) {
        setState(() => isLoading = false);
        showSnackbar(context, AppLocalizations.of(context)?.msg_network_error ?? 'Something went wrong. Please try again.');
      }
    } on HttpTimeoutException catch (e) {
      logger.e("Translation request timed out: $e");
      if (mounted) {
        setState(() => isLoading = false);
        showSnackbar(context, AppLocalizations.of(context)?.msg_network_error ?? 'Something went wrong. Please try again.');
      }
    } catch (e) {
      logger.e("failed to translate status: $e");
      if (mounted) {
        setState(() => isLoading = false);
        showSnackbar(context, AppLocalizations.of(context)?.msg_network_error ?? 'Something went wrong. Please try again.');
      }
    }
  }

  bool get _shouldShowTranslate {
    if (widget.status?.isSignedIn != true) return false;
    if (widget.schema.content.isEmpty) return false;

    final String? statusLang = widget.schema.language;
    if (statusLang == null || statusLang.isEmpty) return false;

    final String userLang = Localizations.localeOf(context).languageCode;
    return statusLang != userLang;
  }
}

// vim: set ts=2 sw=2 sts=2 et:
