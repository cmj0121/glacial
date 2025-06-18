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

  /// No description provided for @txt_app_name.
  ///
  /// In en, this message translates to:
  /// **'Glacial'**
  String get txt_app_name;

  /// No description provided for @txt_invalid_instance.
  ///
  /// In en, this message translates to:
  /// **'Invalid Mastodon server'**
  String get txt_invalid_instance;

  /// No description provided for @txt_server_contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get txt_server_contact;

  /// No description provided for @txt_search_helper.
  ///
  /// In en, this message translates to:
  /// **'Search for something interesting'**
  String get txt_search_helper;

  /// No description provided for @txt_search_history.
  ///
  /// In en, this message translates to:
  /// **'Search history'**
  String get txt_search_history;

  /// No description provided for @txt_search_mastodon.
  ///
  /// In en, this message translates to:
  /// **'mastodon.social'**
  String get txt_search_mastodon;

  /// No description provided for @txt_server_rules.
  ///
  /// In en, this message translates to:
  /// **'Server rules'**
  String get txt_server_rules;

  /// No description provided for @txt_show_less.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get txt_show_less;

  /// No description provided for @txt_show_more.
  ///
  /// In en, this message translates to:
  /// **'Show more'**
  String get txt_show_more;

  /// No description provided for @txt_trends_uses.
  ///
  /// In en, this message translates to:
  /// **'{uses} used in the past days'**
  String txt_trends_uses(Object uses);

  /// No description provided for @txt_no_results_found.
  ///
  /// In en, this message translates to:
  /// **'No results found for {keyword}'**
  String txt_no_results_found(Object keyword);

  /// No description provided for @txt_copied_to_clipboard.
  ///
  /// In en, this message translates to:
  /// **'Copy to Clipboard'**
  String get txt_copied_to_clipboard;

  /// No description provided for @txt_public.
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get txt_public;

  /// No description provided for @txt_unlisted.
  ///
  /// In en, this message translates to:
  /// **'Unlisted'**
  String get txt_unlisted;

  /// No description provided for @txt_private.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get txt_private;

  /// No description provided for @txt_direct.
  ///
  /// In en, this message translates to:
  /// **'Direct'**
  String get txt_direct;

  /// No description provided for @btn_clean_all.
  ///
  /// In en, this message translates to:
  /// **'Clean All'**
  String get btn_clean_all;

  /// No description provided for @btn_timeline.
  ///
  /// In en, this message translates to:
  /// **'Timelines'**
  String get btn_timeline;

  /// No description provided for @btn_trending.
  ///
  /// In en, this message translates to:
  /// **'Trending now'**
  String get btn_trending;

  /// No description provided for @btn_notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get btn_notifications;

  /// No description provided for @btn_settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get btn_settings;

  /// No description provided for @btn_management.
  ///
  /// In en, this message translates to:
  /// **'Administration'**
  String get btn_management;

  /// No description provided for @btn_trends_links.
  ///
  /// In en, this message translates to:
  /// **'News'**
  String get btn_trends_links;

  /// No description provided for @btn_trends_statuses.
  ///
  /// In en, this message translates to:
  /// **'Posts'**
  String get btn_trends_statuses;

  /// No description provided for @btn_trends_tags.
  ///
  /// In en, this message translates to:
  /// **'Hashtags'**
  String get btn_trends_tags;

  /// No description provided for @btn_home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get btn_home;

  /// No description provided for @btn_user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get btn_user;

  /// No description provided for @btn_profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get btn_profile;

  /// No description provided for @btn_pin.
  ///
  /// In en, this message translates to:
  /// **'Pin'**
  String get btn_pin;

  /// No description provided for @btn_schedule.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get btn_schedule;

  /// No description provided for @btn_local.
  ///
  /// In en, this message translates to:
  /// **'This server'**
  String get btn_local;

  /// No description provided for @btn_federal.
  ///
  /// In en, this message translates to:
  /// **'Other servers'**
  String get btn_federal;

  /// No description provided for @btn_public.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get btn_public;

  /// No description provided for @btn_bookmarks.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks'**
  String get btn_bookmarks;

  /// No description provided for @btn_favourites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get btn_favourites;

  /// No description provided for @btn_post.
  ///
  /// In en, this message translates to:
  /// **'New post'**
  String get btn_post;

  /// No description provided for @btn_follow_mutual.
  ///
  /// In en, this message translates to:
  /// **'Mutual'**
  String get btn_follow_mutual;

  /// No description provided for @btn_following.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get btn_following;

  /// No description provided for @btn_followed_by.
  ///
  /// In en, this message translates to:
  /// **'Followed By'**
  String get btn_followed_by;

  /// No description provided for @btn_follow.
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get btn_follow;

  /// No description provided for @btn_block.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get btn_block;

  /// No description provided for @btn_unblock.
  ///
  /// In en, this message translates to:
  /// **'Unblock'**
  String get btn_unblock;

  /// No description provided for @btn_mute.
  ///
  /// In en, this message translates to:
  /// **'Mute'**
  String get btn_mute;

  /// No description provided for @btn_unmute.
  ///
  /// In en, this message translates to:
  /// **'Unmute'**
  String get btn_unmute;

  /// No description provided for @btn_report.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get btn_report;

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
