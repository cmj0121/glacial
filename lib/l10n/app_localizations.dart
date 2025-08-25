import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('ja'),
    Locale('ko'),
    Locale('pt'),
    Locale('zh'),
  ];

  /// No description provided for @btn_search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get btn_search;

  /// No description provided for @btn_close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get btn_close;

  /// No description provided for @btn_clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get btn_clear;

  /// No description provided for @btn_exit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get btn_exit;

  /// No description provided for @btn_reload.
  ///
  /// In en, this message translates to:
  /// **'Reload'**
  String get btn_reload;

  /// No description provided for @btn_history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get btn_history;

  /// No description provided for @btn_sidebar_timelines.
  ///
  /// In en, this message translates to:
  /// **'Timelines'**
  String get btn_sidebar_timelines;

  /// No description provided for @btn_sidebar_lists.
  ///
  /// In en, this message translates to:
  /// **'Lists'**
  String get btn_sidebar_lists;

  /// No description provided for @btn_sidebar_trendings.
  ///
  /// In en, this message translates to:
  /// **'Trendings'**
  String get btn_sidebar_trendings;

  /// No description provided for @btn_sidebar_notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get btn_sidebar_notifications;

  /// No description provided for @btn_sidebar_management.
  ///
  /// In en, this message translates to:
  /// **'Managements'**
  String get btn_sidebar_management;

  /// No description provided for @btn_sidebar_post.
  ///
  /// In en, this message translates to:
  /// **'Toot'**
  String get btn_sidebar_post;

  /// No description provided for @btn_sidebar_sign_in.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get btn_sidebar_sign_in;

  /// No description provided for @btn_drawer_switch_server.
  ///
  /// In en, this message translates to:
  /// **'Switch Server'**
  String get btn_drawer_switch_server;

  /// No description provided for @btn_drawer_directory.
  ///
  /// In en, this message translates to:
  /// **'Explore Account'**
  String get btn_drawer_directory;

  /// No description provided for @btn_drawer_preference.
  ///
  /// In en, this message translates to:
  /// **'Preference'**
  String get btn_drawer_preference;

  /// No description provided for @btn_drawer_logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get btn_drawer_logout;

  /// No description provided for @btn_trends_links.
  ///
  /// In en, this message translates to:
  /// **'Links'**
  String get btn_trends_links;

  /// No description provided for @btn_trends_toots.
  ///
  /// In en, this message translates to:
  /// **'Toots'**
  String get btn_trends_toots;

  /// No description provided for @btn_trends_users.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get btn_trends_users;

  /// No description provided for @btn_trends_tags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get btn_trends_tags;

  /// No description provided for @btn_timeline_home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get btn_timeline_home;

  /// No description provided for @btn_timeline_local.
  ///
  /// In en, this message translates to:
  /// **'Local'**
  String get btn_timeline_local;

  /// No description provided for @btn_timeline_federal.
  ///
  /// In en, this message translates to:
  /// **'Federal'**
  String get btn_timeline_federal;

  /// No description provided for @btn_timeline_public.
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get btn_timeline_public;

  /// No description provided for @btn_timeline_favourites.
  ///
  /// In en, this message translates to:
  /// **'Favourites'**
  String get btn_timeline_favourites;

  /// No description provided for @btn_timeline_bookmarks.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks'**
  String get btn_timeline_bookmarks;

  /// No description provided for @btn_timeline_list.
  ///
  /// In en, this message translates to:
  /// **'Lists'**
  String get btn_timeline_list;

  /// No description provided for @btn_timeline_vote.
  ///
  /// In en, this message translates to:
  /// **'Vote'**
  String get btn_timeline_vote;

  /// No description provided for @btn_preference_theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get btn_preference_theme;

  /// No description provided for @btn_preference_engineer.
  ///
  /// In en, this message translates to:
  /// **'Engineer Settings'**
  String get btn_preference_engineer;

  /// No description provided for @btn_preference_about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get btn_preference_about;

  /// No description provided for @btn_preference_engineer_clear_cache.
  ///
  /// In en, this message translates to:
  /// **'Clear All Cache'**
  String get btn_preference_engineer_clear_cache;

  /// No description provided for @btn_preference_engineer_reset.
  ///
  /// In en, this message translates to:
  /// **'Reset system'**
  String get btn_preference_engineer_reset;

  /// No description provided for @btn_preference_engineer_test_notifier.
  ///
  /// In en, this message translates to:
  /// **'Test Notification'**
  String get btn_preference_engineer_test_notifier;

  /// No description provided for @btn_interaction_reply.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get btn_interaction_reply;

  /// No description provided for @btn_interaction_reblog.
  ///
  /// In en, this message translates to:
  /// **'Reblog'**
  String get btn_interaction_reblog;

  /// No description provided for @btn_interaction_favourite.
  ///
  /// In en, this message translates to:
  /// **'Favourite'**
  String get btn_interaction_favourite;

  /// No description provided for @btn_interaction_bookmark.
  ///
  /// In en, this message translates to:
  /// **'Bookmark'**
  String get btn_interaction_bookmark;

  /// No description provided for @btn_interaction_share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get btn_interaction_share;

  /// No description provided for @btn_interaction_mute.
  ///
  /// In en, this message translates to:
  /// **'Mute'**
  String get btn_interaction_mute;

  /// No description provided for @btn_interaction_block.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get btn_interaction_block;

  /// No description provided for @btn_interaction_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get btn_interaction_edit;

  /// No description provided for @btn_interaction_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get btn_interaction_delete;

  /// No description provided for @btn_profile_core.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get btn_profile_core;

  /// No description provided for @btn_profile_post.
  ///
  /// In en, this message translates to:
  /// **'Toots'**
  String get btn_profile_post;

  /// No description provided for @btn_profile_pin.
  ///
  /// In en, this message translates to:
  /// **'Pinned'**
  String get btn_profile_pin;

  /// No description provided for @btn_profile_followers.
  ///
  /// In en, this message translates to:
  /// **'Followers'**
  String get btn_profile_followers;

  /// No description provided for @btn_profile_following.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get btn_profile_following;

  /// No description provided for @btn_profile_scheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled Toots'**
  String get btn_profile_scheduled;

  /// No description provided for @btn_profile_hashtag.
  ///
  /// In en, this message translates to:
  /// **'Following Hashtags'**
  String get btn_profile_hashtag;

  /// No description provided for @btn_profile_mute.
  ///
  /// In en, this message translates to:
  /// **'Muted Users'**
  String get btn_profile_mute;

  /// No description provided for @btn_profile_block.
  ///
  /// In en, this message translates to:
  /// **'Blocked Users'**
  String get btn_profile_block;

  /// No description provided for @btn_profile_general_info.
  ///
  /// In en, this message translates to:
  /// **'General Info'**
  String get btn_profile_general_info;

  /// No description provided for @btn_profile_privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Settings'**
  String get btn_profile_privacy;

  /// No description provided for @btn_status_toot.
  ///
  /// In en, this message translates to:
  /// **'Toot'**
  String get btn_status_toot;

  /// No description provided for @btn_status_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get btn_status_edit;

  /// No description provided for @btn_status_scheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled Toot'**
  String get btn_status_scheduled;

  /// No description provided for @btn_relationship_following.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get btn_relationship_following;

  /// No description provided for @btn_relationship_followed_by.
  ///
  /// In en, this message translates to:
  /// **'Followed by'**
  String get btn_relationship_followed_by;

  /// No description provided for @btn_relationship_follow_each_other.
  ///
  /// In en, this message translates to:
  /// **'Be friend'**
  String get btn_relationship_follow_each_other;

  /// No description provided for @btn_relationship_follow_request.
  ///
  /// In en, this message translates to:
  /// **'Requested and wait approved'**
  String get btn_relationship_follow_request;

  /// No description provided for @btn_relationship_stranger.
  ///
  /// In en, this message translates to:
  /// **'Stranger'**
  String get btn_relationship_stranger;

  /// No description provided for @btn_relationship_blocked_by.
  ///
  /// In en, this message translates to:
  /// **'Blocked By'**
  String get btn_relationship_blocked_by;

  /// No description provided for @btn_relationship_mute.
  ///
  /// In en, this message translates to:
  /// **'Mute {acct}'**
  String btn_relationship_mute(Object acct);

  /// No description provided for @btn_relationship_unmute.
  ///
  /// In en, this message translates to:
  /// **'Unmute {acct}'**
  String btn_relationship_unmute(Object acct);

  /// No description provided for @btn_relationship_block.
  ///
  /// In en, this message translates to:
  /// **'Block {acct}'**
  String btn_relationship_block(Object acct);

  /// No description provided for @btn_relationship_unblock.
  ///
  /// In en, this message translates to:
  /// **'Unblock {acct}'**
  String btn_relationship_unblock(Object acct);

  /// No description provided for @btn_relationship_report.
  ///
  /// In en, this message translates to:
  /// **'Report {acct}'**
  String btn_relationship_report(Object acct);

  /// No description provided for @btn_notification_mention.
  ///
  /// In en, this message translates to:
  /// **'Mentioned'**
  String get btn_notification_mention;

  /// No description provided for @btn_notification_status.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get btn_notification_status;

  /// No description provided for @btn_notification_reblog.
  ///
  /// In en, this message translates to:
  /// **'Reblog'**
  String get btn_notification_reblog;

  /// No description provided for @btn_notification_follow.
  ///
  /// In en, this message translates to:
  /// **'Followed'**
  String get btn_notification_follow;

  /// No description provided for @btn_notification_follow_request.
  ///
  /// In en, this message translates to:
  /// **'Follow Request'**
  String get btn_notification_follow_request;

  /// No description provided for @btn_notification_favourite.
  ///
  /// In en, this message translates to:
  /// **'Favourite'**
  String get btn_notification_favourite;

  /// No description provided for @btn_notification_poll.
  ///
  /// In en, this message translates to:
  /// **'Poll'**
  String get btn_notification_poll;

  /// No description provided for @btn_notification_update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get btn_notification_update;

  /// No description provided for @btn_notification_admin_sign_up.
  ///
  /// In en, this message translates to:
  /// **'New SignUp'**
  String get btn_notification_admin_sign_up;

  /// No description provided for @btn_notification_admin_report.
  ///
  /// In en, this message translates to:
  /// **'New Report'**
  String get btn_notification_admin_report;

  /// No description provided for @btn_notification_unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get btn_notification_unknown;

  /// No description provided for @btn_follow_request_accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get btn_follow_request_accept;

  /// No description provided for @btn_follow_request_reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get btn_follow_request_reject;

  /// No description provided for @desc_preference_engineer_clear_cache.
  ///
  /// In en, this message translates to:
  /// **'Clear all cached data'**
  String get desc_preference_engineer_clear_cache;

  /// No description provided for @desc_preference_engineer_reset.
  ///
  /// In en, this message translates to:
  /// **'Clear all settings and reset the app'**
  String get desc_preference_engineer_reset;

  /// No description provided for @desc_preference_engineer_test_notifier.
  ///
  /// In en, this message translates to:
  /// **'Test send the notification in local device'**
  String get desc_preference_engineer_test_notifier;

  /// No description provided for @txt_spoiler.
  ///
  /// In en, this message translates to:
  /// **'Spoiler'**
  String get txt_spoiler;

  /// No description provided for @txt_search_history.
  ///
  /// In en, this message translates to:
  /// **'Search History'**
  String get txt_search_history;

  /// No description provided for @txt_helper_server_explorer.
  ///
  /// In en, this message translates to:
  /// **'Search for a Mastodon server'**
  String get txt_helper_server_explorer;

  /// No description provided for @txt_hint_server_explorer.
  ///
  /// In en, this message translates to:
  /// **'mastodon.social or keyword'**
  String get txt_hint_server_explorer;

  /// No description provided for @txt_desc_preference_system_theme.
  ///
  /// In en, this message translates to:
  /// **'The system theme'**
  String get txt_desc_preference_system_theme;

  /// No description provided for @txt_visibility_public.
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get txt_visibility_public;

  /// No description provided for @txt_visibility_unlisted.
  ///
  /// In en, this message translates to:
  /// **'Unlisted'**
  String get txt_visibility_unlisted;

  /// No description provided for @txt_visibility_private.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get txt_visibility_private;

  /// No description provided for @txt_visibility_direct.
  ///
  /// In en, this message translates to:
  /// **'Direct'**
  String get txt_visibility_direct;

  /// No description provided for @txt_suggestion_staff.
  ///
  /// In en, this message translates to:
  /// **'Staff Recommendation'**
  String get txt_suggestion_staff;

  /// No description provided for @txt_suggestion_past_interactions.
  ///
  /// In en, this message translates to:
  /// **'Interacted previously'**
  String get txt_suggestion_past_interactions;

  /// No description provided for @txt_suggestion_global.
  ///
  /// In en, this message translates to:
  /// **'Global Popularity'**
  String get txt_suggestion_global;

  /// No description provided for @txt_poll_show_total.
  ///
  /// In en, this message translates to:
  /// **'Show Total'**
  String get txt_poll_show_total;

  /// No description provided for @txt_poll_hide_total.
  ///
  /// In en, this message translates to:
  /// **'Hide Total'**
  String get txt_poll_hide_total;

  /// No description provided for @txt_poll_single.
  ///
  /// In en, this message translates to:
  /// **'Single Choice'**
  String get txt_poll_single;

  /// No description provided for @txt_poll_multiple.
  ///
  /// In en, this message translates to:
  /// **'Multiple Choices'**
  String get txt_poll_multiple;

  /// No description provided for @txt_preference_status.
  ///
  /// In en, this message translates to:
  /// **'Status Settings'**
  String get txt_preference_status;

  /// No description provided for @txt_preference_visibiliby.
  ///
  /// In en, this message translates to:
  /// **'Visibility'**
  String get txt_preference_visibiliby;

  /// No description provided for @txt_preference_sensitive.
  ///
  /// In en, this message translates to:
  /// **'Sensitive Content'**
  String get txt_preference_sensitive;

  /// No description provided for @txt_preference_refresh_interval.
  ///
  /// In en, this message translates to:
  /// **'Refresh Interval'**
  String get txt_preference_refresh_interval;

  /// No description provided for @txt_preference_reply_all.
  ///
  /// In en, this message translates to:
  /// **'Everyone mentioned'**
  String get txt_preference_reply_all;

  /// No description provided for @txt_preference_reply_only.
  ///
  /// In en, this message translates to:
  /// **'Only the poster'**
  String get txt_preference_reply_only;

  /// No description provided for @txt_preference_reply_none.
  ///
  /// In en, this message translates to:
  /// **'Tag no one'**
  String get txt_preference_reply_none;

  /// No description provided for @txt_show_less.
  ///
  /// In en, this message translates to:
  /// **'Show Less'**
  String get txt_show_less;

  /// No description provided for @txt_show_more.
  ///
  /// In en, this message translates to:
  /// **'Show More'**
  String get txt_show_more;

  /// No description provided for @txt_no_result.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get txt_no_result;

  /// No description provided for @txt_profile_bot.
  ///
  /// In en, this message translates to:
  /// **'Bot Account'**
  String get txt_profile_bot;

  /// No description provided for @txt_profile_locked.
  ///
  /// In en, this message translates to:
  /// **'Account Locked'**
  String get txt_profile_locked;

  /// No description provided for @txt_profile_discoverable.
  ///
  /// In en, this message translates to:
  /// **'Account can be discoverable in public'**
  String get txt_profile_discoverable;

  /// No description provided for @txt_profile_post_indexable.
  ///
  /// In en, this message translates to:
  /// **'The privacy of the public post'**
  String get txt_profile_post_indexable;

  /// No description provided for @txt_profile_hide_collections.
  ///
  /// In en, this message translates to:
  /// **'Display the follower and following'**
  String get txt_profile_hide_collections;

  /// No description provided for @txt_profile_general_name.
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get txt_profile_general_name;

  /// No description provided for @txt_profile_general_bio.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get txt_profile_general_bio;

  /// No description provided for @txt_list_policy_followed.
  ///
  /// In en, this message translates to:
  /// **'Show replies to any followed user'**
  String get txt_list_policy_followed;

  /// No description provided for @txt_list_policy_list.
  ///
  /// In en, this message translates to:
  /// **'Show replies to members of the list'**
  String get txt_list_policy_list;

  /// No description provided for @txt_list_policy_none.
  ///
  /// In en, this message translates to:
  /// **'Do not show any replies'**
  String get txt_list_policy_none;

  /// No description provided for @txt_list_exclusive.
  ///
  /// In en, this message translates to:
  /// **'Removed from the Home timeline feed'**
  String get txt_list_exclusive;

  /// No description provided for @txt_list_inclusive.
  ///
  /// In en, this message translates to:
  /// **'Keep it in the Home timeline feed'**
  String get txt_list_inclusive;

  /// No description provided for @desc_preference_status.
  ///
  /// In en, this message translates to:
  /// **'Setup and control your default status behavior'**
  String get desc_preference_status;

  /// No description provided for @desc_poll_show_hide_total.
  ///
  /// In en, this message translates to:
  /// **'Show/Hide vote counts until the poll ends'**
  String get desc_poll_show_hide_total;

  /// No description provided for @desc_preference_visibility.
  ///
  /// In en, this message translates to:
  /// **'Control who can see and list the status'**
  String get desc_preference_visibility;

  /// No description provided for @desc_preference_sensitive.
  ///
  /// In en, this message translates to:
  /// **'Show/Hide the sensitive content as default action'**
  String get desc_preference_sensitive;

  /// No description provided for @desc_visibility_public.
  ///
  /// In en, this message translates to:
  /// **'Everyone can list and view this toot'**
  String get desc_visibility_public;

  /// No description provided for @desc_visibility_unlisted.
  ///
  /// In en, this message translates to:
  /// **'Public but not been listed in the timeline'**
  String get desc_visibility_unlisted;

  /// No description provided for @desc_visibility_private.
  ///
  /// In en, this message translates to:
  /// **'The follower and the mentioned user'**
  String get desc_visibility_private;

  /// No description provided for @desc_visibility_direct.
  ///
  /// In en, this message translates to:
  /// **'Only the mentioned user'**
  String get desc_visibility_direct;

  /// No description provided for @desc_preference_refresh_interval.
  ///
  /// In en, this message translates to:
  /// **'The interval to refresh the app\'s data'**
  String get desc_preference_refresh_interval;

  /// No description provided for @desc_preference_locale.
  ///
  /// In en, this message translates to:
  /// **'The system locale would be used to'**
  String get desc_preference_locale;

  /// No description provided for @desc_profile_bot.
  ///
  /// In en, this message translates to:
  /// **'The account may perform automated actions and not monitored by humans'**
  String get desc_profile_bot;

  /// No description provided for @desc_profile_locked.
  ///
  /// In en, this message translates to:
  /// **'Manually approves follow requests'**
  String get desc_profile_locked;

  /// No description provided for @desc_profile_discoverable.
  ///
  /// In en, this message translates to:
  /// **'Account can be discoverable in the profile directory'**
  String get desc_profile_discoverable;

  /// No description provided for @desc_profile_post_indexable.
  ///
  /// In en, this message translates to:
  /// **'The public post cannot be searchable'**
  String get desc_profile_post_indexable;

  /// No description provided for @desc_profile_hide_collections.
  ///
  /// In en, this message translates to:
  /// **'Everyone can follow-up your following and follower in your profile page'**
  String get desc_profile_hide_collections;

  /// No description provided for @desc_preference_reply_all.
  ///
  /// In en, this message translates to:
  /// **'Tag everyone mentioned in post'**
  String get desc_preference_reply_all;

  /// No description provided for @desc_preference_reply_only.
  ///
  /// In en, this message translates to:
  /// **'Only tag the poster'**
  String get desc_preference_reply_only;

  /// No description provided for @desc_preference_reply_none.
  ///
  /// In en, this message translates to:
  /// **'Tag no one'**
  String get desc_preference_reply_none;

  /// No description provided for @desc_create_list.
  ///
  /// In en, this message translates to:
  /// **'Create a new List'**
  String get desc_create_list;

  /// No description provided for @desc_list_search_following.
  ///
  /// In en, this message translates to:
  /// **'Search the following account to add into List'**
  String get desc_list_search_following;

  /// No description provided for @err_invalid_instance.
  ///
  /// In en, this message translates to:
  /// **'invalid Mastodon server domain: {domain}'**
  String err_invalid_instance(Object domain);

  /// No description provided for @msg_preference_engineer_clear_cache.
  ///
  /// In en, this message translates to:
  /// **'Cache cleared successfully'**
  String get msg_preference_engineer_clear_cache;

  /// No description provided for @msg_preference_engineer_reset.
  ///
  /// In en, this message translates to:
  /// **'Reset successfully'**
  String get msg_preference_engineer_reset;

  /// No description provided for @msg_copied_to_clipboard.
  ///
  /// In en, this message translates to:
  /// **'Copy to clipboard'**
  String get msg_copied_to_clipboard;

  /// No description provided for @msg_notification_title.
  ///
  /// In en, this message translates to:
  /// **'New Notifications'**
  String get msg_notification_title;

  /// No description provided for @msg_notification_body.
  ///
  /// In en, this message translates to:
  /// **'You have {count} unread notifications'**
  String msg_notification_body(Object count);

  /// No description provided for @msg_follow_request.
  ///
  /// In en, this message translates to:
  /// **'Follow Request from {name}'**
  String msg_follow_request(Object name);

  /// No description provided for @dots.
  ///
  /// In en, this message translates to:
  /// **'...'**
  String get dots;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'ja',
    'ko',
    'pt',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'pt':
      return AppLocalizationsPt();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
