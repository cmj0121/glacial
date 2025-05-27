// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get txt_app_name => 'glacial';

  @override
  String get txt_search_mastodon => 'mastodon.social';

  @override
  String get txt_search_hint => 'Appuyez sur Entrée pour rechercher...';

  @override
  String get txt_search_helper => 'Recherchez quelque chose d\'intéressant';

  @override
  String get txt_search_history => 'Historique de recherche';

  @override
  String get txt_invalid_instance => 'Serveur Mastodon invalide';

  @override
  String get txt_server_contact => 'Coordonnées';

  @override
  String get txt_server_rules => 'Règles du serveur';

  @override
  String get txt_public => 'Public';

  @override
  String get txt_unlisted => 'Non listé';

  @override
  String get txt_private => 'Privé (abonnés)';

  @override
  String get txt_direct => 'Direct';

  @override
  String get txt_copied_to_clipboard => 'Copié dans le presse-papiers';

  @override
  String txt_trends_uses(Object uses) {
    return 'Utilisé $uses fois ces derniers jours';
  }

  @override
  String get txt_show_less => 'Afficher moins';

  @override
  String get txt_show_more => 'Afficher plus';

  @override
  String txt_user_profile(Object text) {
    return 'Profil de l\'utilisateur $text';
  }

  @override
  String txt_no_results_found(Object keyword) {
    return 'Aucun résultat trouvé pour $keyword';
  }

  @override
  String get btn_clean_all => 'Tout effacer';

  @override
  String get btn_back_to_explorer => 'Retour à l\'explorateur';

  @override
  String get btn_sign_in => 'Se connecter';

  @override
  String get btn_timeline => 'Fil d’actualité';

  @override
  String get btn_trending => 'Tendances';

  @override
  String get btn_notifications => 'Notifications';

  @override
  String get btn_explore => 'Explorer';

  @override
  String get btn_settings => 'Paramètres';

  @override
  String get btn_post => 'Publier';

  @override
  String get btn_home_timeline => 'Accueil';

  @override
  String get btn_local_timeline => 'Local';

  @override
  String get btn_federal_timeline => 'Fédéral';

  @override
  String get btn_public_timeline => 'Public';

  @override
  String get btn_bookmarks_timeline => 'Favoris';

  @override
  String get btn_favourites_timeline => 'Favoris';

  @override
  String get btn_hashtag_timeline => 'Hashtag';

  @override
  String get btn_reply => 'Répondre';

  @override
  String get btn_reblog => 'Rebloguer';

  @override
  String get btn_favourite => 'Favori';

  @override
  String get btn_bookmark => 'Signet';

  @override
  String get btn_share => 'Partager';

  @override
  String get btn_mute => 'Muet';

  @override
  String get btn_block => 'Bloquer';

  @override
  String get btn_delete => 'Supprimer';

  @override
  String get btn_trends_links => 'Actualités chaudes';

  @override
  String get btn_trends_statuses => 'Statuts';

  @override
  String get btn_trends_tags => 'Étiquettes';

  @override
  String get btn_management => 'Gestion';

  @override
  String get dots => '...';
}
