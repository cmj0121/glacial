// The Mastodon server explorer and find a server to connect to.
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';

// The Mastodon server widget to show the information based on the widget type.
class MastodonServer extends StatelessWidget {
  final ServerSchema schema;
  final double badgeFontSize;
  final ValueChanged<ServerSchema>? onTap;

  const MastodonServer({
    super.key,
    required this.schema,
    this.badgeFontSize = 10,
    this.onTap,
  });

  // The static method to create the server widget by the passed domain, with
  // the future builder to load the server information.
  static Widget builder({required String domain, ValueChanged<ServerSchema>? onTap}) {
    return FutureBuilder(
      future: ServerSchema.fetch(domain),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ClockProgressIndicator();
        } else if (snapshot.hasError) {
          final String text = AppLocalizations.of(context)?.err_invalid_instance(domain) ?? 'Invalid instance: $domain';
          return NoResult(message: text);
        }

        final ServerSchema schema = snapshot.data as ServerSchema;
        logger.i("successfully loaded the server: ${schema.domain}");
        return MastodonServer(schema: schema, onTap: onTap);
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final Debouncer debouncer = Debouncer(duration: const Duration(milliseconds: 700));
    return InkWellDone(
      onTap: () => debouncer.callOnce(() => onTap?.call(schema)),
      child: buildContent(context),
    );
  }

  // The main content of the server widget, which includes the thumbnail, title,
  // description, extra content, and metadata.
  Widget buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(child: buildThumbnail()),
          const SizedBox(height: 16),
          Text(schema.title, style: Theme.of(context).textTheme.headlineMedium, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 16),
          Text(schema.desc, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 6),

          buildExtraContent(context),

          const Spacer(),
          buildMetadata(),
        ],
      ),
    );
  }

  // Build the thumbnail image of the server.
  Widget buildThumbnail() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: OverflowBox(
        alignment: Alignment.center,
        maxWidth: double.infinity,
        maxHeight: double.infinity,
        child: CachedNetworkImage(
          imageUrl: schema.thumbnail,
          placeholder: (context, url) => const ClockProgressIndicator(),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
      ),
    );
  }

  // Show the extra content about the server info
  Widget buildExtraContent(BuildContext context) {
    final TextStyle? style = Theme.of(context).textTheme.bodySmall;
    final bool showRules = schema.rules.isNotEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          iconColor: Theme.of(context).colorScheme.primary,
          leading: const Icon(Icons.contact_mail_rounded),
          title: Text(
            schema.contact.email.isEmpty ? '-' : schema.contact.email,
            style: style,
          ),
        ),

        InkWellDone(
          onTap: showRules ? () => showDialog(
            context: context,
            builder: (context) => Dialog(
              child: ServerRules(rules: schema.rules),
            ),
          ) : null,
          child: ListTile(
            iconColor: Theme.of(context).colorScheme.primary,
            leading: const Icon(Icons.rule_outlined),
            title: Text(
              'Server Rules',
              style: style?.copyWith(
                color: showRules ? Theme.of(context).colorScheme.primary : null,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Build the metadata of the server, including the server version and the
  // supported languages.
  Widget buildMetadata() {
    final List<String> tags = [
      'v${schema.version}',
      'mau: ${schema.usage.userActiveMonthly}',
      ...schema.languages,
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ...tags.map((tag) {
          // Show the pill tag with the text.
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            margin: const EdgeInsets.only(left: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(tag, style: TextStyle(fontSize: badgeFontSize, color: Colors.black)),
          );
        }),
      ],
    );
  }

  // Build the register requirement of the server.
  Widget buildRegisterBadge() {
    if (!schema.registration.enabled) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      margin: const EdgeInsets.only(left: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade400,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        "registration",
        style: TextStyle(fontSize: badgeFontSize, color: Colors.black),
      ),
    );
  }
}

// The brief information of the server, which shows the server's title, and the thumbnail.
class MastodonServerInfo extends StatelessWidget {
  final ServerInfoSchema schema;
  final double size;

  const MastodonServerInfo({
    super.key,
    required this.schema,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: schema.thumbnail,
            width: size,
            height: size,
            fit: BoxFit.cover,
            placeholder: (context, url) => const ClockProgressIndicator(),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
        ),
        const SizedBox(width: 16),
        Text(schema.domain, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }
}

// The rules of the server, which shows the rules that the server has.
class ServerRules extends StatelessWidget {
  final List<RuleSchema> rules;

  const ServerRules({super.key, required this.rules});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: rules.length,
      itemBuilder: (context, index) {
        final RuleSchema rule = rules[index];
        final String text = rule.text.replaceAll(RegExp(r'[\n\r]'), ' ');

        return ListTile(
          titleAlignment: ListTileTitleAlignment.top,
          leading: Icon(Icons.library_add_check, color: Theme.of(context).colorScheme.tertiary),
          title: Text(text),
          subtitle: rule.hint.isEmpty ? null : Text(rule.hint),
          titleTextStyle: Theme.of(context).textTheme.bodySmall,
        );
      },
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
