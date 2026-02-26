// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get btn_search => 'Rechercher';

  @override
  String get btn_save => 'Enregistrer';

  @override
  String get btn_close => 'Fermer';

  @override
  String get btn_clear => 'Effacer';

  @override
  String get btn_exit => 'Quitter';

  @override
  String get btn_reload => 'Recharger';

  @override
  String get btn_history => 'Historique';

  @override
  String get btn_sidebar_timelines => 'Chronologies';

  @override
  String get btn_sidebar_lists => 'Listes';

  @override
  String get btn_sidebar_trendings => 'Tendances';

  @override
  String get btn_sidebar_notifications => 'Notifications';

  @override
  String get btn_sidebar_management => 'Gestion';

  @override
  String get btn_sidebar_post => 'Toot';

  @override
  String get btn_sidebar_sign_in => 'Se connecter';

  @override
  String get btn_drawer_switch_server => 'Changer de serveur';

  @override
  String get btn_drawer_directory => 'Explorer le compte';

  @override
  String get btn_drawer_announcement => 'Annonces';

  @override
  String get btn_drawer_preference => 'Préférences';

  @override
  String get btn_drawer_logout => 'Déconnexion';

  @override
  String get btn_dismiss => 'Ignorer';

  @override
  String get btn_trends_links => 'Liens';

  @override
  String get btn_trends_toots => 'Toots';

  @override
  String get btn_trends_users => 'Utilisateurs';

  @override
  String get btn_trends_tags => 'Tags';

  @override
  String get btn_timeline_home => 'Accueil';

  @override
  String get btn_timeline_local => 'Local';

  @override
  String get btn_timeline_federal => 'Fédéral';

  @override
  String get btn_timeline_public => 'Public';

  @override
  String get btn_timeline_favourites => 'Favoris';

  @override
  String get btn_timeline_bookmarks => 'Signets';

  @override
  String get btn_timeline_list => 'Listes';

  @override
  String get btn_timeline_vote => 'Voter';

  @override
  String btn_timeline_unread(Object count) {
    return '#$count toots non lus';
  }

  @override
  String get btn_preference_theme => 'Thème';

  @override
  String get btn_preference_engineer => 'Paramètres développeur';

  @override
  String get btn_preference_about => 'À propos';

  @override
  String get btn_preference_engineer_clear_cache => 'Vider le cache';

  @override
  String get btn_preference_engineer_reset => 'Réinitialiser le système';

  @override
  String get btn_preference_engineer_test_notifier => 'Tester la notification';

  @override
  String get btn_interaction_reply => 'Répondre';

  @override
  String get btn_interaction_reblog => 'Reblog';

  @override
  String get btn_interaction_favourite => 'Favori';

  @override
  String get btn_interaction_bookmark => 'Signet';

  @override
  String get btn_interaction_share => 'Partager';

  @override
  String get btn_interaction_mute => 'Masquer la conversation';

  @override
  String get btn_interaction_block => 'Bloquer';

  @override
  String get btn_interaction_report => 'Signaler';

  @override
  String get btn_interaction_edit => 'Modifier';

  @override
  String get btn_interaction_delete => 'Supprimer';

  @override
  String get btn_interaction_quote => 'Citation';

  @override
  String get btn_interaction_filter => 'Filtre';

  @override
  String get btn_interaction_pin => 'Épingler';

  @override
  String get btn_interaction_policy => 'Politique';

  @override
  String get btn_status_info => 'Voir les interactions';

  @override
  String get btn_status_history => 'Voir l\'historique des modifications';

  @override
  String get btn_profile_core => 'Profil';

  @override
  String get btn_profile_post => 'Toots';

  @override
  String get btn_profile_pin => 'Épinglé';

  @override
  String get btn_profile_followers => 'Abonnés';

  @override
  String get btn_profile_following => 'Abonnements';

  @override
  String get btn_profile_scheduled => 'Toots programmés';

  @override
  String get btn_profile_hashtag => 'Hashtags suivis';

  @override
  String get btn_profile_filter => 'Filtres';

  @override
  String get btn_profile_mute => 'Utilisateurs muets';

  @override
  String get btn_profile_block => 'Utilisateurs bloqués';

  @override
  String get btn_profile_general_info => 'Informations générales';

  @override
  String get btn_profile_privacy => 'Paramètres de confidentialité';

  @override
  String get btn_status_toot => 'Toot';

  @override
  String get btn_status_edit => 'Modifier';

  @override
  String get btn_status_scheduled => 'Toot programmé';

  @override
  String get btn_relationship_following => 'Abonnement';

  @override
  String get btn_relationship_followed_by => 'Suivi par';

  @override
  String get btn_relationship_follow_each_other => 'Amis';

  @override
  String get btn_relationship_follow_request =>
      'Demande envoyée (en attente d’approbation)';

  @override
  String get btn_relationship_stranger => 'Inconnu';

  @override
  String get btn_relationship_blocked_by => 'Bloqué par';

  @override
  String btn_relationship_mute(Object acct) {
    return 'Muet $acct';
  }

  @override
  String btn_relationship_unmute(Object acct) {
    return 'Réactiver $acct';
  }

  @override
  String btn_relationship_block(Object acct) {
    return 'Bloquer $acct';
  }

  @override
  String btn_relationship_unblock(Object acct) {
    return 'Débloquer $acct';
  }

  @override
  String btn_relationship_report(Object acct) {
    return 'Signaler $acct';
  }

  @override
  String get btn_relationship_note => 'Note personnelle';

  @override
  String get desc_relationship_note =>
      'Ajouter une note personnelle sur ce compte';

  @override
  String get btn_relationship_endorse => 'Mettre en avant sur le profil';

  @override
  String get btn_relationship_unendorse => 'Retirer du profil';

  @override
  String get btn_relationship_remove_follower => 'Retirer l\'abonné';

  @override
  String get btn_notification_mention => 'Mention';

  @override
  String get btn_notification_status => 'Notification';

  @override
  String get btn_notification_reblog => 'Reblog';

  @override
  String get btn_notification_follow => 'Abonné';

  @override
  String get btn_notification_follow_request => 'Demande d’abonnement';

  @override
  String get btn_notification_favourite => 'Favori';

  @override
  String get btn_notification_poll => 'Sondage';

  @override
  String get btn_notification_update => 'Mise à jour';

  @override
  String get btn_notification_admin_sign_up => 'Nouvelle inscription';

  @override
  String get btn_notification_admin_report => 'Nouveau rapport';

  @override
  String get btn_notification_unknown => 'Inconnu';

  @override
  String get btn_follow_request_accept => 'Accepter';

  @override
  String get btn_follow_request_reject => 'Refuser';

  @override
  String get btn_report_back => 'Retour';

  @override
  String get btn_report_next => 'Suivant';

  @override
  String get btn_report_file => 'Déposer un rapport';

  @override
  String get btn_report_statuses => 'Toots';

  @override
  String get btn_report_rules => 'Règles';

  @override
  String get btn_filter_warn => 'Avertir';

  @override
  String get btn_filter_hide => 'Masquer';

  @override
  String get btn_filter_blur => 'Flouter';

  @override
  String get btn_filter_context_home => 'Fil d’accueil';

  @override
  String get btn_filter_context_notification => 'Notifications';

  @override
  String get btn_filter_context_public => 'Fil public';

  @override
  String get btn_filter_context_thread => 'Le toot et ses réponses';

  @override
  String get btn_filter_context_account => 'Page de profil';

  @override
  String get btn_filter_whole_match => 'Correspondance exacte';

  @override
  String get btn_filter_partial_match => 'Correspondance partielle';

  @override
  String get desc_preference_engineer_clear_cache =>
      'Vider toutes les données en cache';

  @override
  String get desc_preference_engineer_reset =>
      'Réinitialiser toutes les options et l’application';

  @override
  String get desc_preference_engineer_test_notifier =>
      'Tester l’envoi de notification sur l’appareil local';

  @override
  String get txt_spoiler => 'Spoiler';

  @override
  String get txt_search_history => 'Historique des recherches';

  @override
  String get txt_helper_server_explorer => 'Rechercher un serveur Mastodon';

  @override
  String get txt_hint_server_explorer => 'mastodon.social ou mot-clé';

  @override
  String get txt_desc_preference_system_theme => 'Thème du système';

  @override
  String get txt_visibility_public => 'Public';

  @override
  String get txt_visibility_unlisted => 'Non listé';

  @override
  String get txt_visibility_private => 'Privé';

  @override
  String get txt_visibility_direct => 'Direct';

  @override
  String get txt_suggestion_staff => 'Recommandation du staff';

  @override
  String get txt_suggestion_past_interactions => 'Interactions précédentes';

  @override
  String get txt_suggestion_global => 'Popularité mondiale';

  @override
  String get txt_poll_show_total => 'Afficher le total';

  @override
  String get txt_poll_hide_total => 'Masquer le total';

  @override
  String get txt_poll_single => 'Choix unique';

  @override
  String get txt_poll_multiple => 'Choix multiples';

  @override
  String get txt_preference_status => 'Paramètres du statut';

  @override
  String get txt_preference_visibiliby => 'Visibilité';

  @override
  String get txt_preference_sensitive => 'Contenu sensible';

  @override
  String get txt_preference_refresh_interval =>
      'Intervalle de rafraîchissement';

  @override
  String get txt_preference_loaded_top =>
      'Aligner lors du chargement des plus récents';

  @override
  String get txt_preference_reply_all => 'Répondre à tous';

  @override
  String get txt_preference_reply_only => 'Seulement l’auteur';

  @override
  String get txt_preference_reply_none => 'Ne taguer personne';

  @override
  String get txt_show_less => 'Afficher moins';

  @override
  String get txt_show_more => 'Afficher plus';

  @override
  String get btn_translate_show => 'Traduire';

  @override
  String get btn_translate_hide => 'Afficher l\'original';

  @override
  String get txt_familiar_followers => 'Également suivi par';

  @override
  String get txt_featured_tags => 'Tags mis en avant';

  @override
  String get txt_no_result => 'Aucun résultat';

  @override
  String get txt_profile_bot => 'Compte bot';

  @override
  String get txt_profile_locked => 'Compte verrouillé';

  @override
  String get txt_profile_discoverable => 'Découvrable';

  @override
  String get txt_profile_post_indexable => 'Confidentialité des posts publics';

  @override
  String get txt_profile_hide_collections => 'Afficher abonnements et abonnés';

  @override
  String get txt_profile_general_name => 'Nom affiché';

  @override
  String get txt_profile_general_bio => 'Bio';

  @override
  String get txt_list_policy_followed =>
      'Afficher les réponses des utilisateurs suivis';

  @override
  String get txt_list_policy_list =>
      'Afficher uniquement les réponses des membres de la liste';

  @override
  String get txt_list_policy_none => 'Ne pas afficher de réponses';

  @override
  String get txt_list_exclusive => 'Retirer de la timeline d’accueil';

  @override
  String get txt_list_inclusive => 'Conserver dans la timeline d’accueil';

  @override
  String get txt_report_spam => 'Spam';

  @override
  String get txt_report_legal => 'Contenu illégal';

  @override
  String get txt_report_violation => 'Violation des règles';

  @override
  String get txt_report_other => 'Autre';

  @override
  String get txt_filter_title => 'Choisir un filtre à appliquer';

  @override
  String get txt_filter_applied => 'Filtre déjà appliqué';

  @override
  String get txt_filter_name => 'Nom du filtre';

  @override
  String get txt_filter_expired => 'Expiré';

  @override
  String get txt_filter_never => 'Jamais';

  @override
  String get txt_quote_policy_public => 'Public';

  @override
  String get txt_quote_policy_followers => 'Abonnés';

  @override
  String get txt_quote_policy_nobody => 'Personne';

  @override
  String get desc_preference_status =>
      'Configurer et contrôler le comportement par défaut de vos statuts';

  @override
  String get desc_poll_show_hide_total =>
      'Afficher/masquer le nombre de votes jusqu’à la fin du sondage';

  @override
  String get desc_preference_visibility =>
      'Contrôler qui peut voir et lister le statut';

  @override
  String get desc_preference_sensitive =>
      'Afficher/Masquer le contenu sensible par défaut';

  @override
  String get desc_visibility_public =>
      'Tout le monde peut voir et lister ce toot';

  @override
  String get desc_visibility_unlisted =>
      'Public mais non listé dans la timeline';

  @override
  String get desc_visibility_private =>
      'Seulement les abonnés et les utilisateurs mentionnés';

  @override
  String get desc_visibility_direct => 'Seulement les utilisateurs mentionnés';

  @override
  String get desc_preference_refresh_interval =>
      'Intervalle de rafraîchissement des données de l’application';

  @override
  String get desc_preference_loaded_top =>
      'Charger les données les plus récentes et remonter en haut en appuyant sur l’icône';

  @override
  String get desc_preference_locale => 'La langue du système sera utilisée';

  @override
  String get txt_preference_timeline => 'Paramètres du fil';

  @override
  String get desc_preference_timeline =>
      'Contrôler ce qui apparaît dans votre fil';

  @override
  String get txt_preference_hide_replies => 'Masquer les réponses';

  @override
  String get desc_preference_hide_replies =>
      'Masquer les réponses de votre fil';

  @override
  String get txt_preference_hide_reblogs => 'Masquer les reblogs';

  @override
  String get desc_preference_hide_reblogs => 'Masquer les reblogs de votre fil';

  @override
  String get txt_preference_auto_play => 'Lecture automatique des vidéos';

  @override
  String get desc_preference_auto_play =>
      'Lire automatiquement les vidéos dans le fil';

  @override
  String get txt_preference_timeline_limit => 'Taille du fil';

  @override
  String get desc_preference_timeline_limit =>
      'Nombre maximum de publications à charger à la fois';

  @override
  String get txt_preference_image_quality => 'Qualité d\'image';

  @override
  String get txt_preference_image_low => 'Basse (économise les données)';

  @override
  String get txt_preference_image_medium => 'Moyenne';

  @override
  String get txt_preference_image_high => 'Haute (originale)';

  @override
  String get txt_preference_appearance => 'Apparence';

  @override
  String get desc_preference_appearance =>
      'Personnaliser l\'apparence de l\'application';

  @override
  String get txt_preference_font_scale => 'Taille de police';

  @override
  String get desc_profile_bot =>
      'Compte pouvant effectuer des actions automatisées sans supervision humaine';

  @override
  String get desc_profile_locked =>
      'Approuve manuellement les demandes d’abonnement';

  @override
  String get desc_profile_discoverable =>
      'Le compte peut être découvert dans le répertoire public';

  @override
  String get desc_profile_post_indexable =>
      'Les posts publics peuvent être recherchés par tout le monde';

  @override
  String get desc_profile_hide_collections =>
      'Tout le monde peut voir vos abonnements et abonnés sur votre profil';

  @override
  String get desc_preference_reply_all =>
      'Taguer tous les utilisateurs mentionnés';

  @override
  String get desc_preference_reply_only => 'Taguer seulement l’auteur';

  @override
  String get desc_preference_reply_none => 'Ne taguer personne';

  @override
  String get desc_create_list => 'Créer une nouvelle liste';

  @override
  String get desc_list_search_following =>
      'Rechercher les comptes suivis pour ajouter à la liste';

  @override
  String get desc_report_spam =>
      'Le compte publie des publicités non sollicitées.';

  @override
  String get desc_report_legal =>
      'Le compte publie du contenu illégal ou demande des actions illégales.';

  @override
  String get desc_report_violation =>
      'Le compte publie du contenu qui enfreint les règles de l’instance.';

  @override
  String get desc_report_other => 'Autres raisons non répertoriées.';

  @override
  String get desc_report_comment =>
      'Ajoutez un commentaire facultatif pour donner plus de contexte à votre rapport.';

  @override
  String get desc_filter_warn =>
      'Afficher un avertissement avec le titre du filtre.';

  @override
  String get desc_filter_hide => 'Ne pas afficher ce statut.';

  @override
  String get desc_filter_blur => 'Flouter le contenu sensible.';

  @override
  String get desc_filter_context_home =>
      'Tout toot correspondant dans le fil d’accueil';

  @override
  String get desc_filter_context_notification =>
      'Toute notification correspondante';

  @override
  String get desc_filter_context_public =>
      'Tout toot correspondant dans le fil public';

  @override
  String get desc_filter_context_thread =>
      'Tout toot et ses réponses correspondants';

  @override
  String get desc_filter_context_account => 'Tout profil correspondant';

  @override
  String get desc_filter_expiration => 'Quand le filtre expirera';

  @override
  String get desc_filter_context => 'Où appliquer le filtre';

  @override
  String get desc_quote_approval_public =>
      'N’importe qui peut citer ce statut.';

  @override
  String get desc_quote_approval_followers =>
      'Seuls les abonnés peuvent citer ce statut.';

  @override
  String get desc_quote_approval_following =>
      'Seules les personnes suivies par l’auteur peuvent citer ce statut.';

  @override
  String get desc_quote_approval_unsupport =>
      'Aucune politique de citation prise en charge.';

  @override
  String get desc_quote_policy => 'Politique de citation';

  @override
  String get desc_quote_policy_public => 'N’importe qui peut citer ce statut.';

  @override
  String get desc_quote_policy_followers =>
      'Seuls les abonnés peuvent citer ce statut.';

  @override
  String get desc_quote_policy_nobody => 'Personne ne peut citer ce statut.';

  @override
  String get desc_quote_removed => 'Le statut cité n’est pas disponible';

  @override
  String err_invalid_instance(Object domain) {
    return 'Serveur Mastodon invalide : $domain';
  }

  @override
  String get msg_preference_engineer_clear_cache => 'Cache vidé avec succès';

  @override
  String get msg_preference_engineer_reset => 'Réinitialisation réussie';

  @override
  String get msg_copied_to_clipboard => 'Copié dans le presse-papiers';

  @override
  String get msg_notification_title => 'Nouvelles notifications';

  @override
  String msg_notification_body(Object count) {
    return 'Vous avez $count notifications non lues';
  }

  @override
  String msg_follow_request(Object name) {
    return 'Demande d’abonnement de $name';
  }

  @override
  String get txt_notification_policy => 'Politique de notifications';

  @override
  String get txt_notification_policy_not_following =>
      'Personnes que vous ne suivez pas';

  @override
  String get txt_notification_policy_not_followers =>
      'Personnes qui ne vous suivent pas';

  @override
  String get txt_notification_policy_new_accounts => 'Nouveaux comptes';

  @override
  String get txt_notification_policy_private_mentions => 'Mentions privées';

  @override
  String get txt_notification_policy_limited_accounts => 'Comptes modérés';

  @override
  String get txt_notification_policy_accept => 'Accepter';

  @override
  String get txt_notification_policy_filter => 'Filtrer';

  @override
  String get txt_notification_policy_drop => 'Rejeter';

  @override
  String get txt_no_announcements => 'Aucune annonce de ce serveur';

  @override
  String txt_poll_votes(int count) {
    return '$count votes';
  }

  @override
  String get txt_media_alt_text => 'Texte alternatif';

  @override
  String get txt_media_image_info => 'Info image';

  @override
  String get txt_media_no_exif => 'Aucune donnée EXIF';

  @override
  String get txt_server_rules => 'Règles du serveur';

  @override
  String get txt_server_registration => 'Inscription';

  @override
  String get txt_about_app_version => 'Version de l\'app';

  @override
  String get txt_about_author => 'Auteur';

  @override
  String get txt_about_repository => 'Dépôt';

  @override
  String get txt_about_copyright => 'Droits d\'auteur';

  @override
  String get btn_sidebar_conversations => 'Conversations';

  @override
  String get txt_no_conversations => 'Aucune conversation';

  @override
  String get txt_no_notifications => 'Aucune notification pour le moment';

  @override
  String get txt_conversation_unread => 'Non lu';

  @override
  String get btn_drawer_domain_blocks => 'Domaines bloqués';

  @override
  String get btn_drawer_endorsed => 'Profils mis en avant';

  @override
  String get txt_no_domain_blocks => 'Aucun domaine bloqué';

  @override
  String get btn_admin_reports => 'Signalements';

  @override
  String get btn_admin_accounts => 'Comptes';

  @override
  String get btn_admin_approve => 'Approuver';

  @override
  String get btn_admin_reject => 'Rejeter';

  @override
  String get btn_admin_suspend => 'Suspendre';

  @override
  String get btn_admin_silence => 'Limiter';

  @override
  String get btn_admin_enable => 'Activer';

  @override
  String get btn_admin_unsilence => 'Retirer la limite';

  @override
  String get btn_admin_unsuspend => 'Annuler la suspension';

  @override
  String get btn_admin_unsensitive => 'Retirer le marquage sensible';

  @override
  String get btn_admin_assign => 'M\'assigner';

  @override
  String get btn_admin_unassign => 'Désassigner';

  @override
  String get btn_admin_resolve => 'Résoudre';

  @override
  String get btn_admin_reopen => 'Rouvrir';

  @override
  String get txt_admin_no_permission => 'Accès administrateur requis';

  @override
  String get txt_admin_no_reports => 'Aucun signalement';

  @override
  String get txt_admin_no_accounts => 'Aucun compte trouvé';

  @override
  String get txt_admin_report_resolved => 'Résolu';

  @override
  String get txt_admin_report_unresolved => 'Non résolu';

  @override
  String get txt_admin_account_active => 'Actif';

  @override
  String get txt_admin_account_pending => 'En attente';

  @override
  String get txt_admin_account_disabled => 'Désactivé';

  @override
  String get txt_admin_account_silenced => 'Limité';

  @override
  String get txt_admin_account_suspended => 'Suspendu';

  @override
  String get txt_admin_confirm_action => 'Confirmer l\'action';

  @override
  String get desc_admin_confirm_action =>
      'Cette action ne peut pas être facilement annulée. Êtes-vous sûr ?';

  @override
  String get txt_admin_report_by => 'Signalé par';

  @override
  String get txt_admin_assigned_to => 'Assigné à';

  @override
  String get btn_register => 'Créer un compte';

  @override
  String get txt_register_title => 'Créer un compte';

  @override
  String get txt_username => 'Nom d\'utilisateur';

  @override
  String get txt_email => 'E-mail';

  @override
  String get txt_password => 'Mot de passe';

  @override
  String get txt_confirm_password => 'Confirmer le mot de passe';

  @override
  String get txt_agreement =>
      'J\'accepte les règles du serveur et les conditions d\'utilisation';

  @override
  String get txt_reason => 'Raison de l\'inscription';

  @override
  String get txt_registration_success =>
      'Vérifiez votre e-mail pour confirmer votre compte';

  @override
  String get err_registration_failed => 'Échec de l\'inscription';

  @override
  String get err_field_required => 'Ce champ est obligatoire';

  @override
  String get err_invalid_email => 'Adresse e-mail invalide';

  @override
  String get err_password_too_short =>
      'Le mot de passe doit contenir au moins 8 caractères';

  @override
  String get err_password_mismatch => 'Les mots de passe ne correspondent pas';

  @override
  String get err_agreement_required => 'Vous devez accepter les conditions';

  @override
  String get txt_admin_account_confirmed => 'Confirmé';

  @override
  String get txt_admin_account_unconfirmed => 'Non confirmé';

  @override
  String get txt_admin_account_approved => 'Approuvé';

  @override
  String get txt_admin_account_not_approved => 'Non approuvé';

  @override
  String get txt_work_in_progress => 'En cours';

  @override
  String get txt_default_server_name => 'Serveur Glacial';

  @override
  String txt_hashtag_usage(int uses) {
    return '$uses utilisé ces derniers jours';
  }

  @override
  String get dots => '...';

  @override
  String get btn_drawer_switch_account => 'Changer de compte';

  @override
  String get btn_account_picker_add => 'Ajouter un compte';

  @override
  String get txt_account_picker_title => 'Comptes';

  @override
  String msg_account_switched(String username) {
    return 'Basculé vers $username';
  }

  @override
  String get msg_account_removed => 'Compte supprimé';

  @override
  String get btn_drawer_drafts => 'Brouillons';

  @override
  String get txt_drafts_title => 'Brouillons';

  @override
  String get txt_no_drafts => 'Aucun brouillon';

  @override
  String get msg_draft_saved => 'Brouillon enregistré';

  @override
  String get msg_draft_deleted => 'Brouillon supprimé';

  @override
  String get txt_draft_reply => 'Brouillon de réponse';

  @override
  String get btn_undo => 'Annuler';

  @override
  String get txt_offline_banner => 'Vous êtes hors ligne';

  @override
  String get txt_cached_data => 'Affichage des données en cache';

  @override
  String get msg_network_restored => 'Connexion rétablie';

  @override
  String get msg_confirm_reset =>
      'Toutes vos données, comptes et paramètres seront supprimés. Cette action est irréversible.';

  @override
  String get btn_confirm => 'Confirmer';

  @override
  String get msg_loading_error =>
      'Une erreur est survenue lors du chargement. Veuillez réessayer.';

  @override
  String get btn_retry => 'Réessayer';

  @override
  String get msg_test_notification_pending =>
      'La notification de test sera envoyée dans 5 secondes...';

  @override
  String get msg_test_notification_foreground =>
      'Les notifications ne sont pas envoyées lorsque l\'application est au premier plan.';

  @override
  String get lbl_swipe_back => 'Glisser pour revenir';

  @override
  String get lbl_swipe_remove => 'Glisser pour supprimer';

  @override
  String get lbl_swipe_delete => 'Glisser pour effacer';

  @override
  String get lbl_avatar => 'Avatar';

  @override
  String get msg_admin_only => 'Accès administrateur requis';

  @override
  String get msg_confirm_delete_post =>
      'Voulez-vous vraiment supprimer cette publication ? Cette action est irréversible.';

  @override
  String msg_confirm_block(String account) {
    return 'Bloquer $account ? Vous ne verrez plus ses publications.';
  }

  @override
  String msg_confirm_mute(String account) {
    return 'Masquer $account ? Ses publications seront cachées de vos fils.';
  }

  @override
  String get msg_confirm_delete_conversation =>
      'Supprimer cette conversation ?';

  @override
  String get msg_confirm_delete_filter => 'Supprimer ce filtre ?';

  @override
  String get msg_network_error =>
      'Une erreur est survenue. Veuillez réessayer.';

  @override
  String get btn_tap_retry => 'Appuyez pour réessayer';

  @override
  String get btn_change_server => 'Changer de serveur';

  @override
  String get msg_server_unreachable =>
      'Serveur inaccessible. Vérifiez votre connexion ou essayez un autre serveur.';

  @override
  String get msg_share_upload_failed =>
      'Échec du téléchargement de l\'image partagée';

  @override
  String get msg_share_received => 'Contenu partagé reçu';

  @override
  String get msg_share_not_signed_in =>
      'Connectez-vous pour partager du contenu';
}
