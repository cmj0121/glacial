// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get btn_search => 'Search';

  @override
  String get btn_close => 'Close';

  @override
  String get btn_clear => 'Clear';

  @override
  String get btn_exit => 'Exit';

  @override
  String get btn_reload => 'Reload';

  @override
  String get btn_history => 'History';

  @override
  String get btn_sidebar_timelines => 'Timelines';

  @override
  String get btn_sidebar_lists => 'Lists';

  @override
  String get btn_sidebar_trendings => 'Trendings';

  @override
  String get btn_sidebar_notificatios => 'Notifications';

  @override
  String get btn_sidebar_management => 'Managements';

  @override
  String get btn_sidebar_post => 'Toot';

  @override
  String get btn_drawer_switch_server => 'Switch Server';

  @override
  String get btn_drawer_profile => 'Profile';

  @override
  String get btn_drawer_preference => 'Preference';

  @override
  String get btn_drawer_logout => 'Logout';

  @override
  String get btn_trends_links => 'Links';

  @override
  String get btn_trends_toots => 'Toots';

  @override
  String get btn_trends_users => 'Users';

  @override
  String get btn_trends_tags => 'Tags';

  @override
  String get btn_preference_theme => 'Theme';

  @override
  String get btn_preference_engineer => 'Engineer Settings';

  @override
  String get btn_preference_engineer_clear_cache => 'Clear All Cache';

  @override
  String get desc_preference_engineer_clear_cache =>
      'Clear all cached data and reset the app';

  @override
  String get txt_search_history => 'Search History';

  @override
  String get txt_helper_server_explorer => 'Search for a Mastodon server';

  @override
  String get txt_hint_server_explorer => 'mastodon.social or keyword';

  @override
  String get txt_desc_preference_system_theme => 'The system theme';

  @override
  String err_invalid_instance(Object domain) {
    return 'invalid Mastodon server domain: $domain';
  }

  @override
  String get msg_preference_engineer_clear_cache =>
      'Cache cleared successfully';

  @override
  String get dots => '...';
}
