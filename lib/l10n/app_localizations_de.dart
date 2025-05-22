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
  String get txt_search_mastodon => 'mastodon.social';

  @override
  String get txt_search_hint => 'Drücken Sie Enter zum Suchen...';

  @override
  String get txt_search_helper => 'Suche nach etwas Interessantem';

  @override
  String get txt_search_history => 'Suchverlauf';

  @override
  String get txt_invalid_instance => 'Ungültiger Mastodon-Server';

  @override
  String get txt_server_contact => 'Kontaktinformationen';

  @override
  String get txt_server_rules => 'Serverregeln';

  @override
  String get txt_public => 'Öffentlich';

  @override
  String get txt_unlisted => 'Nicht gelistet';

  @override
  String get txt_private => 'Privat (Follower)';

  @override
  String get txt_direct => 'Direkt';

  @override
  String get txt_copied_to_clipboard => 'In die Zwischenablage kopiert';

  @override
  String txt_trends_uses(Object uses) {
    return '$uses Mal in den letzten Tagen verwendet';
  }

  @override
  String get txt_show_less => 'Weniger anzeigen';

  @override
  String get txt_show_more => 'Mehr anzeigen';

  @override
  String txt_user_profile(Object text) {
    return 'Profil von Benutzer $text';
  }

  @override
  String get btn_clean_all => 'Alles löschen';

  @override
  String get btn_back_to_explorer => 'Zurück zum Explorer';

  @override
  String get btn_sign_in => 'Anmelden';

  @override
  String get btn_timeline => 'Zeitleiste';

  @override
  String get btn_trending => 'Trends';

  @override
  String get btn_notifications => 'Benachrichtigungen';

  @override
  String get btn_explore => 'Entdecken';

  @override
  String get btn_settings => 'Einstellungen';

  @override
  String get btn_post => 'Beitrag';

  @override
  String get btn_home_timeline => 'Startseite';

  @override
  String get btn_local_timeline => 'Lokal';

  @override
  String get btn_federal_timeline => 'Föderal';

  @override
  String get btn_public_timeline => 'Öffentlich';

  @override
  String get btn_bookmarks_timeline => 'Lesezeichen';

  @override
  String get btn_favourites_timeline => 'Favoriten';

  @override
  String get btn_hashtag_timeline => 'Hashtag';

  @override
  String get btn_reply => 'Antworten';

  @override
  String get btn_reblog => 'Rebloggen';

  @override
  String get btn_favourite => 'Favorit';

  @override
  String get btn_bookmark => 'Lesezeichen';

  @override
  String get btn_share => 'Teilen';

  @override
  String get btn_mute => 'Stumm';

  @override
  String get btn_block => 'Blockieren';

  @override
  String get btn_delete => 'Löschen';

  @override
  String get dots => '...';
}
