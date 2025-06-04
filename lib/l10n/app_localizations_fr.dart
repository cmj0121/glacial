// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get txt_app_name => 'Glacial';

  @override
  String get txt_invalid_instance => 'Serveur Mastodon invalide';

  @override
  String get txt_server_contact => 'Contact';

  @override
  String get txt_search_helper => 'Recherchez quelque chose d\'intéressant';

  @override
  String get txt_search_history => 'Historique de recherche';

  @override
  String get txt_search_mastodon => 'mastodon.social';

  @override
  String get txt_server_rules => 'Règles du serveur';

  @override
  String get btn_clean_all => 'Tout effacer';

  @override
  String get dots => '...';
}
