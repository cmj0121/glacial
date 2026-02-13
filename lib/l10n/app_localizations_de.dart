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
  String get btn_save => 'Speichern';

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
  String get btn_drawer_announcement => 'Ankündigungen';

  @override
  String get btn_drawer_preference => 'Einstellungen';

  @override
  String get btn_drawer_logout => 'Abmelden';

  @override
  String get btn_dismiss => 'Gelesen';

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
  String get btn_interaction_mute => 'Unterhaltung stummschalten';

  @override
  String get btn_interaction_block => 'Blockieren';

  @override
  String get btn_interaction_report => 'Melden';

  @override
  String get btn_interaction_edit => 'Bearbeiten';

  @override
  String get btn_interaction_delete => 'Löschen';

  @override
  String get btn_interaction_quote => 'Zitat';

  @override
  String get btn_interaction_filter => 'Filter';

  @override
  String get btn_interaction_pin => 'Anheften';

  @override
  String get btn_interaction_policy => 'Richtlinie';

  @override
  String get btn_status_info => 'Interaktionen anzeigen';

  @override
  String get btn_status_history => 'Bearbeitungsverlauf anzeigen';

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
  String get btn_relationship_note => 'Persönliche Notiz';

  @override
  String get desc_relationship_note =>
      'Eine persönliche Notiz zu diesem Konto hinzufügen';

  @override
  String get btn_relationship_endorse => 'Im Profil hervorheben';

  @override
  String get btn_relationship_unendorse => 'Aus dem Profil entfernen';

  @override
  String get btn_relationship_remove_follower => 'Follower entfernen';

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
  String get btn_filter_warn => 'Warnen';

  @override
  String get btn_filter_hide => 'Ausblenden';

  @override
  String get btn_filter_blur => 'Ausblenden';

  @override
  String get btn_filter_context_home => 'Start-Timeline';

  @override
  String get btn_filter_context_notification => 'Benachrichtigungen';

  @override
  String get btn_filter_context_public => 'Öffentliche Timeline';

  @override
  String get btn_filter_context_thread => 'Der Toot und seine Antworten';

  @override
  String get btn_filter_context_account => 'Profilseite';

  @override
  String get btn_filter_whole_match => 'Ganzes Wort';

  @override
  String get btn_filter_partial_match => 'Teiltreffer';

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
  String get btn_translate_show => 'Übersetzen';

  @override
  String get btn_translate_hide => 'Original anzeigen';

  @override
  String get txt_familiar_followers => 'Auch gefolgt von';

  @override
  String get txt_featured_tags => 'Hervorgehobene Tags';

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
  String get txt_filter_title => 'Filter zum Anwenden auswählen';

  @override
  String get txt_filter_applied => 'Filter bereits angewendet';

  @override
  String get txt_filter_name => 'Name des Filters';

  @override
  String get txt_filter_expired => 'Abgelaufen';

  @override
  String get txt_filter_never => 'Nie';

  @override
  String get txt_quote_policy_public => 'Öffentlich';

  @override
  String get txt_quote_policy_followers => 'Follower';

  @override
  String get txt_quote_policy_nobody => 'Niemand';

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
  String get txt_preference_timeline => 'Timeline-Einstellungen';

  @override
  String get desc_preference_timeline =>
      'Steuern, was in deiner Timeline erscheint';

  @override
  String get txt_preference_hide_replies => 'Antworten ausblenden';

  @override
  String get desc_preference_hide_replies =>
      'Antworten in deiner Timeline ausblenden';

  @override
  String get txt_preference_hide_reblogs => 'Reblogs ausblenden';

  @override
  String get desc_preference_hide_reblogs =>
      'Reblogs in deiner Timeline ausblenden';

  @override
  String get txt_preference_auto_play => 'Videos automatisch abspielen';

  @override
  String get desc_preference_auto_play =>
      'Videos in der Timeline automatisch abspielen';

  @override
  String get txt_preference_timeline_limit => 'Timeline-Größe';

  @override
  String get desc_preference_timeline_limit =>
      'Maximale Anzahl der Beiträge auf einmal laden';

  @override
  String get txt_preference_image_quality => 'Bildqualität';

  @override
  String get txt_preference_image_low => 'Niedrig (spart Daten)';

  @override
  String get txt_preference_image_medium => 'Mittel';

  @override
  String get txt_preference_image_high => 'Hoch (Original)';

  @override
  String get txt_preference_appearance => 'Erscheinungsbild';

  @override
  String get desc_preference_appearance => 'Anpassen, wie die App aussieht';

  @override
  String get txt_preference_font_scale => 'Schriftgröße';

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
  String get desc_filter_warn => 'Zeigt eine Warnung mit dem Filternamen.';

  @override
  String get desc_filter_hide => 'Diesen Status nicht anzeigen.';

  @override
  String get desc_filter_blur => 'Inhalt hinter sensiblem Hinweis verbergen.';

  @override
  String get desc_filter_context_home =>
      'Alle passenden Toots in der Start-Timeline';

  @override
  String get desc_filter_context_notification =>
      'Alle passenden Benachrichtigungen';

  @override
  String get desc_filter_context_public =>
      'Alle passenden Toots in der öffentlichen Timeline';

  @override
  String get desc_filter_context_thread => 'Alle passenden Toots und Antworten';

  @override
  String get desc_filter_context_account => 'Alle passenden Profilseiten';

  @override
  String get desc_filter_expiration => 'Wann der Filter abläuft';

  @override
  String get desc_filter_context => 'Wo der Filter angewendet wird';

  @override
  String get desc_quote_approval_public =>
      'Jeder kann diesen Beitrag zitieren.';

  @override
  String get desc_quote_approval_followers =>
      'Nur Follower können diesen Beitrag zitieren.';

  @override
  String get desc_quote_approval_following =>
      'Nur Personen, denen der Autor folgt, können diesen Beitrag zitieren.';

  @override
  String get desc_quote_approval_unsupport =>
      'Keine unterstützte Zitatrichtlinie.';

  @override
  String get desc_quote_policy => 'Zitatrichtlinie';

  @override
  String get desc_quote_policy_public => 'Jeder kann diesen Beitrag zitieren.';

  @override
  String get desc_quote_policy_followers =>
      'Nur Follower können diesen Beitrag zitieren.';

  @override
  String get desc_quote_policy_nobody =>
      'Niemand kann diesen Beitrag zitieren.';

  @override
  String get desc_quote_removed => 'Der zitierte Beitrag ist nicht verfügbar';

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
  String get txt_notification_policy => 'Benachrichtigungsrichtlinie';

  @override
  String get txt_notification_policy_not_following =>
      'Personen, denen du nicht folgst';

  @override
  String get txt_notification_policy_not_followers =>
      'Personen, die dir nicht folgen';

  @override
  String get txt_notification_policy_new_accounts => 'Neue Konten';

  @override
  String get txt_notification_policy_private_mentions => 'Private Erwähnungen';

  @override
  String get txt_notification_policy_limited_accounts => 'Moderierte Konten';

  @override
  String get txt_notification_policy_accept => 'Akzeptieren';

  @override
  String get txt_notification_policy_filter => 'Filtern';

  @override
  String get txt_notification_policy_drop => 'Verwerfen';

  @override
  String get txt_no_announcements => 'Keine Ankündigungen von diesem Server';

  @override
  String txt_poll_votes(int count) {
    return '$count Stimmen';
  }

  @override
  String get txt_media_alt_text => 'Alternativtext';

  @override
  String get txt_media_image_info => 'Bildinformationen';

  @override
  String get txt_media_no_exif => 'Keine EXIF-Daten verfügbar';

  @override
  String get txt_server_rules => 'Serverregeln';

  @override
  String get txt_server_registration => 'Registrierung';

  @override
  String get txt_about_app_version => 'App-Version';

  @override
  String get txt_about_author => 'Autor';

  @override
  String get txt_about_repository => 'Repository';

  @override
  String get txt_about_copyright => 'Urheberrecht';

  @override
  String get btn_sidebar_conversations => 'Konversationen';

  @override
  String get txt_no_conversations => 'Keine Konversationen';

  @override
  String get txt_no_notifications => 'Noch keine Benachrichtigungen';

  @override
  String get txt_conversation_unread => 'Ungelesen';

  @override
  String get btn_drawer_domain_blocks => 'Blockierte Domains';

  @override
  String get btn_drawer_endorsed => 'Empfohlene Profile';

  @override
  String get txt_no_domain_blocks => 'Keine blockierten Domains';

  @override
  String get btn_admin_reports => 'Berichte';

  @override
  String get btn_admin_accounts => 'Konten';

  @override
  String get btn_admin_approve => 'Genehmigen';

  @override
  String get btn_admin_reject => 'Ablehnen';

  @override
  String get btn_admin_suspend => 'Sperren';

  @override
  String get btn_admin_silence => 'Stummschalten';

  @override
  String get btn_admin_enable => 'Aktivieren';

  @override
  String get btn_admin_unsilence => 'Stummschaltung aufheben';

  @override
  String get btn_admin_unsuspend => 'Entsperren';

  @override
  String get btn_admin_unsensitive => 'Nicht sensibel';

  @override
  String get btn_admin_assign => 'Mir zuweisen';

  @override
  String get btn_admin_unassign => 'Zuweisung aufheben';

  @override
  String get btn_admin_resolve => 'Lösen';

  @override
  String get btn_admin_reopen => 'Erneut öffnen';

  @override
  String get txt_admin_no_permission => 'Adminzugang erforderlich';

  @override
  String get txt_admin_no_reports => 'Keine Berichte';

  @override
  String get txt_admin_no_accounts => 'Keine Konten gefunden';

  @override
  String get txt_admin_report_resolved => 'Gelöst';

  @override
  String get txt_admin_report_unresolved => 'Ungelöst';

  @override
  String get txt_admin_account_active => 'Aktiv';

  @override
  String get txt_admin_account_pending => 'Ausstehend';

  @override
  String get txt_admin_account_disabled => 'Deaktiviert';

  @override
  String get txt_admin_account_silenced => 'Stummgeschaltet';

  @override
  String get txt_admin_account_suspended => 'Gesperrt';

  @override
  String get txt_admin_confirm_action => 'Aktion bestätigen';

  @override
  String get desc_admin_confirm_action =>
      'Diese Aktion kann nicht einfach rückgängig gemacht werden. Sind Sie sicher?';

  @override
  String get txt_admin_report_by => 'Gemeldet von';

  @override
  String get txt_admin_assigned_to => 'Zugewiesen an';

  @override
  String get btn_register => 'Konto erstellen';

  @override
  String get txt_register_title => 'Konto erstellen';

  @override
  String get txt_username => 'Benutzername';

  @override
  String get txt_email => 'E-Mail';

  @override
  String get txt_password => 'Passwort';

  @override
  String get txt_confirm_password => 'Passwort bestätigen';

  @override
  String get txt_agreement =>
      'Ich stimme den Serverregeln und Nutzungsbedingungen zu';

  @override
  String get txt_reason => 'Grund für die Anmeldung';

  @override
  String get txt_registration_success =>
      'Überprüfen Sie Ihre E-Mail, um Ihr Konto zu bestätigen';

  @override
  String get err_registration_failed => 'Registrierung fehlgeschlagen';

  @override
  String get err_field_required => 'Dieses Feld ist erforderlich';

  @override
  String get err_invalid_email => 'Ungültige E-Mail-Adresse';

  @override
  String get err_password_too_short =>
      'Passwort muss mindestens 8 Zeichen lang sein';

  @override
  String get err_password_mismatch => 'Passwörter stimmen nicht überein';

  @override
  String get err_agreement_required => 'Sie müssen den Bedingungen zustimmen';

  @override
  String get txt_admin_account_confirmed => 'Bestätigt';

  @override
  String get txt_admin_account_unconfirmed => 'Unbestätigt';

  @override
  String get txt_admin_account_approved => 'Genehmigt';

  @override
  String get txt_admin_account_not_approved => 'Nicht genehmigt';

  @override
  String get txt_work_in_progress => 'In Arbeit';

  @override
  String get txt_default_server_name => 'Glacial-Server';

  @override
  String txt_hashtag_usage(int uses) {
    return '$uses in den letzten Tagen verwendet';
  }

  @override
  String get dots => '...';

  @override
  String get btn_drawer_switch_account => 'Konto wechseln';

  @override
  String get btn_account_picker_add => 'Konto hinzufügen';

  @override
  String get txt_account_picker_title => 'Konten';

  @override
  String msg_account_switched(String username) {
    return 'Zu $username gewechselt';
  }

  @override
  String get msg_account_removed => 'Konto entfernt';

  @override
  String get btn_drawer_drafts => 'Entwürfe';

  @override
  String get txt_drafts_title => 'Entwürfe';

  @override
  String get txt_no_drafts => 'Keine Entwürfe';

  @override
  String get msg_draft_saved => 'Entwurf gespeichert';

  @override
  String get msg_draft_deleted => 'Entwurf gelöscht';

  @override
  String get txt_draft_reply => 'Antwortentwurf';
}
