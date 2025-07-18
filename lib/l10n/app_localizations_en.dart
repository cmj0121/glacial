// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get txt_app_name => 'Glacial';

  @override
  String get txt_invalid_instance => 'Invalid Mastodon server';

  @override
  String get txt_server_contact => 'Contact';

  @override
  String get txt_search_helper => 'Search for something interesting';

  @override
  String get txt_search_history => 'Search history';

  @override
  String get txt_search_mastodon => 'mastodon.social';

  @override
  String get txt_server_rules => 'Server rules';

  @override
  String get txt_show_less => 'Show less';

  @override
  String get txt_show_more => 'Show more';

  @override
  String txt_trends_uses(Object uses) {
    return '$uses used in the past days';
  }

  @override
  String txt_no_results_found(Object keyword) {
    return 'No results found for $keyword';
  }

  @override
  String get txt_copied_to_clipboard => 'Copy to Clipboard';

  @override
  String get txt_public => 'Public';

  @override
  String get txt_unlisted => 'Unlisted';

  @override
  String get txt_private => 'Private';

  @override
  String get txt_direct => 'Direct';

  @override
  String get btn_clean_all => 'Clean All';

  @override
  String get btn_timeline => 'Timelines';

  @override
  String get btn_trending => 'Trending now';

  @override
  String get btn_notifications => 'Notifications';

  @override
  String get btn_settings => 'Settings';

  @override
  String get btn_management => 'Administration';

  @override
  String get btn_trends_links => 'News';

  @override
  String get btn_trends_statuses => 'Posts';

  @override
  String get btn_trends_tags => 'Hashtags';

  @override
  String get btn_home => 'Home';

  @override
  String get btn_user => 'User';

  @override
  String get btn_profile => 'Profile';

  @override
  String get btn_pin => 'Pin';

  @override
  String get btn_schedule => 'Scheduled';

  @override
  String get btn_local => 'This server';

  @override
  String get btn_federal => 'Other servers';

  @override
  String get btn_public => 'All';

  @override
  String get btn_bookmarks => 'Bookmarks';

  @override
  String get btn_favourites => 'Favorites';

  @override
  String get btn_post => 'New post';

  @override
  String get btn_follow_mutual => 'Mutual';

  @override
  String get btn_following => 'Following';

  @override
  String get btn_followed_by => 'Followed By';

  @override
  String get btn_follow => 'Follow';

  @override
  String get btn_block => 'Block';

  @override
  String get btn_unblock => 'Unblock';

  @override
  String get btn_mute => 'Mute';

  @override
  String get btn_unmute => 'Unmute';

  @override
  String get btn_report => 'Report';

  @override
  String get dots => '...';
}
