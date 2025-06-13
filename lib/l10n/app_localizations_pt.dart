// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get txt_app_name => 'Glacial';

  @override
  String get txt_invalid_instance => 'Servidor Mastodon inválido';

  @override
  String get txt_server_contact => 'Contacto';

  @override
  String get txt_search_helper => 'Pesquise algo interessante';

  @override
  String get txt_search_history => 'Histórico de pesquisa';

  @override
  String get txt_search_mastodon => 'mastodon.social';

  @override
  String get txt_server_rules => 'Regras do servidor';

  @override
  String get txt_show_less => 'Mostrar menos';

  @override
  String get txt_show_more => 'Mostrar mais';

  @override
  String txt_trends_uses(Object uses) {
    return 'Utilisé $uses fois ces derniers jours';
  }

  @override
  String txt_no_results_found(Object keyword) {
    return 'Nenhum resultado encontrado para $keyword';
  }

  @override
  String get txt_copied_to_clipboard => 'Copiado para a área de transferência';

  @override
  String get txt_public => 'Público';

  @override
  String get txt_unlisted => 'Não listado';

  @override
  String get txt_private => 'Privado (seguidores)';

  @override
  String get txt_direct => 'Direta';

  @override
  String get btn_clean_all => 'Limpar tudo';

  @override
  String get btn_timeline => 'Linha do tempo';

  @override
  String get btn_trending => 'Tendências atuais';

  @override
  String get btn_notifications => 'Notificações';

  @override
  String get btn_settings => 'Configurações';

  @override
  String get btn_management => 'Administração';

  @override
  String get btn_trends_links => 'Notícias';

  @override
  String get btn_trends_statuses => 'Publicações';

  @override
  String get btn_trends_tags => 'Etiquetas';

  @override
  String get btn_home => 'Início';

  @override
  String get btn_user => 'utilizador';

  @override
  String get btn_local => 'Este servidor';

  @override
  String get btn_federal => 'Outros servidores';

  @override
  String get btn_public => 'Todas';

  @override
  String get btn_bookmarks => 'Marcadores';

  @override
  String get btn_favourites => 'Favoritos';

  @override
  String get btn_post => 'Nova publicação';

  @override
  String get dots => '...';
}
