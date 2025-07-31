import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
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
    Locale('en'),
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

  /// No description provided for @btn_sidebar_notificatios.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get btn_sidebar_notificatios;

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

  /// No description provided for @btn_drawer_switch_server.
  ///
  /// In en, this message translates to:
  /// **'Switch Server'**
  String get btn_drawer_switch_server;

  /// No description provided for @btn_drawer_profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get btn_drawer_profile;

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

  /// No description provided for @btn_preference_engineer_clear_cache.
  ///
  /// In en, this message translates to:
  /// **'Clear All Cache'**
  String get btn_preference_engineer_clear_cache;

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

  /// No description provided for @desc_preference_engineer_clear_cache.
  ///
  /// In en, this message translates to:
  /// **'Clear all cached data and reset the app'**
  String get desc_preference_engineer_clear_cache;

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

  /// No description provided for @msg_copied_to_clipboard.
  ///
  /// In en, this message translates to:
  /// **'Copy to clipboard'**
  String get msg_copied_to_clipboard;

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
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
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
