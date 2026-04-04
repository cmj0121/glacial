class V2Theme {
  // Spacing scale
  static const double spacingXS = 4;
  static const double spacingSM = 8;
  static const double spacingMD = 12;
  static const double spacingLG = 16;
  static const double spacingXL = 24;
  static const double spacingXXL = 32;
  static const double spacing3XL = 48;

  // Layout
  static const double maxContentWidth = 480;
  static const double borderRadius = 12;
  static const double borderRadiusLG = 16;

  static const double borderRadiusFull = 24;

  // Sizes
  static const double logoSize = 96;
  static const double logoSizeSM = 32;
  static const double iconSizeSM = 16;

  // Responsive breakpoint
  static const double wideBreakpoint = 600;

  // Curated server list for the server picker
  static const List<CuratedServer> curatedServers = [
    CuratedServer(
      domain: 'mastodon.social',
      description: 'General purpose',
      users: '2.1M',
    ),
    CuratedServer(
      domain: 'mastodon.online',
      description: 'For everyone',
      users: '340K',
    ),
    CuratedServer(
      domain: 'fosstodon.org',
      description: 'Open source community',
      users: '62K',
    ),
    CuratedServer(
      domain: 'mstdn.jp',
      description: 'Japanese community',
      users: '800K',
    ),
  ];
}

class CuratedServer {
  final String domain;
  final String description;
  final String users;
  final String? language;
  final String? category;
  final String? thumbnail;

  const CuratedServer({
    required this.domain,
    required this.description,
    required this.users,
    this.language,
    this.category,
    this.thumbnail,
  });

  factory CuratedServer.fromJson(Map<String, dynamic> json) {
    final int totalUsers = json['total_users'] as int? ?? 0;
    String users;
    if (totalUsers >= 1000000) {
      users = '${(totalUsers / 1000000).toStringAsFixed(1)}M';
    } else if (totalUsers >= 1000) {
      users = '${(totalUsers / 1000).toStringAsFixed(0)}K';
    } else {
      users = totalUsers.toString();
    }

    // The API returns proxied_thumbnail as a proxy URL that often 500s.
    // Extract the direct URL from the hex-encoded path segment.
    String? thumbnail = json['proxied_thumbnail'] as String?;
    if (thumbnail != null) {
      final uri = Uri.tryParse(thumbnail);
      if (uri != null && uri.host == 'proxy.joinmastodon.org' && uri.pathSegments.length >= 2) {
        try {
          final hex = uri.pathSegments.last;
          final bytes = List.generate(hex.length ~/ 2, (i) => int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16));
          thumbnail = String.fromCharCodes(bytes);
        } catch (_) {}
      }
    }

    return CuratedServer(
      domain: json['domain'] as String,
      description: (json['description'] as String? ?? '').replaceAll(RegExp(r'\s+'), ' ').trim(),
      users: users,
      language: json['language'] as String?,
      category: json['category'] as String?,
      thumbnail: thumbnail,
    );
  }
}
// vim: set ts=2 sw=2 sts=2 et:
