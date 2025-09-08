// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get btn_search => 'Suchen';

  @override
  String get btn_close => 'Schließen';

  @override
  String get btn_clear => 'Löschen';

  @override
  String get btn_exit => 'Beenden';

  @override
  String get btn_reload => 'Neu laden';

  @override
  String get btn_history => 'Verlauf';

  @override
  String get btn_sidebar_timelines => 'Timelines';

  @override
  String get btn_sidebar_lists => 'Listen';

  @override
  String get btn_sidebar_trendings => 'Trends';

  @override
  String get btn_sidebar_notifications => 'Benachrichtigungen';

  @override
  String get btn_sidebar_management => 'Verwaltung';

  @override
  String get btn_sidebar_post => 'Toot';

  @override
  String get btn_sidebar_sign_in => 'Anmelden';

  @override
  String get btn_drawer_switch_server => 'Server wechseln';

  @override
  String get btn_drawer_directory => 'Account erkunden';

  @override
  String get btn_drawer_preference => 'Einstellungen';

  @override
  String get btn_drawer_logout => 'Abmelden';

  @override
  String get btn_trends_links => 'Links';

  @override
  String get btn_trends_toots => 'Toots';

  @override
  String get btn_trends_users => 'Benutzer';

  @override
  String get btn_trends_tags => 'Tags';

  @override
  String get btn_timeline_home => 'Startseite';

  @override
  String get btn_timeline_local => 'Lokal';

  @override
  String get btn_timeline_federal => 'Föderal';

  @override
  String get btn_timeline_public => 'Öffentlich';

  @override
  String get btn_timeline_favourites => 'Favoriten';

  @override
  String get btn_timeline_bookmarks => 'Lesezeichen';

  @override
  String get btn_timeline_list => 'Listen';

  @override
  String get btn_timeline_vote => 'Abstimmen';

  @override
  String btn_timeline_unread(Object count) {
    return '#$count ungelesene Toots';
  }

  @override
  String get btn_preference_theme => 'Thema';

  @override
  String get btn_preference_engineer => 'Entwicklereinstellungen';

  @override
  String get btn_preference_about => 'Über';

  @override
  String get btn_preference_engineer_clear_cache => 'Cache löschen';

  @override
  String get btn_preference_engineer_reset => 'System zurücksetzen';

  @override
  String get btn_preference_engineer_test_notifier => 'Benachrichtigung testen';

  @override
  String get btn_interaction_reply => 'Antworten';

  @override
  String get btn_interaction_reblog => 'Reblog';

  @override
  String get btn_interaction_favourite => 'Favorit';

  @override
  String get btn_interaction_bookmark => 'Lesezeichen';

  @override
  String get btn_interaction_share => 'Teilen';

  @override
  String get btn_interaction_mute => 'Stummschalten';

  @override
  String get btn_interaction_block => 'Blockieren';

  @override
  String get btn_interaction_report => 'Melden';

  @override
  String get btn_interaction_edit => 'Bearbeiten';

  @override
  String get btn_interaction_delete => 'Löschen';

  @override
  String get btn_profile_core => 'Profil';

  @override
  String get btn_profile_post => 'Toots';

  @override
  String get btn_profile_pin => 'Angeheftet';

  @override
  String get btn_profile_followers => 'Follower';

  @override
  String get btn_profile_following => 'Folgend';

  @override
  String get btn_profile_scheduled => 'Geplante Toots';

  @override
  String get btn_profile_hashtag => 'Gefolgte Hashtags';

  @override
  String get btn_profile_filter => 'Filter';

  @override
  String get btn_profile_mute => 'Stummgeschaltete Nutzer';

  @override
  String get btn_profile_block => 'Blockierte Nutzer';

  @override
  String get btn_profile_general_info => 'Allgemeine Infos';

  @override
  String get btn_profile_privacy => 'Datenschutzeinstellungen';

  @override
  String get btn_status_toot => 'Toot';

  @override
  String get btn_status_edit => 'Bearbeiten';

  @override
  String get btn_status_scheduled => 'Geplanter Toot';

  @override
  String get btn_relationship_following => 'Folgend';

  @override
  String get btn_relationship_followed_by => 'Gefolgt von';

  @override
  String get btn_relationship_follow_each_other => 'Freunde';

  @override
  String get btn_relationship_follow_request =>
      'Anfrage gesendet (wartet auf Bestätigung)';

  @override
  String get btn_relationship_stranger => 'Fremd';

  @override
  String get btn_relationship_blocked_by => 'Blockiert von';

  @override
  String btn_relationship_mute(Object acct) {
    return '$acct stummschalten';
  }

  @override
  String btn_relationship_unmute(Object acct) {
    return '$acct Stummschaltung aufheben';
  }

  @override
  String btn_relationship_block(Object acct) {
    return '$acct blockieren';
  }

  @override
  String btn_relationship_unblock(Object acct) {
    return '$acct Blockierung aufheben';
  }

  @override
  String btn_relationship_report(Object acct) {
    return '$acct melden';
  }

  @override
  String get btn_notification_mention => 'Erwähnt';

  @override
  String get btn_notification_status => 'Benachrichtigung';

  @override
  String get btn_notification_reblog => 'Reblog';

  @override
  String get btn_notification_follow => 'Gefolgt';

  @override
  String get btn_notification_follow_request => 'Follow-Anfrage';

  @override
  String get btn_notification_favourite => 'Favorit';

  @override
  String get btn_notification_poll => 'Umfrage';

  @override
  String get btn_notification_update => 'Aktualisierung';

  @override
  String get btn_notification_admin_sign_up => 'Neue Anmeldung';

  @override
  String get btn_notification_admin_report => 'Neuer Bericht';

  @override
  String get btn_notification_unknown => 'Unbekannt';

  @override
  String get btn_follow_request_accept => 'Akzeptieren';

  @override
  String get btn_follow_request_reject => 'Ablehnen';

  @override
  String get btn_report_back => 'Zurück';

  @override
  String get btn_report_next => 'Weiter';

  @override
  String get btn_report_file => 'Bericht einreichen';

  @override
  String get btn_report_statuses => 'Toots';

  @override
  String get btn_report_rules => 'Regeln';

  @override
  String get desc_preference_engineer_clear_cache =>
      'Alle zwischengespeicherten Daten löschen';

  @override
  String get desc_preference_engineer_reset =>
      'Alle Einstellungen löschen und App zurücksetzen';

  @override
  String get desc_preference_engineer_test_notifier =>
      'Benachrichtigung auf dem lokalen Gerät testen';

  @override
  String get txt_spoiler => 'Spoiler';

  @override
  String get txt_search_history => 'Suchverlauf';

  @override
  String get txt_helper_server_explorer => 'Mastodon-Server suchen';

  @override
  String get txt_hint_server_explorer => 'mastodon.social oder Stichwort';

  @override
  String get txt_desc_preference_system_theme => 'Systemthema';

  @override
  String get txt_visibility_public => 'Öffentlich';

  @override
  String get txt_visibility_unlisted => 'Nicht gelistet';

  @override
  String get txt_visibility_private => 'Privat';

  @override
  String get txt_visibility_direct => 'Direkt';

  @override
  String get txt_suggestion_staff => 'Empfehlung des Teams';

  @override
  String get txt_suggestion_past_interactions => 'Frühere Interaktionen';

  @override
  String get txt_suggestion_global => 'Globale Beliebtheit';

  @override
  String get txt_poll_show_total => 'Gesamt anzeigen';

  @override
  String get txt_poll_hide_total => 'Gesamt verbergen';

  @override
  String get txt_poll_single => 'Einzelauswahl';

  @override
  String get txt_poll_multiple => 'Mehrfachauswahl';

  @override
  String get txt_preference_status => 'Status-Einstellungen';

  @override
  String get txt_preference_visibiliby => 'Sichtbarkeit';

  @override
  String get txt_preference_sensitive => 'Sensibler Inhalt';

  @override
  String get txt_preference_refresh_interval => 'Aktualisierungsintervall';

  @override
  String get txt_preference_loaded_top => 'Ausrichten beim Laden der neuesten';

  @override
  String get txt_preference_reply_all => 'Alle markieren';

  @override
  String get txt_preference_reply_only => 'Nur Autor';

  @override
  String get txt_preference_reply_none => 'Niemand markieren';

  @override
  String get txt_show_less => 'Weniger anzeigen';

  @override
  String get txt_show_more => 'Mehr anzeigen';

  @override
  String get txt_no_result => 'Keine Ergebnisse gefunden';

  @override
  String get txt_profile_bot => 'Bot-Account';

  @override
  String get txt_profile_locked => 'Account gesperrt';

  @override
  String get txt_profile_discoverable => 'Entdeckbar';

  @override
  String get txt_profile_post_indexable =>
      'Privatsphäre der öffentlichen Beiträge';

  @override
  String get txt_profile_hide_collections => 'Follower und Folgendes anzeigen';

  @override
  String get txt_profile_general_name => 'Anzeigename';

  @override
  String get txt_profile_general_bio => 'Bio';

  @override
  String get txt_list_policy_followed =>
      'Antworten aller gefolgten Nutzer anzeigen';

  @override
  String get txt_list_policy_list =>
      'Nur Antworten der List-Mitglieder anzeigen';

  @override
  String get txt_list_policy_none => 'Keine Antworten anzeigen';

  @override
  String get txt_list_exclusive => 'Aus Home-Timeline entfernen';

  @override
  String get txt_list_inclusive => 'In Home-Timeline belassen';

  @override
  String get txt_report_spam => 'Spam';

  @override
  String get txt_report_legal => 'Illegale Inhalte';

  @override
  String get txt_report_violation => 'Regelverstoß';

  @override
  String get txt_report_other => 'Andere';

  @override
  String get desc_preference_status =>
      'Standard-Verhalten der Statusmeldungen festlegen und steuern';

  @override
  String get desc_poll_show_hide_total =>
      'Anzeigen/Verbergen der Stimmen bis zum Ende der Umfrage';

  @override
  String get desc_preference_visibility =>
      'Steuern, wer den Status sehen und listen kann';

  @override
  String get desc_preference_sensitive =>
      'Sensible Inhalte standardmäßig anzeigen/verbergen';

  @override
  String get desc_visibility_public => 'Jeder kann diesen Toot sehen';

  @override
  String get desc_visibility_unlisted =>
      'Öffentlich, aber nicht in der Timeline';

  @override
  String get desc_visibility_private => 'Nur Follower und erwähnte Nutzer';

  @override
  String get desc_visibility_direct => 'Nur erwähnte Nutzer';

  @override
  String get desc_preference_refresh_interval =>
      'Intervall für die Aktualisierung der App-Daten';

  @override
  String get desc_preference_loaded_top =>
      'Beim Tippen auf das Symbol die neuesten Daten laden und nach oben springen';

  @override
  String get desc_preference_locale => 'Die Systemsprache wird verwendet';

  @override
  String get desc_profile_bot =>
      'Der Account kann automatisierte Aktionen ausführen und wird nicht menschlich überwacht';

  @override
  String get desc_profile_locked => 'Follow-Anfragen manuell genehmigen';

  @override
  String get desc_profile_discoverable =>
      'Account ist im öffentlichen Verzeichnis auffindbar';

  @override
  String get desc_profile_post_indexable =>
      'Öffentliche Beiträge können von jedem gesucht werden';

  @override
  String get desc_profile_hide_collections =>
      'Follower und Folgende im Profil anzeigen';

  @override
  String get desc_preference_reply_all =>
      'Alle in einem Beitrag markierten Nutzer taggen';

  @override
  String get desc_preference_reply_only => 'Nur Autor taggen';

  @override
  String get desc_preference_reply_none => 'Niemand taggen';

  @override
  String get desc_create_list => 'Neue Liste erstellen';

  @override
  String get desc_list_search_following =>
      'Folgende Konten suchen, um zur Liste hinzuzufügen';

  @override
  String get desc_report_spam =>
      'Das Konto veröffentlicht unerwünschte Werbung.';

  @override
  String get desc_report_legal =>
      'Das Konto veröffentlicht illegale Inhalte oder fordert zu illegalen Handlungen auf.';

  @override
  String get desc_report_violation =>
      'Das Konto veröffentlicht Inhalte, die gegen die Regeln dieser Instanz verstoßen.';

  @override
  String get desc_report_other => 'Andere nicht aufgeführte Gründe.';

  @override
  String get desc_report_comment =>
      'Fügen Sie optional einen Kommentar hinzu, um Ihren Bericht zu erläutern';

  @override
  String err_invalid_instance(Object domain) {
    return 'Ungültiger Mastodon-Server: $domain';
  }

  @override
  String get msg_preference_engineer_clear_cache =>
      'Cache erfolgreich gelöscht';

  @override
  String get msg_preference_engineer_reset => 'Zurücksetzen erfolgreich';

  @override
  String get msg_copied_to_clipboard => 'In die Zwischenablage kopiert';

  @override
  String get msg_notification_title => 'Neue Benachrichtigungen';

  @override
  String msg_notification_body(Object count) {
    return 'Du hast $count ungelesene Benachrichtigungen';
  }

  @override
  String msg_follow_request(Object name) {
    return 'Follow-Anfrage von $name';
  }

  @override
  String get dots => '...';
}
