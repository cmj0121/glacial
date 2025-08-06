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
  String get btn_sidebar_sign_in => 'Sign In';

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
  String get btn_timeline_home => 'Home';

  @override
  String get btn_timeline_local => 'Local';

  @override
  String get btn_timeline_federal => 'Federal';

  @override
  String get btn_timeline_public => 'Public';

  @override
  String get btn_timeline_favourites => 'Favourites';

  @override
  String get btn_timeline_bookmarks => 'Bookmarks';

  @override
  String get btn_preference_theme => 'Theme';

  @override
  String get btn_preference_engineer => 'Engineer Settings';

  @override
  String get btn_preference_engineer_clear_cache => 'Clear All Cache';

  @override
  String get btn_interaction_reply => 'Reply';

  @override
  String get btn_interaction_reblog => 'Reblog';

  @override
  String get btn_interaction_favourite => 'Favourite';

  @override
  String get btn_interaction_bookmark => 'Bookmark';

  @override
  String get btn_interaction_share => 'Share';

  @override
  String get btn_interaction_mute => 'Mute';

  @override
  String get btn_interaction_block => 'Block';

  @override
  String get btn_interaction_edit => 'Edit';

  @override
  String get btn_interaction_delete => 'Delete';

  @override
  String get btn_profile_core => 'Profile';

  @override
  String get btn_profile_post => 'Toots';

  @override
  String get btn_profile_pin => 'Pinned';

  @override
  String get btn_profile_scheduled => 'Scheduled Toots';

  @override
  String get btn_profile_hashtag => 'Following Hashtags';

  @override
  String get btn_profile_mute => 'Muted Users';

  @override
  String get btn_profile_block => 'Blocked Users';

  @override
  String get btn_status_toot => 'Toot';

  @override
  String get btn_status_scheduled => 'Scheduled Toot';

  @override
  String get desc_preference_engineer_clear_cache =>
      'Clear all cached data and reset the app';

  @override
  String get txt_spoiler => 'Spoiler';

  @override
  String get txt_search_history => 'Search History';

  @override
  String get txt_helper_server_explorer => 'Search for a Mastodon server';

  @override
  String get txt_hint_server_explorer => 'mastodon.social or keyword';

  @override
  String get txt_desc_preference_system_theme => 'The system theme';

  @override
  String get txt_visibility_public => 'Public';

  @override
  String get txt_visibility_unlisted => 'Unlisted';

  @override
  String get txt_visibility_private => 'Private';

  @override
  String get txt_visibility_direct => 'Direct';

  @override
  String get txt_suggestion_staff => 'Staff Recommendation';

  @override
  String get txt_suggestion_past_interactions => 'Interacted previously';

  @override
  String get txt_suggestion_global => 'Global Popularity';

  @override
  String get txt_poll_show_total => 'Show Total';

  @override
  String get txt_poll_hide_total => 'Hide Total';

  @override
  String get txt_poll_single => 'Single Choice';

  @override
  String get txt_poll_multiple => 'Multiple Choices';

  @override
  String get txt_preference_status => 'Status Settings';

  @override
  String get txt_preference_visibiliby => 'Visibility';

  @override
  String get txt_preference_sensitive => 'Sensitive Content';

  @override
  String get txt_show_less => 'Show Less';

  @override
  String get txt_show_more => 'Show More';

  @override
  String get desc_preference_status =>
      'Setup and control your default status behavior';

  @override
  String get desc_poll_show_hide_total =>
      'Show/Hide vote counts until the poll ends';

  @override
  String get desc_preference_visibility =>
      'Control who can see and list the status';

  @override
  String get desc_preference_sensitive =>
      'Show/Hide the sensitive content as default action';

  @override
  String get desc_visibility_public => 'Everyone can list and view this toot';

  @override
  String get desc_visibility_unlisted =>
      'Public but not been listed in the timeline';

  @override
  String get desc_visibility_private => 'The follower and the mentioned user';

  @override
  String get desc_visibility_direct => 'Only the mentioned user';

  @override
  String err_invalid_instance(Object domain) {
    return 'invalid Mastodon server domain: $domain';
  }

  @override
  String get msg_preference_engineer_clear_cache =>
      'Cache cleared successfully';

  @override
  String get msg_copied_to_clipboard => 'Copy to clipboard';

  @override
  String get dots => '...';
}
