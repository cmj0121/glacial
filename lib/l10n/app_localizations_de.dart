// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get txt_app_name => 'Gletscher';

  @override
  String get txt_invalid_instance => 'Ungültiger Mastodon-Server';

  @override
  String get txt_server_contact => 'Kontakt';

  @override
  String get txt_search_helper => 'Suche nach etwas Interessantem';

  @override
  String get txt_search_history => 'Suchverlauf';

  @override
  String get txt_search_mastodon => 'mastodon.social';

  @override
  String get txt_server_rules => 'Serverregeln';

  @override
  String get btn_clean_all => 'Alles löschen';

  @override
  String get dots => '...';
}
