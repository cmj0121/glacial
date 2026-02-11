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
  String get btn_save => 'Save';

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
  String get btn_drawer_announcement => 'Announcements';

  @override
  String get btn_drawer_preference => 'Preference';

  @override
  String get btn_drawer_logout => 'Logout';

  @override
  String get btn_dismiss => 'Dismiss';

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
  String get btn_interaction_mute => 'Mute conversation';

  @override
  String get btn_interaction_block => 'Block';

  @override
  String get btn_interaction_report => 'Report';

  @override
  String get btn_interaction_edit => 'Edit';

  @override
  String get btn_interaction_delete => 'Delete';

  @override
  String get btn_interaction_quote => 'Quote';

  @override
  String get btn_interaction_filter => 'Filter';

  @override
  String get btn_interaction_pin => 'Pin';

  @override
  String get btn_interaction_policy => 'Policy';

  @override
  String get btn_status_info => 'View interactions';

  @override
  String get btn_status_history => 'View edit history';

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
  String get btn_profile_filter => 'Filters';

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
  String get btn_relationship_note => 'Personal note';

  @override
  String get desc_relationship_note => 'Add a personal note about this account';

  @override
  String get btn_relationship_endorse => 'Feature on profile';

  @override
  String get btn_relationship_unendorse => 'Unfeature from profile';

  @override
  String get btn_relationship_remove_follower => 'Remove follower';

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
  String get btn_filter_warn => 'Warn';

  @override
  String get btn_filter_hide => 'Hide';

  @override
  String get btn_filter_blur => 'Blur';

  @override
  String get btn_filter_context_home => 'Home timeline';

  @override
  String get btn_filter_context_notification => 'Notifications timeline';

  @override
  String get btn_filter_context_public => 'Public timeline';

  @override
  String get btn_filter_context_thread => 'The toot and its replies';

  @override
  String get btn_filter_context_account => 'The profile page';

  @override
  String get btn_filter_whole_match => 'Whole word';

  @override
  String get btn_filter_partial_match => 'Partial match';

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
  String get btn_translate_show => 'Translate';

  @override
  String get btn_translate_hide => 'Show original';

  @override
  String get txt_familiar_followers => 'Also followed by';

  @override
  String get txt_featured_tags => 'Featured tags';

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
  String get txt_filter_title => 'Select a filter to apply';

  @override
  String get txt_filter_applied => 'Filter already applied';

  @override
  String get txt_filter_name => 'The name of the filter';

  @override
  String get txt_filter_expired => 'Expired';

  @override
  String get txt_filter_never => 'Never';

  @override
  String get txt_quote_policy_public => 'Public';

  @override
  String get txt_quote_policy_followers => 'Followers';

  @override
  String get txt_quote_policy_nobody => 'Nobody';

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
  String get txt_preference_timeline => 'Timeline Settings';

  @override
  String get desc_preference_timeline =>
      'Control what appears in your timeline';

  @override
  String get txt_preference_hide_replies => 'Hide Replies';

  @override
  String get desc_preference_hide_replies => 'Hide replies from your timeline';

  @override
  String get txt_preference_hide_reblogs => 'Hide Reblogs';

  @override
  String get desc_preference_hide_reblogs => 'Hide reblogs from your timeline';

  @override
  String get txt_preference_auto_play => 'Auto-play Videos';

  @override
  String get desc_preference_auto_play =>
      'Automatically play videos in timeline';

  @override
  String get txt_preference_timeline_limit => 'Timeline Size';

  @override
  String get desc_preference_timeline_limit => 'Maximum posts to load at once';

  @override
  String get txt_preference_image_quality => 'Image Quality';

  @override
  String get txt_preference_image_low => 'Low (saves data)';

  @override
  String get txt_preference_image_medium => 'Medium';

  @override
  String get txt_preference_image_high => 'High (original)';

  @override
  String get txt_preference_appearance => 'Appearance';

  @override
  String get desc_preference_appearance => 'Customize how the app looks';

  @override
  String get txt_preference_font_scale => 'Font Size';

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
  String get desc_filter_warn =>
      'Show a warning that identifies the matching filter by title.';

  @override
  String get desc_filter_hide => 'Do not show this status if it is received.';

  @override
  String get desc_filter_blur =>
      'Hide the content behind the sensitive content';

  @override
  String get desc_filter_context_home =>
      'Any matched toots show in the home timeline';

  @override
  String get desc_filter_context_notification => 'Any matched notifications';

  @override
  String get desc_filter_context_public =>
      'Any matched toots show in the public timeline';

  @override
  String get desc_filter_context_thread => 'Any matched toots and its replies';

  @override
  String get desc_filter_context_account => 'Any matched account profile page';

  @override
  String get desc_filter_expiration => 'When the filter will expire';

  @override
  String get desc_filter_context => 'Where the filter should be applied';

  @override
  String get desc_quote_approval_public => 'Anyone can quote this status.';

  @override
  String get desc_quote_approval_followers =>
      'Only followers can quote this status.';

  @override
  String get desc_quote_approval_following =>
      'Only people followed by the author can quote this status.';

  @override
  String get desc_quote_approval_unsupport => 'No supported quote policy.';

  @override
  String get desc_quote_policy => 'Quote Policy';

  @override
  String get desc_quote_policy_public => 'Anyone can quote this status.';

  @override
  String get desc_quote_policy_followers =>
      'Only followers can quote this status.';

  @override
  String get desc_quote_policy_nobody => 'No one can quote this status.';

  @override
  String get desc_quote_removed => 'The Quote Status is Unavailable';

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
  String get txt_notification_policy => 'Notification Policy';

  @override
  String get txt_notification_policy_not_following =>
      'People you don\'t follow';

  @override
  String get txt_notification_policy_not_followers =>
      'People not following you';

  @override
  String get txt_notification_policy_new_accounts => 'New accounts';

  @override
  String get txt_notification_policy_private_mentions => 'Private mentions';

  @override
  String get txt_notification_policy_limited_accounts => 'Moderated accounts';

  @override
  String get txt_notification_policy_accept => 'Accept';

  @override
  String get txt_notification_policy_filter => 'Filter';

  @override
  String get txt_notification_policy_drop => 'Drop';

  @override
  String get txt_no_announcements => 'No announcements from this server';

  @override
  String txt_poll_votes(int count) {
    return '$count votes';
  }

  @override
  String get txt_media_alt_text => 'Alt Text';

  @override
  String get txt_media_image_info => 'Image Info';

  @override
  String get txt_media_no_exif => 'No EXIF data available';

  @override
  String get txt_server_rules => 'Server Rules';

  @override
  String get txt_server_registration => 'Registration';

  @override
  String get txt_about_app_version => 'App Version';

  @override
  String get txt_about_author => 'Author';

  @override
  String get txt_about_repository => 'Repository';

  @override
  String get txt_about_copyright => 'Copyright';

  @override
  String get btn_sidebar_conversations => 'Conversations';

  @override
  String get txt_no_conversations => 'No conversations';

  @override
  String get txt_conversation_unread => 'Unread';

  @override
  String get btn_drawer_domain_blocks => 'Blocked Domains';

  @override
  String get btn_drawer_endorsed => 'Featured Profiles';

  @override
  String get txt_no_domain_blocks => 'No blocked domains';

  @override
  String get btn_admin_reports => 'Reports';

  @override
  String get btn_admin_accounts => 'Accounts';

  @override
  String get btn_admin_approve => 'Approve';

  @override
  String get btn_admin_reject => 'Reject';

  @override
  String get btn_admin_suspend => 'Suspend';

  @override
  String get btn_admin_silence => 'Silence';

  @override
  String get btn_admin_enable => 'Enable';

  @override
  String get btn_admin_unsilence => 'Unsilence';

  @override
  String get btn_admin_unsuspend => 'Unsuspend';

  @override
  String get btn_admin_unsensitive => 'Unsensitive';

  @override
  String get btn_admin_assign => 'Assign to me';

  @override
  String get btn_admin_unassign => 'Unassign';

  @override
  String get btn_admin_resolve => 'Resolve';

  @override
  String get btn_admin_reopen => 'Reopen';

  @override
  String get txt_admin_no_permission => 'Admin access required';

  @override
  String get txt_admin_no_reports => 'No reports';

  @override
  String get txt_admin_no_accounts => 'No accounts found';

  @override
  String get txt_admin_report_resolved => 'Resolved';

  @override
  String get txt_admin_report_unresolved => 'Unresolved';

  @override
  String get txt_admin_account_active => 'Active';

  @override
  String get txt_admin_account_pending => 'Pending';

  @override
  String get txt_admin_account_disabled => 'Disabled';

  @override
  String get txt_admin_account_silenced => 'Silenced';

  @override
  String get txt_admin_account_suspended => 'Suspended';

  @override
  String get txt_admin_confirm_action => 'Confirm Action';

  @override
  String get desc_admin_confirm_action =>
      'This action cannot be easily undone. Are you sure?';

  @override
  String get txt_admin_report_by => 'Reported by';

  @override
  String get txt_admin_assigned_to => 'Assigned to';

  @override
  String get btn_register => 'Create Account';

  @override
  String get txt_register_title => 'Create Account';

  @override
  String get txt_username => 'Username';

  @override
  String get txt_email => 'Email';

  @override
  String get txt_password => 'Password';

  @override
  String get txt_confirm_password => 'Confirm Password';

  @override
  String get txt_agreement =>
      'I agree to the server rules and terms of service';

  @override
  String get txt_reason => 'Reason for joining';

  @override
  String get txt_registration_success =>
      'Check your email to confirm your account';

  @override
  String get err_registration_failed => 'Registration failed';

  @override
  String get err_field_required => 'This field is required';

  @override
  String get err_invalid_email => 'Invalid email address';

  @override
  String get err_password_too_short => 'Password must be at least 8 characters';

  @override
  String get err_password_mismatch => 'Passwords do not match';

  @override
  String get err_agreement_required => 'You must agree to the terms';

  @override
  String get txt_admin_account_confirmed => 'Confirmed';

  @override
  String get txt_admin_account_unconfirmed => 'Unconfirmed';

  @override
  String get txt_admin_account_approved => 'Approved';

  @override
  String get txt_admin_account_not_approved => 'Not approved';

  @override
  String get txt_work_in_progress => 'Work in Progress';

  @override
  String get txt_default_server_name => 'Glacial Server';

  @override
  String txt_hashtag_usage(int uses) {
    return '$uses used in the past days';
  }

  @override
  String get dots => '...';
}
