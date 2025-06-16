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
  String get txt_show_less => 'Afficher moins';

  @override
  String get txt_show_more => 'Afficher plus';

  @override
  String txt_trends_uses(Object uses) {
    return 'Utilisé $uses fois ces derniers jours';
  }

  @override
  String txt_no_results_found(Object keyword) {
    return 'Aucun résultat trouvé pour $keyword';
  }

  @override
  String get txt_copied_to_clipboard => 'Copié dans le presse-papiers';

  @override
  String get txt_public => 'Public';

  @override
  String get txt_unlisted => 'Non listé';

  @override
  String get txt_private => 'Privé (abonnés)';

  @override
  String get txt_direct => 'Direct';

  @override
  String get btn_clean_all => 'Tout effacer';

  @override
  String get btn_timeline => 'Fil d’actualité';

  @override
  String get btn_trending => 'Tendance en ce moment';

  @override
  String get btn_notifications => 'Tendance en ce moment';

  @override
  String get btn_settings => 'Paramètres';

  @override
  String get btn_management => 'Administration';

  @override
  String get btn_trends_links => 'Nouvelles';

  @override
  String get btn_trends_statuses => 'Messages';

  @override
  String get btn_trends_tags => 'Hashtags';

  @override
  String get btn_home => 'Accueil';

  @override
  String get btn_user => 'utilisateur·ice';

  @override
  String get btn_local => 'Ce serveur';

  @override
  String get btn_federal => 'Autres serveurs';

  @override
  String get btn_public => 'Tout';

  @override
  String get btn_bookmarks => 'Marque-pages';

  @override
  String get btn_favourites => 'Favoris';

  @override
  String get btn_post => 'Nouveau message';

  @override
  String get btn_follow_mutual => 'Abonnement mutuel';

  @override
  String get btn_following => 'Abonné';

  @override
  String get btn_followed_by => 'Abonné par';

  @override
  String get btn_follow => 'Suivre';

  @override
  String get btn_block => 'Bloquer';

  @override
  String get btn_unblock => 'Débloquer';

  @override
  String get btn_mute => 'Mettre en sourdine';

  @override
  String get btn_unmute => 'Réactiver le son';

  @override
  String get btn_report => 'Signaler';

  @override
  String get dots => '...';
}
