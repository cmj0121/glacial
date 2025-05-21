// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get txt_app_name => 'glacial';

  @override
  String get txt_search_mastodon => 'mastodon.social';

  @override
  String get txt_search_hint => 'Enter to Search ...';

  @override
  String get txt_search_helper => 'Search for something interesting';

  @override
  String get txt_search_history => 'Search history';

  @override
  String get txt_invalid_instance => 'Invalid Mastodon server';

  @override
  String get txt_server_contact => 'Contact Info';

  @override
  String get txt_server_rules => 'Server Rules';

  @override
  String get txt_public => 'Public';

  @override
  String get txt_unlisted => 'Unlisted';

  @override
  String get txt_private => 'Private';

  @override
  String get txt_direct => 'Direct';

  @override
  String get txt_copied_to_clipboard => 'Copy to Clipboard';

  @override
  String txt_trends_uses(Object uses) {
    return '$uses used in the past days';
  }

  @override
  String get txt_show_less => 'Show less';

  @override
  String get txt_show_more => 'Show more';

  @override
  String get btn_clean_all => 'Clean All';

  @override
  String get btn_back_to_explorer => 'Back to Explorer';

  @override
  String get btn_sign_in => 'Sign In';

  @override
  String get btn_timeline => 'Timeline';

  @override
  String get btn_trending => 'Trending';

  @override
  String get btn_notifications => 'Notification';

  @override
  String get btn_explore => 'Explore';

  @override
  String get btn_settings => 'Settings';

  @override
  String get btn_post => 'Post';

  @override
  String get btn_home_timeline => 'Home';

  @override
  String get btn_local_timeline => 'Local';

  @override
  String get btn_federal_timeline => 'Federal';

  @override
  String get btn_public_timeline => 'Public';

  @override
  String get btn_bookmarks_timeline => 'Bookmarks';

  @override
  String get btn_favourites_timeline => 'Favourites';

  @override
  String get btn_hashtag_timeline => 'Hashtag';

  @override
  String get btn_reply => 'Reply';

  @override
  String get btn_reblog => 'Reblog';

  @override
  String get btn_favourite => 'Favourite';

  @override
  String get btn_bookmark => 'Bookmark';

  @override
  String get btn_share => 'Share';

  @override
  String get btn_mute => 'Mute';

  @override
  String get btn_block => 'Block';

  @override
  String get btn_delete => 'Delete';

  @override
  String get dots => '...';
}
