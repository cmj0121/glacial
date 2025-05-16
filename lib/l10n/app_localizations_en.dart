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
  String get txt_invalid_instance => 'Invalid Mastodon server';

  @override
  String get dots => '...';
}
