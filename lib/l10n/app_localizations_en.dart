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
  String get btn_sidebar_notifications => 'Notifications';

  @override
  String get btn_sidebar_management => 'Managements';

  @override
  String get btn_sidebar_post => 'Toot';

  @override
  String get btn_sidebar_sign_in => 'Sign In';

  @override
  String get btn_drawer_switch_server => 'Switch Server';

  @override
  String get btn_drawer_directory => 'Explore Account';

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
  String get btn_timeline_list => 'Lists';

  @override
  String get btn_timeline_vote => 'Vote';

  @override
  String btn_timeline_unread(Object count) {
    return '#$count Unread Toots';
  }

  @override
  String get btn_preference_theme => 'Theme';

  @override
  String get btn_preference_engineer => 'Engineer Settings';

  @override
  String get btn_preference_about => 'About';

  @override
  String get btn_preference_engineer_clear_cache => 'Clear All Cache';

  @override
  String get btn_preference_engineer_reset => 'Reset system';

  @override
  String get btn_preference_engineer_test_notifier => 'Test Notification';

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
  String get btn_interaction_report => 'Report';

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
  String get btn_profile_followers => 'Followers';

  @override
  String get btn_profile_following => 'Following';

  @override
  String get btn_profile_scheduled => 'Scheduled Toots';

  @override
  String get btn_profile_hashtag => 'Following Hashtags';

  @override
  String get btn_profile_mute => 'Muted Users';

  @override
  String get btn_profile_block => 'Blocked Users';

  @override
  String get btn_profile_general_info => 'General Info';

  @override
  String get btn_profile_privacy => 'Privacy Settings';

  @override
  String get btn_status_toot => 'Toot';

  @override
  String get btn_status_edit => 'Edit';

  @override
  String get btn_status_scheduled => 'Scheduled Toot';

  @override
  String get btn_relationship_following => 'Following';

  @override
  String get btn_relationship_followed_by => 'Followed by';

  @override
  String get btn_relationship_follow_each_other => 'Be friend';

  @override
  String get btn_relationship_follow_request => 'Requested and wait approved';

  @override
  String get btn_relationship_stranger => 'Stranger';

  @override
  String get btn_relationship_blocked_by => 'Blocked By';

  @override
  String btn_relationship_mute(Object acct) {
    return 'Mute $acct';
  }

  @override
  String btn_relationship_unmute(Object acct) {
    return 'Unmute $acct';
  }

  @override
  String btn_relationship_block(Object acct) {
    return 'Block $acct';
  }

  @override
  String btn_relationship_unblock(Object acct) {
    return 'Unblock $acct';
  }

  @override
  String btn_relationship_report(Object acct) {
    return 'Report $acct';
  }

  @override
  String get btn_notification_mention => 'Mentioned';

  @override
  String get btn_notification_status => 'Notification';

  @override
  String get btn_notification_reblog => 'Reblog';

  @override
  String get btn_notification_follow => 'Followed';

  @override
  String get btn_notification_follow_request => 'Follow Request';

  @override
  String get btn_notification_favourite => 'Favourite';

  @override
  String get btn_notification_poll => 'Poll';

  @override
  String get btn_notification_update => 'Update';

  @override
  String get btn_notification_admin_sign_up => 'New SignUp';

  @override
  String get btn_notification_admin_report => 'New Report';

  @override
  String get btn_notification_unknown => 'Unknown';

  @override
  String get btn_follow_request_accept => 'Accept';

  @override
  String get btn_follow_request_reject => 'Reject';

  @override
  String get btn_report_back => 'Back';

  @override
  String get btn_report_next => 'Next';

  @override
  String get btn_report_file => 'File Report';

  @override
  String get btn_report_statuses => 'Toots';

  @override
  String get btn_report_rules => 'Rules';

  @override
  String get desc_preference_engineer_clear_cache => 'Clear all cached data';

  @override
  String get desc_preference_engineer_reset =>
      'Clear all settings and reset the app';

  @override
  String get desc_preference_engineer_test_notifier =>
      'Test send the notification in local device';

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
  String get txt_preference_refresh_interval => 'Refresh Interval';

  @override
  String get txt_preference_loaded_top => 'Align when loaded newest';

  @override
  String get txt_preference_reply_all => 'Everyone mentioned';

  @override
  String get txt_preference_reply_only => 'Only the poster';

  @override
  String get txt_preference_reply_none => 'Tag no one';

  @override
  String get txt_show_less => 'Show Less';

  @override
  String get txt_show_more => 'Show More';

  @override
  String get txt_no_result => 'No results found';

  @override
  String get txt_profile_bot => 'Bot Account';

  @override
  String get txt_profile_locked => 'Account Locked';

  @override
  String get txt_profile_discoverable =>
      'Account can be discoverable in public';

  @override
  String get txt_profile_post_indexable => 'The privacy of the public post';

  @override
  String get txt_profile_hide_collections =>
      'Display the follower and following';

  @override
  String get txt_profile_general_name => 'Display Name';

  @override
  String get txt_profile_general_bio => 'Bio';

  @override
  String get txt_list_policy_followed => 'Show replies to any followed user';

  @override
  String get txt_list_policy_list => 'Show replies to members of the list';

  @override
  String get txt_list_policy_none => 'Do not show any replies';

  @override
  String get txt_list_exclusive => 'Removed from the Home timeline feed';

  @override
  String get txt_list_inclusive => 'Keep it in the Home timeline feed';

  @override
  String get txt_report_spam => 'Spam';

  @override
  String get txt_report_legal => 'Illegal Content';

  @override
  String get txt_report_violation => 'Rule Violation';

  @override
  String get txt_report_other => 'Other';

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
  String get desc_preference_refresh_interval =>
      'The interval to refresh the app\'s data';

  @override
  String get desc_preference_loaded_top =>
      'Load the newest data and jump to top when tapping the icon';

  @override
  String get desc_preference_locale => 'The system locale would be used to';

  @override
  String get desc_profile_bot =>
      'The account may perform automated actions and not monitored by humans';

  @override
  String get desc_profile_locked => 'Manually approves follow requests';

  @override
  String get desc_profile_discoverable =>
      'Account can be discoverable in the profile directory';

  @override
  String get desc_profile_post_indexable =>
      'The public post cannot be searchable';

  @override
  String get desc_profile_hide_collections =>
      'Everyone can follow-up your following and follower in your profile page';

  @override
  String get desc_preference_reply_all => 'Tag everyone mentioned in post';

  @override
  String get desc_preference_reply_only => 'Only tag the poster';

  @override
  String get desc_preference_reply_none => 'Tag no one';

  @override
  String get desc_create_list => 'Create a new List';

  @override
  String get desc_list_search_following =>
      'Search the following account to add into List';

  @override
  String get desc_report_spam =>
      'The account is posting unsolicited advertisements.';

  @override
  String get desc_report_legal =>
      'The account is posting illegal content or requesting illegal actions.';

  @override
  String get desc_report_violation =>
      'The account is posting content that violates the rules of the instance.';

  @override
  String get desc_report_other => 'Other reasons not listed.';

  @override
  String get desc_report_comment =>
      'Add the optional comment to provide more context about your report';

  @override
  String err_invalid_instance(Object domain) {
    return 'invalid Mastodon server domain: $domain';
  }

  @override
  String get msg_preference_engineer_clear_cache =>
      'Cache cleared successfully';

  @override
  String get msg_preference_engineer_reset => 'Reset successfully';

  @override
  String get msg_copied_to_clipboard => 'Copy to clipboard';

  @override
  String get msg_notification_title => 'New Notifications';

  @override
  String msg_notification_body(Object count) {
    return 'You have $count unread notifications';
  }

  @override
  String msg_follow_request(Object name) {
    return 'Follow Request from $name';
  }

  @override
  String get dots => '...';
}
