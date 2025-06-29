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
  String get txt_show_less => 'Weniger anzeigen';

  @override
  String get txt_show_more => 'Mehr anzeigen';

  @override
  String txt_trends_uses(Object uses) {
    return '$uses Mal in den letzten Tagen verwendet';
  }

  @override
  String txt_no_results_found(Object keyword) {
    return 'Keine Ergebnisse für $keyword gefunden';
  }

  @override
  String get txt_copied_to_clipboard => 'In die Zwischenablage kopiert';

  @override
  String get txt_public => 'Öffentlich';

  @override
  String get txt_unlisted => 'Nicht gelistet';

  @override
  String get txt_private => 'Privat (Follower)';

  @override
  String get txt_direct => 'Direkt';

  @override
  String get btn_clean_all => 'Alles löschen';

  @override
  String get btn_timeline => 'Zeitleiste';

  @override
  String get btn_trending => 'Aktuelle Trends';

  @override
  String get btn_notifications => 'Benachrichtigungen';

  @override
  String get btn_settings => 'Einstellungen';

  @override
  String get btn_management => 'Administration';

  @override
  String get btn_trends_links => 'Neuigkeiten';

  @override
  String get btn_trends_statuses => 'Beiträge';

  @override
  String get btn_trends_tags => 'Hashtags';

  @override
  String get btn_home => 'Startseite';

  @override
  String get btn_user => 'Profil';

  @override
  String get btn_profile => 'Profil';

  @override
  String get btn_pin => 'Anheften';

  @override
  String get btn_schedule => 'Geplant';

  @override
  String get btn_local => 'Dieser Server';

  @override
  String get btn_federal => 'Externe Server';

  @override
  String get btn_public => 'Alle Server';

  @override
  String get btn_bookmarks => 'Lesezeichen';

  @override
  String get btn_favourites => 'Favoriten';

  @override
  String get btn_post => 'Neuer Beitrag';

  @override
  String get btn_follow_mutual => 'Beidseitig gefolgt';

  @override
  String get btn_following => 'Folgt';

  @override
  String get btn_followed_by => 'Gefolgt von';

  @override
  String get btn_follow => 'Folgen';

  @override
  String get btn_block => 'Blockieren';

  @override
  String get btn_unblock => 'Entblocken';

  @override
  String get btn_mute => 'Stummschalten';

  @override
  String get btn_unmute => 'Stumm aus';

  @override
  String get btn_report => 'Melden';

  @override
  String get dots => '...';
}
